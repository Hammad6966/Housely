import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/image_model.dart';

/// Service for storing image metadata in Firebase Realtime Database.
/// Works with Cloudinary URLs - does NOT handle the actual image upload.
/// 
/// Usage:
/// ```dart
/// final imageService = ImageService();
/// 
/// // Save image metadata after Cloudinary upload
/// final imageModel = await imageService.saveImageMetadata(
///   imageUrl: cloudinaryUrl,
///   referenceId: propertyId,      // optional
///   referenceType: 'property',    // optional
///   publicId: cloudinaryPublicId, // optional
/// );
/// ```
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save image metadata to Firebase Realtime Database
  /// 
  /// [imageUrl] - The Cloudinary secure_url (required)
  /// [referenceId] - Optional ID linking to another entity (e.g., propertyId)
  /// [referenceType] - Optional type of reference ('property', 'profile', etc.)
  /// [publicId] - Optional Cloudinary public_id for future deletion
  /// 
  /// Returns the saved [ImageModel] with generated ID
  /// Throws [ImageServiceException] on failure
  Future<ImageModel> saveImageMetadata({
    required String imageUrl,
    String? referenceId,
    String? referenceType,
    String? publicId,
  }) async {
    try {
      // Get current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw ImageServiceException('User must be logged in to save images');
      }

      // Generate new ID
      final newRef = _database.child('images').push();
      final imageId = newRef.key!;

      // Create image model
      final imageModel = ImageModel(
        id: imageId,
        imageUrl: imageUrl,
        userId: currentUser.uid,
        referenceId: referenceId,
        referenceType: referenceType,
        publicId: publicId,
        createdAt: DateTime.now(),
      );

      // Save to database
      await newRef.set(imageModel.toJson());

      return imageModel;
    } on ImageServiceException {
      rethrow;
    } catch (e) {
      throw ImageServiceException('Failed to save image metadata: $e');
    }
  }

  /// Get all images for a specific reference (e.g., all images for a property)
  Future<List<ImageModel>> getImagesByReference({
    required String referenceId,
    required String referenceType,
  }) async {
    try {
      final snapshot = await _database
          .child('images')
          .orderByChild('referenceId')
          .equalTo(referenceId)
          .get();

      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.entries
          .map((e) => ImageModel.fromJson(Map<String, dynamic>.from(e.value as Map)))
          .where((img) => img.referenceType == referenceType)
          .toList();
    } catch (e) {
      throw ImageServiceException('Failed to fetch images: $e');
    }
  }

  /// Get all images uploaded by the current user
  Future<List<ImageModel>> getCurrentUserImages() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw ImageServiceException('User must be logged in');
      }

      final snapshot = await _database
          .child('images')
          .orderByChild('userId')
          .equalTo(currentUser.uid)
          .get();

      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final images = data.entries
          .map((e) => ImageModel.fromJson(Map<String, dynamic>.from(e.value as Map)))
          .toList();

      // Sort by createdAt descending
      images.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return images;
    } catch (e) {
      throw ImageServiceException('Failed to fetch user images: $e');
    }
  }

  /// Delete image metadata from database
  /// Note: This does NOT delete the image from Cloudinary
  Future<void> deleteImageMetadata(String imageId) async {
    try {
      await _database.child('images').child(imageId).remove();
    } catch (e) {
      throw ImageServiceException('Failed to delete image metadata: $e');
    }
  }

  /// Get a single image by ID
  Future<ImageModel?> getImageById(String imageId) async {
    try {
      final snapshot = await _database.child('images').child(imageId).get();

      if (!snapshot.exists || snapshot.value == null) {
        return null;
      }

      return ImageModel.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } catch (e) {
      throw ImageServiceException('Failed to fetch image: $e');
    }
  }

  /// Stream of images for real-time updates
  Stream<List<ImageModel>> getImagesStream({String? referenceId}) {
    Query query = _database.child('images');
    
    if (referenceId != null) {
      query = query.orderByChild('referenceId').equalTo(referenceId);
    }

    return query.onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <ImageModel>[];
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final images = data.entries
          .map((e) => ImageModel.fromJson(Map<String, dynamic>.from(e.value as Map)))
          .toList();

      images.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return images;
    });
  }

  // ============================================================
  // CURRENT USER IMAGE QUERIES
  // ============================================================

  /// Get image URLs only for current user (one-time fetch)
  /// Returns list of URLs ordered by createdAt descending
  Future<List<String>> getCurrentUserImageUrls() async {
    final images = await getCurrentUserImages();
    return images.map((img) => img.imageUrl).toList();
  }

  /// Real-time stream of current user's images
  /// Filtered by userId, ordered by createdAt descending
  Stream<List<ImageModel>> getCurrentUserImagesStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Return empty stream if not logged in
      return Stream.value(<ImageModel>[]);
    }

    return _database
        .child('images')
        .orderByChild('userId')
        .equalTo(currentUser.uid)
        .onValue
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <ImageModel>[];
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final images = data.entries
          .map((e) => ImageModel.fromJson(Map<String, dynamic>.from(e.value as Map)))
          .toList();

      // Sort by createdAt descending (newest first)
      images.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return images;
    });
  }

  /// Real-time stream of current user's image URLs only
  /// Filtered by userId, ordered by createdAt descending
  Stream<List<String>> getCurrentUserImageUrlsStream() {
    return getCurrentUserImagesStream()
        .map((images) => images.map((img) => img.imageUrl).toList());
  }

  /// Real-time stream of images by reference type for current user
  /// e.g., get all 'property' images or all 'profile' images
  Stream<List<ImageModel>> getCurrentUserImagesByTypeStream(String referenceType) {
    return getCurrentUserImagesStream()
        .map((images) => images.where((img) => img.referenceType == referenceType).toList());
  }
}

/// Custom exception for ImageService errors
class ImageServiceException implements Exception {
  final String message;
  
  ImageServiceException(this.message);
  
  @override
  String toString() => 'ImageServiceException: $message';
}
