import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';
import '../widgets/property_card.dart';
import '../data/sample_data.dart';
import '../models/property.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  String _selectedType = 'For Rent'; // 'For Rent' or 'For Sale'

  List<Property> get _myProperties {
    // Mocking user properties by filtering sample data for now
    // In a real app, this would match some user ID
    // We'll just assume half are "For Rent" and half "For Sale" based on existing types
    // or just show matching types from SampleData
    return SampleData.properties
        .where((p) =>
            (p.propertyType == 'Apartment' && _selectedType == 'For Rent') ||
            (p.propertyType == 'House' && _selectedType == 'For Sale'))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text('My Listings', style: AppTheme.heading3),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkGray),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildFilterToggle(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(20.w),
              itemCount: _myProperties.length,
              itemBuilder: (context, index) {
                final property = _myProperties[index];
                return Column(
                  children: [
                    PropertyCard(
                      property: property,
                      onTap: () {
                        // Navigate to details if needed, or edit
                      },
                    ),
                    _buildActionButtons(),
                    SizedBox(height: 20.h),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.mediumGray.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _buildToggleButton('For Rent', _selectedType == 'For Rent'),
          _buildToggleButton('For Sale', _selectedType == 'For Sale'),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = text;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              color: isSelected ? AppTheme.white : AppTheme.mediumGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: EdgeInsets.only(top: -10.h), // Pull up closer to card
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGray.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.edit, size: 18.sp),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryTeal,
                side: const BorderSide(color: AppTheme.primaryTeal),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.delete_outline, size: 18.sp),
              label: const Text('Unlist'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accent,
                side: const BorderSide(color: AppTheme.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
