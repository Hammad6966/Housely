import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/image_model.dart';
import 'cloudinary_service.dart';
import 'image_service.dart';

/// Orchestrates the complete image upload flow:
/// 1. Pick image from gallery/camera
/// 2. Upload to Cloudinary
/// 3. Save metadata to Firebase
/// 
/// Handles loading states and stops safely on any failure.
/// 
/// Edge cases handled:
/// - User cancels image selection → Returns cancelled state
/// - Upload fails mid-way → Cleans up, returns error
/// - Firebase write fails → Logs orphaned Cloudinary URL, returns error
/// - Network disconnects → Timeout + proper error message
/// - Concurrent uploads → Blocked with error message
class ImageUploadController {
  static final ImageUploadController _instance = ImageUploadController._internal();
  factory ImageUploadController() => _instance;
  ImageUploadController._internal();

  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinary = CloudinaryService();
  final ImageService _imageService = ImageService();

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Current step for UI feedback
  UploadStep _currentStep = UploadStep.idle;
  UploadStep get currentStep => _currentStep;

  // Track orphaned uploads (Cloudinary succeeded but Firebase failed)
  final List<String> _orphanedUrls = [];
  List<String> get orphanedUrls => List.unmodifiable(_orphanedUrls);

  // Upload timeout duration
  static const Duration _uploadTimeout = Duration(minutes: 2);
  static const Duration _firebaseTimeout = Duration(seconds: 30);

