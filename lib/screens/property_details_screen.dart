import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';
import '../models/property.dart';
import 'chat_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailsScreen({
    super.key,
    required this.property,
  });

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.property.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      backgroundColor: AppTheme.white,
      leading: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppTheme.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkGray.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.darkGray,
            size: 24.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ).animate().fadeIn(duration: 300.ms).scale(duration: 300.ms),
      actions: [
        Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.darkGray.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? AppTheme.accent : AppTheme.darkGray,
              size: 24.sp,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 100.ms)
            .scale(duration: 300.ms, delay: 100.ms),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildImageGallery(),
      ),
    );
  }

  Widget _buildImageGallery() {
    return Stack(
      children: [
        PageView.builder(
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: widget.property.images.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
              ),
              child: Image.asset(
                widget.property.images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.primaryTeal.withOpacity(0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home,
                          size: 50.sp,
                          color: AppTheme.primaryTeal,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Property Image',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
        Positioned(
          bottom: 20.h,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.property.images.length,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: _currentImageIndex == index
                      ? AppTheme.white
                      : AppTheme.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 300.ms)
            .slideY(begin: 0.3, duration: 500.ms, delay: 300.ms),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPropertyInfo(),
          SizedBox(height: 30.h),
          _buildHostSection(),
          SizedBox(height: 30.h),
          _buildAmenitiesSection(),
          SizedBox(height: 30.h),
          _buildDescriptionSection(),
          SizedBox(height: 100.h), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildPropertyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.property.title,
                style: AppTheme.heading1.copyWith(
                  color: AppTheme.darkGray,
                ),
              ),
            ),
            Text(
              '\$${widget.property.price.toStringAsFixed(0)}/night',
              style: AppTheme.heading2.copyWith(
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.3, duration: 600.ms),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: AppTheme.mediumGray,
              size: 18.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              widget.property.location,
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.mediumGray,
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: 200.ms),
        SizedBox(height: 16.h),
        Row(
          children: [
            RatingBar.builder(
              initialRating: widget.property.rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 20.sp,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {},
              ignoreGestures: true,
            ),
            SizedBox(width: 8.w),
            Text(
              '${widget.property.rating}',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.darkGray,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '(${widget.property.reviewCount} reviews)',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.mediumGray,
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 400.ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: 400.ms),
        SizedBox(height: 20.h),
        Row(
          children: [
            _buildInfoChip(
              icon: Icons.bed,
              text: '${widget.property.bedrooms} bedrooms',
            ),
            SizedBox(width: 12.w),
            _buildInfoChip(
              icon: Icons.bathtub_outlined,
              text: '${widget.property.bathrooms} bathrooms',
            ),
            SizedBox(width: 12.w),
            _buildInfoChip(
              icon: Icons.people_outline,
              text: '${widget.property.guests} guests',
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 600.ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: 600.ms),
      ],
    );
  }

  Widget _buildHostSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundImage: NetworkImage(widget.property.hostAvatar),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hosted by ${widget.property.hostName}',
                  style: AppTheme.heading3.copyWith(
                    color: AppTheme.darkGray,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Superhost • 5 years hosting',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Contact',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 800.ms)
        .slideY(begin: 0.3, duration: 600.ms, delay: 800.ms);
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What this place offers',
          style: AppTheme.heading2.copyWith(
            color: AppTheme.darkGray,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 1000.ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: 1000.ms),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: widget.property.amenities.map((amenity) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppTheme.mediumGray.withOpacity(0.3),
                ),
              ),
              child: Text(
                amenity,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 1200.ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: 1200.ms),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this place',
          style: AppTheme.heading2.copyWith(
            color: AppTheme.darkGray,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 1400.ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: 1400.ms),
        SizedBox(height: 16.h),
        Text(
          widget.property.description,
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.darkGray,
            height: 1.6,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 1600.ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: 1600.ms),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.mediumGray,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text(
                  'Contact Seller',
                  style: AppTheme.button.copyWith(
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.message_outlined,
                color: AppTheme.primaryTeal,
                size: 24.sp,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 1800.ms)
        .slideY(begin: 0.3, duration: 600.ms, delay: 1800.ms);
  }
}
