import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_theme.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';
import 'listing_type_step.dart';
import 'step_two_details.dart';
import 'step_three_location.dart';

class ListingWizardScreen extends StatefulWidget {
  const ListingWizardScreen({super.key});

  @override
  State<ListingWizardScreen> createState() => _ListingWizardScreenState();
}

class _ListingWizardScreenState extends State<ListingWizardScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  final PropertyService _propertyService = PropertyService();

  // Step 1 Data
  String _selectedType = 'For Rent';
  String _selectedPropertyType = 'House';

  // Step 2 Data
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _bedsController = TextEditingController();
  final TextEditingController _bathsController = TextEditingController();
  final TextEditingController _sqftController = TextEditingController();
  final Set<String> _selectedAmenities = {};

  // Step 3 Data
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();
    _sqftController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _publishListing() async {
    // Validate required fields
    if (_titleController.text.trim().isEmpty) {
      _showError('Please enter a title for your property');
      return;
    }
    if (_priceController.text.trim().isEmpty) {
      _showError('Please enter a price');
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      _showError('Please enter an address');
      return;
    }

    setState(() => _isLoading = true);

    final property = Property(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? 'Beautiful ${_selectedPropertyType.toLowerCase()} available ${_selectedType.toLowerCase()}'
          : _descriptionController.text.trim(),
      location: _addressController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      images: ['assets/images/properties/property_1.jpg'], // Default image
      hostName: '',
      hostAvatar: '',
      amenities: _selectedAmenities.toList(),
      bedrooms: int.tryParse(_bedsController.text.trim()) ?? 0,
      bathrooms: int.tryParse(_bathsController.text.trim()) ?? 0,
      propertyType: _selectedPropertyType,
      listingType: _selectedType,
      sqft: int.tryParse(_sqftController.text.trim()) ?? 0,
    );

    final result = await _propertyService.addProperty(property);

    setState(() => _isLoading = false);

    if (result.success) {
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Listing published successfully!'),
            backgroundColor: AppTheme.primaryTeal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } else {
      _showError(result.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      _publishListing();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text('New Listing', style: AppTheme.heading3),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.darkGray),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.h),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: AppTheme.lightGray,
            color: AppTheme.primaryTeal,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: IndexedStack(
          index: _currentStep,
          children: [
            ListingTypeStep(
              selectedType: _selectedType,
              selectedPropertyType: _selectedPropertyType,
              onTypeSelected: (type) => setState(() => _selectedType = type),
              onPropertyTypeSelected: (type) =>
                  setState(() => _selectedPropertyType = type),
            ),
            StepTwoDetails(
              titleController: _titleController,
              descriptionController: _descriptionController,
              priceController: _priceController,
              bedsController: _bedsController,
              bathsController: _bathsController,
              sqftController: _sqftController,
              selectedAmenities: _selectedAmenities,
              onAmenityToggle: (amenity) {
                setState(() {
                  if (_selectedAmenities.contains(amenity)) {
                    _selectedAmenities.remove(amenity);
                  } else {
                    _selectedAmenities.add(amenity);
                  }
                });
              },
            ),
            StepThreeLocation(
              addressController: _addressController,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkGray.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _previousStep,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      side: const BorderSide(color: AppTheme.primaryTeal),
                    ),
                    child: Text(
                      'Back',
                      style: AppTheme.button.copyWith(
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ),
                ),
              if (_currentStep > 0) SizedBox(width: 16.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _currentStep == 2 ? 'Publish Listing' : 'Next',
                          style: AppTheme.button,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
