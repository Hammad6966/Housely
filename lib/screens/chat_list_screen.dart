import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text('Messages', style: AppTheme.heading3),
        backgroundColor: AppTheme.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: 5, // Mock data count
        separatorBuilder: (context, index) => Divider(
          color: AppTheme.lightGray,
          indent: 20.w,
          endIndent: 20.w,
        ),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            leading: CircleAvatar(
              radius: 28.r,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=$index'),
            ),
            title: Text(
              'Host User ${index + 1}',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
            subtitle: Text(
              'Hey, is the apartment available for next week?',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.bodyMedium,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '10:3${index} AM',
                  style: AppTheme.caption,
                ),
                SizedBox(height: 4.h),
                if (index < 2)
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '2',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.white,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          );
        },
      ),
    );
  }
}