  /// Full upload flow: Pick → Upload → Save
  /// 
  /// [source] - ImageSource.gallery or ImageSource.camera
  /// [folder] - Cloudinary folder (e.g., 'profiles', 'properties')
  /// [referenceId] - Optional link to entity (e.g., propertyId)
  /// [referenceType] - Optional type ('property', 'profile')
  /// [maxWidth] - Max image width (default 1080)
  /// [maxHeight] - Max image height (default 1080)
  /// [imageQuality] - Compression quality 0-100 (default 85)
  /// 
  /// Returns [UploadResult] with success status and data/error
  Future<UploadResult> pickAndUploadImage({
    required ImageSource source,
    required String folder,
    String? referenceId,
    String? referenceType,
    double maxWidth = 1080,
    double maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    // ========== EDGE CASE: Concurrent uploads ==========
    if (_isLoading) {
      return UploadResult.failure(
        'Upload already in progress. Please wait.',
        errorType: UploadErrorType.concurrentUpload,
      );
    }

    _isLoading = true;
    _currentStep = UploadStep.picking;
    String? uploadedUrl; // Track for cleanup if Firebase fails

    try {
      // ========== STEP 1: Pick Image ==========
      final XFile? pickedFile;
      
      try {
        pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );
      } catch (e) {
        // ========== EDGE CASE: Picker error (permissions, etc.) ==========
        _reset();
        return UploadResult.failure(
          'Could not access ${source == ImageSource.camera ? 'camera' : 'gallery'}. Please check permissions.',
          errorType: UploadErrorType.permissionDenied,
        );
      }

      // ========== EDGE CASE: User cancelled selection ==========
      if (pickedFile == null) {
        _reset();
        return UploadResult.cancelled();
      }

      final File imageFile = File(pickedFile.path);

      // ========== EDGE CASE: File doesn't exist ==========
      if (!await imageFile.exists()) {
        _reset();
        return UploadResult.failure(
          'Selected file not found. Please try again.',
          errorType: UploadErrorType.fileNotFound,
        );
      }

      // ========== EDGE CASE: File is empty or corrupted ==========
      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        _reset();
        return UploadResult.failure(
          'Selected file is empty or corrupted.',
          errorType: UploadErrorType.invalidFile,
        );
      }

      // ========== EDGE CASE: File too large (>20MB) ==========
      if (fileSize > 20 * 1024 * 1024) {
        _reset();
        return UploadResult.failure(
          'File is too large. Maximum size is 20MB.',
          errorType: UploadErrorType.fileTooLarge,
        );
      }

      // ========== STEP 2: Upload to Cloudinary ==========
      _currentStep = UploadStep.uploading;

      try {
        uploadedUrl = await _cloudinary
            .uploadImage(imageFile: imageFile, folder: folder)
            .timeout(_uploadTimeout, onTimeout: () {
          throw TimeoutException('Upload timed out');
        });
      } on TimeoutException {
        // ========== EDGE CASE: Upload timeout ==========
        _reset();
        return UploadResult.failure(
          'Upload timed out. Please check your connection and try again.',
          errorType: UploadErrorType.timeout,
        );
      } on SocketException {
        // ========== EDGE CASE: No internet ==========
        _reset();
        return UploadResult.failure(
          'No internet connection. Please check your network.',
          errorType: UploadErrorType.noInternet,
        );
      } on CloudinaryException catch (e) {
        // ========== EDGE CASE: Cloudinary upload failed ==========
        _reset();
        return UploadResult.failure(
          'Upload failed: ${e.message}',
          errorType: UploadErrorType.uploadFailed,
        );
      }

      // ========== STEP 3: Save to Firebase ==========
      _currentStep = UploadStep.saving;

      try {
        final ImageModel savedImage = await _imageService
            .saveImageMetadata(
              imageUrl: uploadedUrl,
              referenceId: referenceId,
              referenceType: referenceType,
            )
            .timeout(_firebaseTimeout, onTimeout: () {
          throw TimeoutException('Firebase save timed out');
        });

        // ========== SUCCESS ==========
        _currentStep = UploadStep.complete;
        _isLoading = false;

        return UploadResult.success(
          imageUrl: uploadedUrl,
          imageModel: savedImage,
        );
      } on TimeoutException {
        // ========== EDGE CASE: Firebase timeout ==========
        // Image is on Cloudinary but not in database - track it
        _trackOrphanedUrl(uploadedUrl);
        _reset();
        return UploadResult.failure(
          'Save timed out. Image uploaded but not saved. Please try again.',
          errorType: UploadErrorType.firebaseTimeout,
          orphanedUrl: uploadedUrl,
        );
      } on ImageServiceException catch (e) {
        // ========== EDGE CASE: Firebase write failed ==========
        // Image is on Cloudinary but not in database - track it
        _trackOrphanedUrl(uploadedUrl);
        _reset();
        return UploadResult.failure(
          'Failed to save image data: ${e.message}',
          errorType: UploadErrorType.firebaseFailed,
          orphanedUrl: uploadedUrl,
        );
      }
    } catch (e) {
      // ========== EDGE CASE: Unexpected error ==========
      if (uploadedUrl != null) {
        _trackOrphanedUrl(uploadedUrl);
      }
      _reset();
      return UploadResult.failure(
        'Unexpected error: $e',
        errorType: UploadErrorType.unknown,
        orphanedUrl: uploadedUrl,
      );
    }
  }

  /// Upload profile image (convenience method)
  Future<UploadResult> uploadProfileImage({
    required ImageSource source,
    required String userId,
  }) {
    return pickAndUploadImage(
      source: source,
      folder: 'profiles',
      referenceId: userId,
      referenceType: 'profile',
    );
  }

  /// Upload property image (convenience method)
  Future<UploadResult> uploadPropertyImage({
    required ImageSource source,
    required String propertyId,
  }) {
    return pickAndUploadImage(
      source: source,
      folder: 'properties',
      referenceId: propertyId,
      referenceType: 'property',
    );
  }

  /// Upload from an existing File (skip picker)
  /// Useful when you already have the file
  Future<UploadResult> uploadExistingFile({
    required File imageFile,
    required String folder,
    String? referenceId,
    String? referenceType,
  }) async {
    if (_isLoading) {
      return UploadResult.failure(
        'Upload already in progress',
        errorType: UploadErrorType.concurrentUpload,
      );
    }

    _isLoading = true;
    String? uploadedUrl;

    try {
      // Validate file
      if (!await imageFile.exists()) {
        _reset();
        return UploadResult.failure(
          'File not found',
          errorType: UploadErrorType.fileNotFound,
        );
      }

      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        _reset();
        return UploadResult.failure(
          'File is empty or corrupted',
          errorType: UploadErrorType.invalidFile,
        );
      }

      // Upload to Cloudinary
      _currentStep = UploadStep.uploading;
      
      try {
        uploadedUrl = await _cloudinary
            .uploadImage(imageFile: imageFile, folder: folder)
            .timeout(_uploadTimeout);
      } on TimeoutException {
        _reset();
        return UploadResult.failure(
          'Upload timed out',
          errorType: UploadErrorType.timeout,
        );
      } on SocketException {
        _reset();
        return UploadResult.failure(
          'No internet connection',
          errorType: UploadErrorType.noInternet,
        );
      }

      // Save to Firebase
      _currentStep = UploadStep.saving;
      
      try {
        final ImageModel savedImage = await _imageService
            .saveImageMetadata(
              imageUrl: uploadedUrl,
              referenceId: referenceId,
              referenceType: referenceType,
            )
            .timeout(_firebaseTimeout);

        _currentStep = UploadStep.complete;
        _isLoading = false;

        return UploadResult.success(
          imageUrl: uploadedUrl,
          imageModel: savedImage,
        );
      } on TimeoutException {
        _trackOrphanedUrl(uploadedUrl);
        _reset();
        return UploadResult.failure(
          'Save timed out',
          errorType: UploadErrorType.firebaseTimeout,
          orphanedUrl: uploadedUrl,
        );
      } on ImageServiceException catch (e) {
        _trackOrphanedUrl(uploadedUrl);
        _reset();
        return UploadResult.failure(
          'Save failed: ${e.message}',
          errorType: UploadErrorType.firebaseFailed,
          orphanedUrl: uploadedUrl,
        );
      }
    } on CloudinaryException catch (e) {
      _reset();
      return UploadResult.failure(
        'Upload failed: ${e.message}',
        errorType: UploadErrorType.uploadFailed,
      );
    } catch (e) {
      if (uploadedUrl != null) {
        _trackOrphanedUrl(uploadedUrl);
      }
      _reset();
      return UploadResult.failure(
        'Unexpected error: $e',
        errorType: UploadErrorType.unknown,
        orphanedUrl: uploadedUrl,
      );
    }
  }

  /// Upload to Cloudinary only (no Firebase save)
  /// Returns just the URL - useful for profile pics stored in user document
  Future<UploadResult> uploadImageOnly({
    required ImageSource source,
    required String folder,
    double maxWidth = 1080,
    double maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    if (_isLoading) {
      return UploadResult.failure(
        'Upload already in progress',
        errorType: UploadErrorType.concurrentUpload,
      );
    }

    _isLoading = true;
    _currentStep = UploadStep.picking;

    try {
      // Pick image
      final XFile? pickedFile;
      
      try {
        pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );
      } catch (e) {
        _reset();
        return UploadResult.failure(
          'Could not access ${source == ImageSource.camera ? 'camera' : 'gallery'}',
          errorType: UploadErrorType.permissionDenied,
        );
      }

      if (pickedFile == null) {
        _reset();
        return UploadResult.cancelled();
      }

      final File imageFile = File(pickedFile.path);

      if (!await imageFile.exists()) {
        _reset();
        return UploadResult.failure(
          'File not found',
          errorType: UploadErrorType.fileNotFound,
        );
      }

      // Upload to Cloudinary
      _currentStep = UploadStep.uploading;
      
      try {
        final String imageUrl = await _cloudinary
            .uploadImage(imageFile: imageFile, folder: folder)
            .timeout(_uploadTimeout);

        _currentStep = UploadStep.complete;
        _isLoading = false;

        return UploadResult.success(imageUrl: imageUrl);
      } on TimeoutException {
        _reset();
        return UploadResult.failure(
          'Upload timed out',
          errorType: UploadErrorType.timeout,
        );
      } on SocketException {
        _reset();
        return UploadResult.failure(
          'No internet connection',
          errorType: UploadErrorType.noInternet,
        );
      }
    } on CloudinaryException catch (e) {
      _reset();
      return UploadResult.failure(
        'Upload failed: ${e.message}',
        errorType: UploadErrorType.uploadFailed,
      );
    } catch (e) {
      _reset();
      return UploadResult.failure(
        'Unexpected error: $e',
        errorType: UploadErrorType.unknown,
      );
    }
  }

  void _reset() {
    _isLoading = false;
    _currentStep = UploadStep.idle;
  }

  /// Track orphaned URLs (uploaded to Cloudinary but not saved to Firebase)
  void _trackOrphanedUrl(String url) {
    _orphanedUrls.add(url);
    debugPrint('⚠️ Orphaned image URL tracked: $url');
    // In production, you might want to:
    // 1. Store these in SharedPreferences for later cleanup
    // 2. Send to a backend service for deletion
    // 3. Log to analytics/crashlytics
  }

  /// Retry saving an orphaned URL to Firebase
  Future<UploadResult> retrySaveOrphanedUrl({
    required String imageUrl,
    String? referenceId,
    String? referenceType,
  }) async {
    if (_isLoading) {
      return UploadResult.failure(
        'Another operation in progress',
        errorType: UploadErrorType.concurrentUpload,
      );
    }

    _isLoading = true;
    _currentStep = UploadStep.saving;

    try {
      final savedImage = await _imageService
          .saveImageMetadata(
            imageUrl: imageUrl,
            referenceId: referenceId,
            referenceType: referenceType,
          )
          .timeout(_firebaseTimeout);

      // Remove from orphaned list on success
      _orphanedUrls.remove(imageUrl);

      _currentStep = UploadStep.complete;
      _isLoading = false;

      return UploadResult.success(
        imageUrl: imageUrl,
        imageModel: savedImage,
      );
    } catch (e) {
      _reset();
      return UploadResult.failure(
        'Retry failed: $e',
        errorType: UploadErrorType.firebaseFailed,
        orphanedUrl: imageUrl,
      );
    }
  }

  /// Clear orphaned URLs list (after manual cleanup)
  void clearOrphanedUrls() {
    _orphanedUrls.clear();
  }

  /// Cancel current upload (resets state)
  void cancel() {
    _reset();
  }
}

