import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _profileImage;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final profileController = context.read<ProfileController>();
    final user = profileController.user;

    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: '');

    _nameController.addListener(_onTextChanged);
    _emailController.addListener(_onTextChanged);
    _phoneController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final profileController = context.read<ProfileController>();
    final user = profileController.user;

    final nameChanged = _nameController.text != user.name;
    final emailChanged = _emailController.text != user.email;

    if (_hasChanges != (nameChanged || emailChanged)) {
      setState(() {
        _hasChanges = nameChanged || emailChanged;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
        centerTitle: true,
        backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFF0A4779),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showExitDialog(context, isDarkMode),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : () => _saveProfile(profileController),
              child: Text(
                'حفظ',
                style: TextStyle(
                  color: _isLoading 
                      ? Colors.white.withOpacity(0.5) 
                      : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDarkMode ? Colors.orange.shade300 : const Color(0xFF0A4779),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF121212) : Colors.grey.shade50,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileImage(profileController, isDarkMode),
                    const SizedBox(height: 30),
                    _buildForm(isDarkMode),
                    const SizedBox(height: 30),
                    _buildSaveButton(profileController, isDarkMode),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileImage(ProfileController profileController, bool isDarkMode) {
    return GestureDetector(
      onTap: () => _showImageOptions(context, profileController, isDarkMode),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDarkMode ? Colors.orange.shade300 : const Color(0xFF0A4779), 
                width: 3
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
            child: CircleAvatar(
              radius: 70,
              backgroundImage: _getProfileImage(profileController.user, isDarkMode),
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              child: _profileImage == null && profileController.user.profileImage == null
                  ? Icon(
                      Icons.person,
                      size: 50,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    )
                  : null,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.orange.shade700 : const Color(0xFF0A4779),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDarkMode ? Colors.orange.shade300 : Colors.white,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.edit,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المعلومات الشخصية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.orange.shade300 : const Color(0xFF0A4779),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _nameController,
            label: 'الاسم الكامل',
            icon: Icons.person,
            isDarkMode: isDarkMode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الاسم مطلوب';
              }
              if (value.length < 3) {
                return 'الاسم قصير جداً';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _emailController,
            label: 'البريد الإلكتروني',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            isDarkMode: isDarkMode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'البريد الإلكتروني مطلوب';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'البريد الإلكتروني غير صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _phoneController,
            label: 'رقم الهاتف (اختياري)',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required bool isDarkMode,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        prefixIcon: Icon(
          icon, 
          color: isDarkMode ? Colors.orange.shade300 : const Color(0xFF0A4779)
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.orange.shade300 : const Color(0xFF0A4779), 
            width: 2
          ),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
        errorStyle: TextStyle(
          color: isDarkMode ? Colors.red.shade300 : Colors.red,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildSaveButton(ProfileController profileController, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _hasChanges && !_isLoading
            ? () => _saveProfile(profileController)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.orange.shade700 : const Color(0xFF0A4779),
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDarkMode 
              ? Colors.grey.shade700.withOpacity(0.5)
              : Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: const Text(
          'حفظ التغييرات',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  ImageProvider _getProfileImage(user, bool isDarkMode) {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    }
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
                final image = await profileController.pickImageFromGallery();
                if (image != null && mounted) {
                  setState(() {
                    _profileImage = image;
                    _hasChanges = true;
                  });
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
                final image = await profileController.takePhoto();
                if (image != null && mounted) {
                  setState(() {
                    _profileImage = image;
                    _hasChanges = true;
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            if (_profileImage != null || profileController.user.profileImage != null)
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
                  setState(() {
                    _profileImage = null;
                    _hasChanges = true;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile(ProfileController profileController) async {
    setState(() => _isLoading = true);

    bool success = true;
    String? errorMessage;

    // تحديث الاسم إذا تغير
    if (_nameController.text != profileController.user.name) {
      success = await profileController.updateName(_nameController.text.trim());
      if (!success) errorMessage = 'فشل تحديث الاسم';
    }

    // تحديث البريد الإلكتروني إذا تغير ونجحت العملية السابقة
    if (success && _emailController.text != profileController.user.email) {
      success = await profileController.updateEmail(_emailController.text.trim());
      if (!success) errorMessage = 'فشل تحديث البريد الإلكتروني';
    }

    // تحديث الصورة إذا تغيرت ونجحت العمليات السابقة
    if (success && _profileImage != null) {
      success = await profileController.updateProfileImage(_profileImage!);
      if (!success) errorMessage = 'فشل تحديث الصورة';
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم حفظ التغييرات بنجاح'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'حدث خطأ أثناء الحفظ'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showExitDialog(BuildContext context, bool isDarkMode) {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF2A2A3A) : Colors.white,
          title: Text(
            'تجاهل التغييرات؟',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            'لديك تغييرات غير محفوظة. هل تريد تجاهلها؟',
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
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.red.shade800 : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('تجاهل'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }
}