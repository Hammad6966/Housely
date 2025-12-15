import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';
import 'main_navigation.dart';
import 'auth/login_screen.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // Wait for animations and initialization
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // Check auth status
    final isLoggedIn = await AuthService().checkAuthStatus();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainNavigation(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryTeal,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryTeal,
              AppTheme.lightTeal,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with animation
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.darkGray.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.r),
                  child: Image.asset(
                    'assets/images/ui/logo.png',
                    width: 120.w,
                    height: 120.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading logo: $error');
                      return Icon(
                        Icons.home,
                        size: 60.sp,
                        color: AppTheme.primaryTeal,
                      );
                    },
                  ),
                ),
              )
                  .animate()
                  .scale(
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .shimmer(
                    duration: 1000.ms,
                    color: AppTheme.lightTeal.withOpacity(0.3),
                  ),

              SizedBox(height: 40.h),

              // App name with animation
              Text(
                'Housely',
                style: AppTheme.heading1.copyWith(
                  color: AppTheme.white,
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate()
                  .fadeIn(
                    duration: 1000.ms,
                    delay: 500.ms,
                  )
                  .slideY(
                    begin: 0.3,
                    duration: 800.ms,
                    delay: 500.ms,
                    curve: Curves.easeOut,
                  ),

              SizedBox(height: 16.h),

              // Tagline with animation
              Text(
                'Find Your Perfect Home',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.white.withOpacity(0.9),
                  fontSize: 18.sp,
                ),
              )
                  .animate()
                  .fadeIn(
                    duration: 1000.ms,
                    delay: 1000.ms,
                  )
                  .slideY(
                    begin: 0.3,
                    duration: 800.ms,
                    delay: 1000.ms,
                    curve: Curves.easeOut,
                  ),

              SizedBox(height: 60.h),

              // Loading indicator with animation
              SizedBox(
                width: 40.w,
                height: 40.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.white.withOpacity(0.8),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(
                    duration: 500.ms,
                    delay: 1500.ms,
                  )
                  .scale(
                    duration: 1000.ms,
                    delay: 1500.ms,
                    curve: Curves.elasticOut,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
