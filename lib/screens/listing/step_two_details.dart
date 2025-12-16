import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_theme.dart';

class StepTwoDetails extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController bedsController;
  final TextEditingController bathsController;
  final TextEditingController sqftController;
  final Set<String> selectedAmenities;
  final Function(String) onAmenityToggle;

  const StepTwoDetails({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.priceController,
    required this.bedsController,
    required this.bathsController,
    required this.sqftController,
    required this.selectedAmenities,
    required this.onAmenityToggle,
  });

  final List<String> _amenities = const [
    'Wifi',
    'Kitchen',
    'Pool',
    'Gym',
    'Parking',
    'Air Conditioning',
    'Heating',
    'Washer/Dryer'
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property Details',
            style: AppTheme.heading2,
          ),
          SizedBox(height: 20.h),
          _buildInput('Property Title *', titleController, TextInputType.text, 
              hintText: 'e.g., Modern Downtown Apartment'),
          SizedBox(height: 16.h),
          _buildInput('Description', descriptionController, TextInputType.multiline, 
              hintText: 'Describe your property...', maxLines: 3),
          SizedBox(height: 16.h),
          _buildInput('Price (per month/total) *', priceController, TextInputType.number, 
              hintText: '0', prefixText: '\$ '),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildInput('Beds', bedsController, TextInputType.number)),
              SizedBox(width: 16.w),
              Expanded(child: _buildInput('Baths', bathsController, TextInputType.number)),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInput('Sq. Ft.', sqftController, TextInputType.number),
          SizedBox(height: 24.h),
          Text(
            'Amenities',
            style: AppTheme.heading3,
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: _amenities.map((amenity) {
              final isSelected = selectedAmenities.contains(amenity);
              return FilterChip(
                label: Text(amenity),
                selected: isSelected,
                onSelected: (_) => onAmenityToggle(amenity),
                backgroundColor: AppTheme.white,
                selectedColor: AppTheme.primaryTeal,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.white : AppTheme.darkGray,
                ),
                checkmarkColor: AppTheme.white,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, TextInputType type, 
      {String? hintText, int maxLines = 1, String? prefixText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.bodyMedium),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText ?? '0',
            prefixText: prefixText,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }
}