/// Current step in the upload process
enum UploadStep {
  idle,
  picking,
  uploading,
  saving,
  complete,
}

/// Types of upload errors for handling in UI
enum UploadErrorType {
  none,
  concurrentUpload,
  permissionDenied,
  fileNotFound,
  invalidFile,
  fileTooLarge,
  timeout,
  noInternet,
  uploadFailed,
  firebaseTimeout,
  firebaseFailed,
  unknown,
}

/// Result of an upload operation
class UploadResult {
  final bool success;
  final bool cancelled;
  final String? imageUrl;
  final ImageModel? imageModel;
  final String? errorMessage;
  final UploadErrorType errorType;
  final String? orphanedUrl; // URL uploaded but not saved to Firebase

  const UploadResult._({
    required this.success,
    this.cancelled = false,
    this.imageUrl,
    this.imageModel,
    this.errorMessage,
    this.errorType = UploadErrorType.none,
    this.orphanedUrl,
  });

  factory UploadResult.success({
    required String imageUrl,
    ImageModel? imageModel,
  }) {
    return UploadResult._(
      success: true,
      imageUrl: imageUrl,
      imageModel: imageModel,
    );
  }

  factory UploadResult.failure(
    String message, {
    UploadErrorType errorType = UploadErrorType.unknown,
    String? orphanedUrl,
  }) {
    return UploadResult._(
      success: false,
      errorMessage: message,
      errorType: errorType,
      orphanedUrl: orphanedUrl,
    );
  }

  factory UploadResult.cancelled() {
    return const UploadResult._(
      success: false,
      cancelled: true,
    );
  }

  /// Check if this error is recoverable (can retry)
  bool get isRetryable {
    return errorType == UploadErrorType.timeout ||
        errorType == UploadErrorType.noInternet ||
        errorType == UploadErrorType.firebaseTimeout ||
        errorType == UploadErrorType.firebaseFailed;
  }

  /// Check if there's an orphaned image that needs cleanup
  bool get hasOrphanedImage => orphanedUrl != null;

  @override
  String toString() {
    if (cancelled) return 'UploadResult: Cancelled';
    if (success) return 'UploadResult: Success - $imageUrl';
    return 'UploadResult: Failed ($errorType) - $errorMessage';
  }
}
