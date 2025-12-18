import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_upload_controller.dart';

/// A reusable image upload widget that handles:
/// - Upload button with camera/gallery selection
/// - Loading indicator during upload
/// - Success/error messages
/// - Non-blocking async operations
/// 
/// Usage:
/// ```dart
/// ImageUploadWidget(
///   folder: 'properties',
///   referenceId: propertyId,
///   referenceType: 'property',
///   onUploadSuccess: (url) => print('Uploaded: $url'),
///   onUploadError: (error) => print('Error: $error'),
/// )
/// ```
class ImageUploadWidget extends StatefulWidget {
  final String folder;
  final String? referenceId;
  final String? referenceType;
  final bool saveToFirebase;
  final Function(String imageUrl)? onUploadSuccess;
  final Function(String error)? onUploadError;
  final Widget? customButton;
  final double? buttonWidth;
  final double? buttonHeight;
  final Color? buttonColor;
  final String buttonText;
  final IconData buttonIcon;

  const ImageUploadWidget({
    super.key,
    required this.folder,
    this.referenceId,
    this.referenceType,
    this.saveToFirebase = true,
    this.onUploadSuccess,
    this.onUploadError,
    this.customButton,
    this.buttonWidth,
    this.buttonHeight,
    this.buttonColor,
    this.buttonText = 'Upload Image',
    this.buttonIcon = Icons.cloud_upload_outlined,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImageUploadController _controller = ImageUploadController();
  
  bool _isLoading = false;
  UploadStep _currentStep = UploadStep.idle;
  String? _successMessage;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Upload Button or Loading Indicator
        _isLoading ? _buildLoadingIndicator() : _buildUploadButton(),
        
        // Status Messages
        if (_successMessage != null) ...[
          SizedBox(height: 12.h),
          _buildSuccessMessage(),
        ],
        
        if (_errorMessage != null) ...[
          SizedBox(height: 12.h),
          _buildErrorMessage(),
        ],
      ],
    );
  }

  Widget _buildUploadButton() {
    if (widget.customButton != null) {
      return GestureDetector(
        onTap: _showSourceDialog,
        child: widget.customButton,
      );
    }

    return SizedBox(
      width: widget.buttonWidth ?? double.infinity,
      height: widget.buttonHeight ?? 56.h,
      child: ElevatedButton.icon(
        onPressed: _showSourceDialog,
        icon: Icon(widget.buttonIcon, size: 24.sp),
        label: Text(
          widget.buttonText,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.buttonColor ?? Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    String statusText;
    switch (_currentStep) {
      case UploadStep.picking:
        statusText = 'Opening...';
        break;
      case UploadStep.uploading:
        statusText = 'Uploading image...';
        break;
      case UploadStep.saving:
        statusText = 'Saving...';
        break;
      case UploadStep.complete:
        statusText = 'Complete!';
        break;
      default:
        statusText = 'Processing...';
    }

    return Container(
      width: widget.buttonWidth ?? double.infinity,
      height: widget.buttonHeight ?? 56.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              _successMessage!,
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 14.sp,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _successMessage = null),
            child: Icon(Icons.close, color: Colors.green.shade600, size: 18.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14.sp,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _errorMessage = null),
            child: Icon(Icons.close, color: Colors.red.shade600, size: 18.sp),
          ),
        ],
      ),
    );
  }

  void _showSourceDialog() {
    // Clear previous messages
    setState(() {
      _successMessage = null;
      _errorMessage = null;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            
            Text(
              'Choose Image Source',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _startUpload(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _startUpload(ImageSource.gallery);
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32.sp, color: Theme.of(context).primaryColor),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startUpload(ImageSource source) async {
    setState(() {
      _isLoading = true;
      _currentStep = UploadStep.picking;
      _successMessage = null;
      _errorMessage = null;
    });

    // Use a periodic check to update the UI with current step
    // This ensures the UI stays responsive
    _updateStepPeriodically();

    UploadResult result;
    
    if (widget.saveToFirebase) {
      // Full flow: Pick → Upload → Save to Firebase
      result = await _controller.pickAndUploadImage(
        source: source,
        folder: widget.folder,
        referenceId: widget.referenceId,
        referenceType: widget.referenceType,
      );
    } else {
      // Upload only (no Firebase save)
      result = await _controller.uploadImageOnly(
        source: source,
        folder: widget.folder,
      );
    }

    // Update UI based on result
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
      _currentStep = UploadStep.idle;
    });

    if (result.success) {
      setState(() {
        _successMessage = 'Image uploaded successfully!';
      });
      widget.onUploadSuccess?.call(result.imageUrl!);
    } else if (result.cancelled) {
      // User cancelled - no message needed
    } else {
      // Handle different error types with appropriate messages
      String errorMessage = _getErrorMessage(result);
      
      setState(() {
        _errorMessage = errorMessage;
      });
      widget.onUploadError?.call(errorMessage);
      
      // Show retry option for retryable errors with orphaned images
      if (result.hasOrphanedImage && result.isRetryable) {
        _showRetryDialog(result);
      }
    }
  }

  String _getErrorMessage(UploadResult result) {
    switch (result.errorType) {
      case UploadErrorType.concurrentUpload:
        return 'Please wait for the current upload to finish';
      case UploadErrorType.permissionDenied:
        return 'Permission denied. Please allow access in settings.';
      case UploadErrorType.fileNotFound:
        return 'File not found. Please try again.';
      case UploadErrorType.invalidFile:
        return 'Invalid file. Please select a different image.';
      case UploadErrorType.fileTooLarge:
        return 'File too large. Maximum size is 20MB.';
      case UploadErrorType.timeout:
        return 'Upload timed out. Please check your connection.';
      case UploadErrorType.noInternet:
        return 'No internet connection. Please try again later.';
      case UploadErrorType.uploadFailed:
        return result.errorMessage ?? 'Upload failed. Please try again.';
      case UploadErrorType.firebaseTimeout:
        return 'Save timed out. Image uploaded but not saved.';
      case UploadErrorType.firebaseFailed:
        return 'Failed to save image data. Please try again.';
      default:
        return result.errorMessage ?? 'An error occurred. Please try again.';
    }
  }

  void _showRetryDialog(UploadResult result) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Incomplete'),
        content: const Text(
          'The image was uploaded but could not be saved. Would you like to retry saving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _retrySave(result.orphanedUrl!);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _retrySave(String imageUrl) async {
    setState(() {
      _isLoading = true;
      _currentStep = UploadStep.saving;
      _errorMessage = null;
    });

    final result = await _controller.retrySaveOrphanedUrl(
      imageUrl: imageUrl,
      referenceId: widget.referenceId,
      referenceType: widget.referenceType,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _currentStep = UploadStep.idle;
    });

    if (result.success) {
      setState(() {
        _successMessage = 'Image saved successfully!';
      });
      widget.onUploadSuccess?.call(result.imageUrl!);
    } else {
      setState(() {
        _errorMessage = result.errorMessage ?? 'Retry failed';
      });
    }
  }

  void _updateStepPeriodically() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!_isLoading) return false;
      
      if (mounted) {
        setState(() {
          _currentStep = _controller.currentStep;
        });
      }
      return _isLoading;
    });
  }
}

