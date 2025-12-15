import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_theme.dart';

class ListingTypeStep extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeSelected;

  const ListingTypeStep({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What kind of property?',
          style: AppTheme.heading2,
        ),
        SizedBox(height: 20.h),
        _buildTypeOption(
          'For Rent',
          Icons.key,
          selectedType == 'For Rent',
        ),
        SizedBox(height: 16.h),
        _buildTypeOption(
          'For Sale',
          Icons.sell,
          selectedType == 'For Sale',
        ),
      ],
    );
  }

  Widget _buildTypeOption(String title, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => onTypeSelected(title),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal.withOpacity(0.1) : AppTheme.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.mediumGray.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryTeal : AppTheme.mediumGray,
              size: 28.sp,
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: AppTheme.bodyLarge.copyWith(
                color: isSelected ? AppTheme.primaryTeal : AppTheme.darkGray,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryTeal,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }
}
