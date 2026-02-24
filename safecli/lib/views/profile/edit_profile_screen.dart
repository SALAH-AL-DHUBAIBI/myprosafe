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
    _phoneController = TextEditingController(text: ''); // يمكن إضافة رقم الهاتف لاحقاً

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : () => _saveProfile(profileController),
              child: Text(
                'حفظ',
                style: TextStyle(
                  color: _isLoading ? Colors.grey : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileImage(profileController),
                  const SizedBox(height: 30),
                  _buildForm(),
                  const SizedBox(height: 30),
                  _buildSaveButton(profileController),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileImage(ProfileController profileController) {
    return GestureDetector(
      onTap: () => _showImageOptions(context, profileController),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0A4779), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 70,
              backgroundImage: _getProfileImage(profileController.user),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF0A4779),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المعلومات الشخصية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A4779),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _nameController,
            label: 'الاسم الكامل',
            icon: Icons.person,
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0A4779)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A4779), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
    );
  }

  Widget _buildSaveButton(ProfileController profileController) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _hasChanges && !_isLoading
            ? () => _saveProfile(profileController)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A4779),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'حفظ التغييرات',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
              'تغيير الصورة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('اختر من المعرض'),
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
              leading: const Icon(Icons.camera_alt, color: Colors.orange),
              title: const Text('التقاط صورة'),
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
          const SnackBar(
            content: Text('تم حفظ التغييرات بنجاح'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'حدث خطأ أثناء الحفظ'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showExitDialog(BuildContext context) {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تجاهل التغييرات؟'),
          content: const Text('لديك تغييرات غير محفوظة. هل تريد تجاهلها؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق الحوار
                Navigator.pop(context); // العودة للصفحة السابقة
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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