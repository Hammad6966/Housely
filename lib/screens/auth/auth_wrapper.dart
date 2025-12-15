import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import '../main_navigation.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.checkAuthStatus();
      if (mounted) {
        setState(() {
          _isAuthenticated = isLoggedIn;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_isAuthenticated) {
      return const MainNavigation();
    } else {
      return const LoginScreen();
    }
  }

  Widget _buildLoadingScreen() {
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
                child: Icon(
                  Icons.home,
                  size: 60.sp,
                  color: AppTheme.primaryTeal,
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

              // Loading text with animation
              Text(
                'Checking authentication...',
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
