import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/profile_stats.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoadingImage = false;

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final profileController = context.watch<ProfileController>();
    final user = profileController.user;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: profileController.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDarkMode ? Colors.orange.shade300 : const Color(0xFF0A4779),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header مع خلفية متدرجة
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 70),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDarkMode
                            ? [
                                const Color(0xFF1A1A2E),
                                const Color(0xFF16213E),
                              ]
                            : [
                                const Color(0xFF0A4779),
                                const Color(0xFF4D82B8),
                              ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode 
                              ? Colors.black.withOpacity(0.3) 
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // صورة المستخدم
                        _buildProfileImage(user, profileController, isDarkMode),
                        const SizedBox(height: 15),
                        // اسم المستخدم
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // البريد الإلكتروني
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            if (user.isEmailVerified)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // تاريخ الانضمام
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'منضم منذ ${_formatJoinDate(user.createdAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // المحتوى الرئيسي (يظهر فوق الخلفية)
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // الإحصائيات
                          ProfileStats(
                            scannedLinks: user.scannedLinks,
                            detectedThreats: user.detectedThreats,
                            accuracyRate: user.accuracyRate,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // خيارات الملف الشخصي
                          _buildProfileOptions(context, authController, profileController, isDarkMode),
                          
                          if (profileController.error != null)
                            _buildErrorWidget(profileController, isDarkMode),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileImage(user, ProfileController profileController, bool isDarkMode) {
    return GestureDetector(
      onTap: () => _showImageOptions(context, profileController, isDarkMode),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // الصورة مع حدود
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: _getProfileImage(user),
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              child: _isLoadingImage
                  ? CircularProgressIndicator(
                      color: isDarkMode ? Colors.orange.shade300 : Colors.white,
                    )
                  : null,
            ),
          ),
          // أيقونة الكاميرا
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.orange.shade700 : const Color(0xFF0A4779),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(
    BuildContext context,
    AuthController authController,
    ProfileController profileController,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A3A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            icon: Icons.edit,
            iconColor: isDarkMode ? Colors.blue.shade300 : Colors.blue,
            title: 'تعديل الملف الشخصي',
            titleColor: isDarkMode ? Colors.white : Colors.black87,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            isDarkMode: isDarkMode,
          ),
          _buildDivider(isDarkMode),
          _buildOptionTile(
            icon: Icons.security,
            iconColor: isDarkMode ? Colors.green.shade300 : Colors.green,
            title: 'الأمان والخصوصية',
            titleColor: isDarkMode ? Colors.white : Colors.black87,
            onTap: () {},
            isDarkMode: isDarkMode,
          ),
          _buildDivider(isDarkMode),
          _buildOptionTile(
            icon: Icons.notifications,
            iconColor: isDarkMode ? Colors.orange.shade300 : Colors.orange,
            title: 'الإشعارات',
            titleColor: isDarkMode ? Colors.white : Colors.black87,
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: isDarkMode ? Colors.orange.shade300 : const Color(0xFF0A4779),
              activeTrackColor: isDarkMode ? Colors.orange.shade700 : const Color(0xFF4D82B8),
            ),
            isDarkMode: isDarkMode,
          ),
          _buildDivider(isDarkMode),
          _buildOptionTile(
            icon: Icons.language,
            iconColor: isDarkMode ? Colors.purple.shade300 : Colors.purple,
            title: 'اللغة',
            titleColor: isDarkMode ? Colors.white : Colors.black87,
            trailing: Text(
              'العربية',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            onTap: () {},
            isDarkMode: isDarkMode,
          ),
          _buildDivider(isDarkMode),
          _buildOptionTile(
            icon: Icons.help_outline,
            iconColor: isDarkMode ? Colors.teal.shade300 : Colors.teal,
            title: 'المساعدة والدعم',
            titleColor: isDarkMode ? Colors.white : Colors.black87,
            onTap: () {},
            isDarkMode: isDarkMode,
          ),
          _buildDivider(isDarkMode),
          _buildOptionTile(
            icon: Icons.logout,
            iconColor: isDarkMode ? Colors.red.shade300 : Colors.red,
            title: 'تسجيل الخروج',
            titleColor: isDarkMode ? Colors.red.shade300 : Colors.red,
            onTap: () => _showLogoutDialog(context, authController, isDarkMode),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      endIndent: 16,
      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? (isDarkMode ? Colors.white : Colors.black87),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? Icon(
        Icons.arrow_forward_ios, 
        size: 16,
        color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
      ),
      onTap: onTap,
    );
  }

  Widget _buildErrorWidget(ProfileController profileController, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.red.shade900.withOpacity(0.2) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.red.shade700.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: isDarkMode ? Colors.red.shade300 : Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              profileController.error!,
              style: TextStyle(
                color: isDarkMode ? Colors.red.shade300 : Colors.red,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 20,
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
            onPressed: profileController.clearError,
          ),
        ],
      ),
    );
  }

  ImageProvider _getProfileImage(user) {
    if (user.profileImage != null && user.profileImage!.isNotEmpty) {
      try {
        return FileImage(File(user.profileImage!));
      } catch (e) {
        return const AssetImage('assets/images/default_profile.png');
      }
    }
    return const AssetImage('assets/images/default_profile.png');
  }

  void _showImageOptions(BuildContext context, ProfileController profileController, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF2A2A3A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تغيير الصورة الشخصية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_library,
                  color: isDarkMode ? Colors.blue.shade300 : Colors.blue,
                ),
              ),
              title: Text(
                'اختر من المعرض',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                setState(() => _isLoadingImage = true);
                final image = await profileController.pickImageFromGallery();
                setState(() => _isLoadingImage = false);
                
                if (image != null && mounted) {
                  await profileController.updateProfileImage(image);
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: isDarkMode ? Colors.orange.shade300 : Colors.orange,
                ),
              ),
              title: Text(
                'التقاط صورة',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                setState(() => _isLoadingImage = true);
                final image = await profileController.takePhoto();
                setState(() => _isLoadingImage = false);
                
                if (image != null && mounted) {
                  await profileController.updateProfileImage(image);
                }
              },
            ),
            const SizedBox(height: 10),
            if (profileController.user.profileImage != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete,
                    color: isDarkMode ? Colors.red.shade300 : Colors.red,
                  ),
                ),
                title: Text(
                  'حذف الصورة',
                  style: TextStyle(
                    color: isDarkMode ? Colors.red.shade300 : Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // حذف الصورة
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A2A3A) : Colors.white,
        title: Text(
          'تسجيل الخروج',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await authController.logout();
              if (mounted) {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.red.shade800 : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'اليوم';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} يوم';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months شهر';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years سنة';
    }
  }
}