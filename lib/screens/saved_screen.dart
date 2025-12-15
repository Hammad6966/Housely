import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';
import '../data/sample_data.dart';
import '../models/property.dart';
import '../widgets/property_card.dart';
import 'property_details_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'House',
    'Apartment',
    'Cabin',
    'Villa',
    'Cottage',
    'Studio'
  ];

  List<Property> get _savedProperties {
    // For demo purposes, we'll show all properties as "saved"
    // In a real app, this would come from a saved properties list
    return SampleData.properties;
  }

  List<Property> get _filteredProperties {
    if (_selectedFilter == 'All') {
      return _savedProperties;
    }
    return _savedProperties
        .where((property) =>
            property.propertyType.toLowerCase() ==
            _selectedFilter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            Expanded(
              child: _buildSavedPropertiesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Saved Places',
                style: AppTheme.heading2.copyWith(
                  color: AppTheme.darkGray,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideX(begin: -0.3, duration: 600.ms),
              Text(
                '${_savedProperties.length} properties saved',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.mediumGray,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideX(begin: -0.3, duration: 600.ms, delay: 200.ms),
            ],
          ),
          const Spacer(),
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal,
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryTeal.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.search,
              color: AppTheme.white,
              size: 24.sp,
            ),
          )
              .animate()
              .scale(duration: 600.ms, delay: 400.ms)
              .fadeIn(duration: 600.ms, delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(bottom: 20.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Container(
            margin: EdgeInsets.only(right: 12.w),
            child: FilterChip(
              label: Text(
                filter,
                style: AppTheme.bodyMedium.copyWith(
                  color: isSelected ? AppTheme.white : AppTheme.mediumGray,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: AppTheme.white,
              selectedColor: AppTheme.primaryTeal,
              checkmarkColor: AppTheme.white,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.primaryTeal
                    : AppTheme.mediumGray.withOpacity(0.3),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: (index * 100).ms)
              .slideX(begin: 0.3, duration: 400.ms, delay: (index * 100).ms);
        },
      ),
    );
  }

  Widget _buildSavedPropertiesList() {
    final properties = _filteredProperties;

    if (properties.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];

        return PropertyCard(
          property: property,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    PropertyDetailsScreen(property: property),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.easeInOut)),
                    ),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: (index * 100).ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: (index * 100).ms);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60.r),
            ),
            child: Icon(
              Icons.favorite_border,
              size: 60.sp,
              color: AppTheme.primaryTeal,
            ),
          ).animate().scale(duration: 800.ms).fadeIn(duration: 800.ms),
          SizedBox(height: 24.h),
          Text(
            'No saved properties yet',
            style: AppTheme.heading2.copyWith(
              color: AppTheme.darkGray,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 300.ms)
              .slideY(begin: 0.3, duration: 600.ms, delay: 300.ms),
          SizedBox(height: 8.h),
          Text(
            'Start exploring and save your favorite places',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.mediumGray,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 500.ms)
              .slideY(begin: 0.3, duration: 600.ms, delay: 500.ms),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () {
              // Navigate to home screen
              // This would typically be handled by the parent navigation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
            ),
            child: Text(
              'Explore Properties',
              style: AppTheme.button,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 700.ms)
              .slideY(begin: 0.3, duration: 600.ms, delay: 700.ms),
        ],
      ),
    );
  }
}
