import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  RangeValues _currentPriceRange = const RangeValues(100000, 500000);
  String _selectedPropertyType = 'House';
  final List<String> _propertyTypes = ['House', 'Apartment', 'Condo', 'Townhouse'];
  
  final List<String> _amenities = [
    'Wifi',
    'Kitchen',
    'Pool',
    'Gym',
    'Parking',
    'Air Conditioning',
    'Heating',
    'Washer/Dryer'
  ];
  final Set<String> _selectedAmenities = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text('Filters', style: AppTheme.heading3),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.darkGray),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Price Range'),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${_currentPriceRange.start.round()}', style: AppTheme.bodyMedium),
                Text('\$${_currentPriceRange.end.round()}', style: AppTheme.bodyMedium),
              ],
            ),
            RangeSlider(
              values: _currentPriceRange,
              min: 0,
              max: 1000000,
              divisions: 20,
              activeColor: AppTheme.primaryTeal,
              inactiveColor: AppTheme.mediumGray.withOpacity(0.3),
              labels: RangeLabels(
                '\$${_currentPriceRange.start.round()}',
                '\$${_currentPriceRange.end.round()}',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentPriceRange = values;
                });
              },
            ),
            SizedBox(height: 24.h),
            
            _buildSectionTitle('Property Type'),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: _propertyTypes.map((type) {
                final isSelected = _selectedPropertyType == type;
                return ChoiceChip(
                  label: Text(
                    type,
                    style: TextStyle(
                      color: isSelected ? AppTheme.white : AppTheme.darkGray,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPropertyType = type;
                      });
                    }
                  },
                  selectedColor: AppTheme.primaryTeal,
                  backgroundColor: AppTheme.white,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : AppTheme.mediumGray.withOpacity(0.3),
                    )
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24.h),

            _buildSectionTitle('Amenities'),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: _amenities.map((amenity) {
                final isSelected = _selectedAmenities.contains(amenity);
                return FilterChip(
                  label: Text(
                    amenity,
                    style: TextStyle(
                      color: isSelected ? AppTheme.white : AppTheme.darkGray,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAmenities.add(amenity);
                      } else {
                        _selectedAmenities.remove(amenity);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryTeal,
                  backgroundColor: AppTheme.white,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  checkmarkColor: AppTheme.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : AppTheme.mediumGray.withOpacity(0.3),
                      )
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 100.h), // Bottom padding for FAB
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50.h),
              backgroundColor: AppTheme.primaryTeal,
            ),
            child: Text(
              'Apply Filters',
              style: AppTheme.button,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.heading3.copyWith(fontSize: 18.sp),
    );
  }
}
