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

    return Scaffold(
      body: profileController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildCoverImage(),
                    title: Text(user.name),
                    centerTitle: true,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildProfileHeader(context, user, profileController),
                      const SizedBox(height: 20),
                      ProfileStats(
                        scannedLinks: user.scannedLinks,
                        detectedThreats: user.detectedThreats,
                        accuracyRate: user.accuracyRate,
                      ),
                      const SizedBox(height: 20),
                      _buildProfileOptions(context, authController, profileController),
                      if (profileController.error != null)
                        _buildErrorWidget(profileController),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCoverImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A4779),
            Color(0xFF4D82B8),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user, ProfileController profileController) {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showImageOptions(context, profileController),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _getProfileImage(user),
                    backgroundColor: Colors.grey.shade200,
                    child: _isLoadingImage
                        ? const CircularProgressIndicator()
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0A4779),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.email,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (user.isEmailVerified)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.verified,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'منضم منذ ${_formatJoinDate(user.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
              ),
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
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            icon: Icons.edit,
            iconColor: Colors.blue,
            title: 'تعديل الملف الشخصي',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          _buildOptionTile(
            icon: Icons.security,
            iconColor: Colors.green,
            title: 'الأمان والخصوصية',
            onTap: () {},
          ),
          _buildOptionTile(
            icon: Icons.notifications,
            iconColor: Colors.orange,
            title: 'الإشعارات',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: const Color(0xFF0A4779),
            ),
          ),
          _buildOptionTile(
            icon: Icons.language,
            iconColor: Colors.purple,
            title: 'اللغة',
            trailing: const Text('العربية'),
            onTap: () {},
          ),
          _buildOptionTile(
            icon: Icons.help_outline,
            iconColor: Colors.teal,
            title: 'المساعدة والدعم',
            onTap: () {},
          ),
          _buildOptionTile(
            icon: Icons.logout,
            iconColor: Colors.red,
            title: 'تسجيل الخروج',
            titleColor: Colors.red,
            onTap: () => _showLogoutDialog(context, authController),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
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
          color: titleColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildErrorWidget(ProfileController profileController) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              profileController.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
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

  void _showImageOptions(BuildContext context, ProfileController profileController) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'تغيير الصورة الشخصية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library, color: Colors.blue),
              ),
              title: const Text('اختر من المعرض'),
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
                child: const Icon(Icons.camera_alt, color: Colors.orange),
              ),
              title: const Text('التقاط صورة'),
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
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: const Text(
                  'حذف الصورة',
                  style: TextStyle(color: Colors.red),
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

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authController.logout();
              if (mounted) {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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