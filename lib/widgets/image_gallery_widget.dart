import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/image_model.dart';
import '../services/image_service.dart';

/// A widget that displays images from Firebase Realtime Database
/// using StreamBuilder for real-time updates.
/// 
/// Features:
/// - Real-time updates via StreamBuilder
/// - Empty state handling
/// - Loading state handling
/// - Network image caching
/// - Responsive grid layout
class ImageGalleryStream extends StatelessWidget {
  final String? referenceId;
  final String? referenceType;
  final bool currentUserOnly;
  final int crossAxisCount;
  final double spacing;
  final double aspectRatio;
  final Function(ImageModel image)? onImageTap;
  final Function(ImageModel image)? onImageLongPress;
  final Widget? emptyStateWidget;
  final bool showDeleteButton;
  final Function(ImageModel image)? onDelete;

  const ImageGalleryStream({
    super.key,
    this.referenceId,
    this.referenceType,
    this.currentUserOnly = true,
    this.crossAxisCount = 3,
    this.spacing = 8,
    this.aspectRatio = 1.0,
    this.onImageTap,
    this.onImageLongPress,
    this.emptyStateWidget,
    this.showDeleteButton = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imageService = ImageService();
    
    // Choose the appropriate stream based on parameters
    Stream<List<ImageModel>> stream;
    
    if (currentUserOnly) {
      if (referenceType != null) {
        stream = imageService.getCurrentUserImagesByTypeStream(referenceType!);
      } else {
        stream = imageService.getCurrentUserImagesStream();
      }
    } else if (referenceId != null) {
      stream = imageService.getImagesStream(referenceId: referenceId);
    } else {
      stream = imageService.getImagesStream();
    }

    return StreamBuilder<List<ImageModel>>(
      stream: stream,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        // Error state
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        // Empty state
        final images = snapshot.data ?? [];
        if (images.isEmpty) {
          return emptyStateWidget ?? _buildEmptyState();
        }

        // Data state - show images
        return _buildImageGrid(context, images);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 2.5),
          SizedBox(height: 16.h),
          Text(
            'Loading images...',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load images',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'No images yet',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Upload your first image to see it here',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, List<ImageModel> images) {
    return GridView.builder(
      padding: EdgeInsets.all(spacing.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing.w,
        mainAxisSpacing: spacing.h,
        childAspectRatio: aspectRatio,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return _ImageGridItem(
          image: images[index],
          onTap: onImageTap,
          onLongPress: onImageLongPress,
          showDeleteButton: showDeleteButton,
          onDelete: onDelete,
        );
      },
    );
  }
}

/// Individual image item in the grid
class _ImageGridItem extends StatelessWidget {
  final ImageModel image;
  final Function(ImageModel)? onTap;
  final Function(ImageModel)? onLongPress;
  final bool showDeleteButton;
  final Function(ImageModel)? onDelete;

  const _ImageGridItem({
    required this.image,
    this.onTap,
    this.onLongPress,
    this.showDeleteButton = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(image),
      onLongPress: () => onLongPress?.call(image),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cached Network Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: image.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey.shade400,
                  size: 32.sp,
                ),
              ),
            ),
          ),
          
          // Delete button overlay
          if (showDeleteButton)
            Positioned(
              top: 4.h,
              right: 4.w,
              child: GestureDetector(
                onTap: () => _confirmDelete(context),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call(image);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Full-screen image viewer with hero animation
class ImageViewer extends StatelessWidget {
  final ImageModel image;
  final List<ImageModel>? allImages;
  final int initialIndex;

  const ImageViewer({
    super.key,
    required this.image,
    this.allImages,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final images = allImages ?? [image];
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: images[index].imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Horizontal scrollable image list (for property details, etc.)
class ImageListHorizontal extends StatelessWidget {
  final Stream<List<ImageModel>> stream;
  final double height;
  final double itemWidth;
  final double spacing;
  final Function(ImageModel image, int index)? onImageTap;

  const ImageListHorizontal({
    super.key,
    required this.stream,
    this.height = 200,
    this.itemWidth = 280,
    this.spacing = 12,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h,
      child: StreamBuilder<List<ImageModel>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final images = snapshot.data ?? [];
          if (images.isEmpty) {
            return Center(
              child: Text(
                'No images',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: images.length,
            separatorBuilder: (_, __) => SizedBox(width: spacing.w),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => onImageTap?.call(images[index], index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: images[index].imageUrl,
                    width: itemWidth.w,
                    height: height.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: itemWidth.w,
                      color: Colors.grey.shade200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: itemWidth.w,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Simple cached image widget wrapper
class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Center(
            child: SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
