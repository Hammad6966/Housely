import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_theme.dart';

class StepThreeLocation extends StatelessWidget {
  final TextEditingController addressController;

  const StepThreeLocation({
    super.key,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location & Photos',
            style: AppTheme.heading2,
          ),
          SizedBox(height: 20.h),
          Text('Street Address', style: AppTheme.bodyMedium),
          SizedBox(height: 8.h),
          TextField(
            controller: addressController,
            decoration: InputDecoration(
              hintText: '123 Main St, City, State',
              prefixIcon: const Icon(Icons.location_on_outlined),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
          SizedBox(height: 24.h),
          Text('Photos', style: AppTheme.heading3),
          SizedBox(height: 12.h),
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppTheme.mediumGray.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48.sp,
                  color: AppTheme.primaryTeal,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Tap to upload images',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
