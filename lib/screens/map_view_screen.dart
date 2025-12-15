import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map View', style: AppTheme.heading3),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkGray),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.mediumGray.withOpacity(0.3)),
          ),
          child: Text(
            'Interactive Google Map Placeholder',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.mediumGray,
            ),
          ),
        ),
      ),
    );
  }
}