/// Compact version - just an icon button
class ImageUploadIconButton extends StatefulWidget {
  final String folder;
  final String? referenceId;
  final String? referenceType;
  final bool saveToFirebase;
  final Function(String imageUrl)? onUploadSuccess;
  final Function(String error)? onUploadError;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const ImageUploadIconButton({
    super.key,
    required this.folder,
    this.referenceId,
    this.referenceType,
    this.saveToFirebase = true,
    this.onUploadSuccess,
    this.onUploadError,
    this.size = 48,
    this.color,
    this.backgroundColor,
  });

  @override
  State<ImageUploadIconButton> createState() => _ImageUploadIconButtonState();
}

class _ImageUploadIconButtonState extends State<ImageUploadIconButton> {
  final ImageUploadController _controller = ImageUploadController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _showSourceDialog,
      child: Container(
        width: widget.size.w,
        height: widget.size.w,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Theme.of(context).primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: _isLoading
            ? Padding(
                padding: EdgeInsets.all(widget.size * 0.25),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.color ?? Theme.of(context).primaryColor,
                  ),
                ),
              )
            : Icon(
                Icons.add_a_photo_outlined,
                size: widget.size * 0.5,
                color: widget.color ?? Theme.of(context).primaryColor,
              ),
      ),
    );
  }

  void _showSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Choose Image Source',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24.h),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _startUpload(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _startUpload(ImageSource.gallery);
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Future<void> _startUpload(ImageSource source) async {
    setState(() => _isLoading = true);

    UploadResult result;
    
    if (widget.saveToFirebase) {
      result = await _controller.pickAndUploadImage(
        source: source,
        folder: widget.folder,
        referenceId: widget.referenceId,
        referenceType: widget.referenceType,
      );
    } else {
      result = await _controller.uploadImageOnly(
        source: source,
        folder: widget.folder,
      );
    }

    setState(() => _isLoading = false);

    if (result.success) {
      widget.onUploadSuccess?.call(result.imageUrl!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (!result.cancelled) {
      widget.onUploadError?.call(result.errorMessage ?? 'Upload failed');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Upload failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
