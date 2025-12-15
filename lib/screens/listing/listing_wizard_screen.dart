import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_theme.dart';
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
  
  // Step 1 Data
  String _selectedType = 'For Rent';

  // Step 2 Data
  final TextEditingController _bedsController = TextEditingController();
  final TextEditingController _bathsController = TextEditingController();
  final TextEditingController _sqftController = TextEditingController();
  final Set<String> _selectedAmenities = {};

  // Step 3 Data
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _bedsController.dispose();
    _bathsController.dispose();
    _sqftController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Finish Wizard
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing Created Successfully!')),
      );
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
              onTypeSelected: (type) => setState(() => _selectedType = type),
            ),
            StepTwoDetails(
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
              color: AppTheme.darkGray.withOpacity(0.05),
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
                    onPressed: _previousStep,
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
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(
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
