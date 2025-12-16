import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_theme.dart';

class ListingTypeStep extends StatelessWidget {
  final String selectedType;
  final String selectedPropertyType;
  final Function(String) onTypeSelected;
  final Function(String) onPropertyTypeSelected;

  const ListingTypeStep({
    super.key,
    required this.selectedType,
    required this.selectedPropertyType,
    required this.onTypeSelected,
    required this.onPropertyTypeSelected,
  });

  final List<String> _propertyTypes = const [
    'House',
    'Apartment',
    'Villa',
    'Cabin',
    'Cottage',
    'Studio',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What kind of listing?',
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
          SizedBox(height: 32.h),
          Text(
            'Property Type',
            style: AppTheme.heading2,
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: _propertyTypes.map((type) {
              final isSelected = selectedPropertyType == type;
              return GestureDetector(
                onTap: () => onPropertyTypeSelected(type),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryTeal : AppTheme.white,
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryTeal : AppTheme.mediumGray.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    type,
                    style: AppTheme.bodyMedium.copyWith(
                      color: isSelected ? AppTheme.white : AppTheme.darkGray,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String title, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => onTypeSelected(title),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal.withValues(alpha: 0.1) : AppTheme.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.mediumGray.withValues(alpha: 0.3),
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
