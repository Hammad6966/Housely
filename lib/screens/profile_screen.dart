import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'auth/login_screen.dart';
import 'settings_screen.dart';
import 'my_listings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImage = false;

  Future<void> _pickAndUploadImage() async {
    try {
      // Show bottom sheet to choose camera or gallery
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.mediumGray,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Choose Profile Photo',
                style: AppTheme.heading3,
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.camera_alt, color: AppTheme.primaryTeal),
                ),
                title: Text('Take a Photo', style: AppTheme.bodyLarge),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.photo_library, color: AppTheme.primaryTeal),
                ),
                title: Text('Choose from Gallery', style: AppTheme.bodyLarge),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      );

      if (source == null) return;

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      final result = await _authService.uploadProfileImage(File(pickedFile.path));

      setState(() => _isUploadingImage = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? AppTheme.primaryTeal : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
        if (result.success) {
          setState(() {}); // Refresh UI
        }
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildProfileInfo(user),
              _buildStatsSection(),
              _buildMenuSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
      child: Row(
        children: [
          Text(
            'Profile',
            style: AppTheme.heading2.copyWith(
              color: AppTheme.darkGray,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.3, duration: 600.ms),
          const Spacer(),
          GestureDetector(
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            child: Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkGray.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.settings_outlined,
                color: AppTheme.primaryTeal,
                size: 24.sp,
              ),
            ),
          )
              .animate()
              .scale(duration: 600.ms, delay: 200.ms)
              .fadeIn(duration: 600.ms, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(User? user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGray.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isUploadingImage ? null : _pickAndUploadImage,
            child: Stack(
              children: [
                _isUploadingImage
                    ? Container(
                        width: 100.r,
                        height: 100.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.lightGray,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryTeal,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 50.r,
                        backgroundColor: AppTheme.lightGray,
                        backgroundImage: user?.profileImage != null && user!.profileImage!.isNotEmpty
                            ? NetworkImage(user.profileImage!)
                            : null,
                        child: user?.profileImage == null || user!.profileImage!.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 50.sp,
                                color: AppTheme.mediumGray,
                              )
                            : null,
                      ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal,
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(
                        color: AppTheme.white,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: AppTheme.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .scale(duration: 800.ms, delay: 300.ms)
              .fadeIn(duration: 800.ms, delay: 300.ms),
          SizedBox(height: 16.h),
          Text(
            user?.fullName ?? 'User',
            style: AppTheme.heading2.copyWith(
              color: AppTheme.darkGray,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 500.ms)
              .slideY(begin: 0.3, duration: 600.ms, delay: 500.ms),
          SizedBox(height: 4.h),
          Text(
            user?.email ?? 'user@example.com',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.mediumGray,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 700.ms)
              .slideY(begin: 0.3, duration: 600.ms, delay: 700.ms),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Verified Host',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 900.ms)
              .slideY(begin: 0.3, duration: 600.ms, delay: 900.ms),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGray.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              title: 'Trips',
              value: '12',
              icon: Icons.flight_takeoff,
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: AppTheme.lightGray,
          ),
          Expanded(
            child: _buildStatItem(
              title: 'Saved',
              value: '8',
              icon: Icons.favorite,
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: AppTheme.lightGray,
          ),
          Expanded(
            child: _buildStatItem(
              title: 'Reviews',
              value: '24',
              icon: Icons.star,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 1100.ms)
        .slideY(begin: 0.3, duration: 600.ms, delay: 1100.ms);
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryTeal,
          size: 24.sp,
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: AppTheme.heading3.copyWith(
            color: AppTheme.darkGray,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.mediumGray,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGray.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Personal Information',
            subtitle: 'Update your personal details',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.list_alt,
            title: 'My Listings',
            subtitle: 'Manage your property listings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyListingsScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            subtitle: 'Manage your payment options',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage your notification preferences',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.security_outlined,
            title: 'Privacy & Security',
            subtitle: 'Control your privacy settings',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: _handleLogout,
            isDestructive: true,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 1300.ms)
        .slideY(begin: 0.3, duration: 600.ms, delay: 1300.ms);
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: isDestructive
              ? AppTheme.accent.withOpacity(0.1)
              : AppTheme.primaryTeal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppTheme.accent : AppTheme.primaryTeal,
          size: 20.sp,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.bodyLarge.copyWith(
          color: isDestructive ? AppTheme.accent : AppTheme.darkGray,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(
          color: AppTheme.mediumGray,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppTheme.mediumGray,
        size: 16.sp,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      height: 1,
      color: AppTheme.lightGray,
    );
  }
}
