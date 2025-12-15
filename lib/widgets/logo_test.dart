import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';

class LogoTest extends StatelessWidget {
  const LogoTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Logo Test',
              style: AppTheme.heading1,
            ),
            SizedBox(height: 40.h),
            // Test logo loading
            Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkGray.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.asset(
                  'assets/images/ui/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Logo error: $error');
                    return Container(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error,
                            size: 50.sp,
                            color: AppTheme.accent,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Logo Error',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.accent,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            error.toString(),
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.mediumGray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'If you see an error above, the logo file is not loading properly.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
