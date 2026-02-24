import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();

    return Scaffold(
     
      body: settingsController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildGeneralSection(settingsController),
                const SizedBox(height: 20),
                _buildProtectionSection(settingsController),
                const SizedBox(height: 20),
                _buildScanSettingsSection(settingsController),
                const SizedBox(height: 20),
                _buildAppearanceSection(settingsController),
                const SizedBox(height: 20),
                _buildAboutSection(context),
                const SizedBox(height: 20),
                _buildDangerZone(context, settingsController),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A4779), Color(0xFF4D82B8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.settings, color: Colors.white, size: 30),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الإعدادات',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'خصص التطبيق حسب احتياجاتك',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection(SettingsController controller) {
    return _buildSection(
      title: 'عام',
      icon: Icons.settings_applications,
      children: [
        _buildSwitchTile(
          title: 'المسح التلقائي',
          subtitle: 'فحص الروابط تلقائياً عند النسخ',
          value: controller.settings.autoScan,
          icon: Icons.auto_fix_high,
          onChanged: (value) => controller.toggleAutoScan(value),
        ),
        _buildSwitchTile(
          title: 'الإشعارات',
          subtitle: 'إشعارات عند اكتشاف روابط ضارة',
          value: controller.settings.notifications,
          icon: Icons.notifications,
          onChanged: (value) => controller.toggleNotifications(value),
        ),
        _buildSwitchTile(
          title: 'حفظ السجل',
          subtitle: 'حفظ سجل الفحوصات السابقة',
          value: controller.settings.saveHistory,
          icon: Icons.save,
          onChanged: (value) => controller.toggleSaveHistory(value),
        ),
        _buildLanguageTile(controller),
      ],
    );
  }

  Widget _buildProtectionSection(SettingsController controller) {
    return _buildSection(
      title: 'الحماية',
      icon: Icons.security,
      children: [
        _buildSwitchTile(
          title: 'التصفح الآمن',
          subtitle: 'حظر المواقع الضارة تلقائياً',
          value: controller.settings.safeBrowsing,
          icon: Icons.shield,
          onChanged: (value) => controller.toggleSafeBrowsing(value),
        ),
        _buildSwitchTile(
          title: 'التحديث التلقائي',
          subtitle: 'تحديث قواعد البيانات تلقائياً',
          value: controller.settings.autoUpdate,
          icon: Icons.update,
          onChanged: (value) => controller.toggleAutoUpdate(value),
        ),
      ],
    );
  }

  Widget _buildScanSettingsSection(SettingsController controller) {
    return _buildSection(
      title: 'إعدادات الفحص',
      icon: Icons.search,
      children: [
        _buildSliderTile(
          title: 'مهلة الفحص',
          value: controller.settings.scanTimeout.toDouble(),
          min: 10,
          max: 60,
          divisions: 5,
          onChanged: (value) => controller.setScanTimeout(value.toInt()),
        ),
        _buildScanLevelTile(controller),
      ],
    );
  }

  Widget _buildAppearanceSection(SettingsController controller) {
    return _buildSection(
      title: 'المظهر',
      icon: Icons.palette,
      children: [
        _buildSwitchTile(
          title: 'الوضع الداكن',
          subtitle: 'تفعيل الوضع الداكن للتطبيق',
          value: controller.settings.darkMode,
          icon: Icons.dark_mode,
          onChanged: (value) => controller.toggleDarkMode(value),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(
      title: 'حول التطبيق',
      icon: Icons.info,
      children: [
        _buildInfoTile(
          title: 'إصدار التطبيق',
          value: '1.0.0',
          icon: Icons.tag,
        ),
        _buildInfoTile(
          title: 'آخر تحديث',
          value: 'يناير 2024',
          icon: Icons.update,
        ),
        _buildActionTile(
          title: 'تقييم التطبيق',
          icon: Icons.star,
          iconColor: Colors.amber,
          onTap: () {},
        ),
        _buildActionTile(
          title: 'مشاركة التطبيق',
          icon: Icons.share,
          iconColor: Colors.green,
          onTap: () {},
        ),
        _buildActionTile(
          title: 'سياسة الخصوصية',
          icon: Icons.privacy_tip,
          iconColor: Colors.blue,
          onTap: () {},
        ),
        _buildActionTile(
          title: 'الشروط والأحكام',
          icon: Icons.description,
          iconColor: Colors.purple,
          onTap: () {},
        ),
        _buildActionTile(
          title: 'الدعم الفني',
          icon: Icons.contact_support,
          iconColor: Colors.orange,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildDangerZone(BuildContext context, SettingsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'منطقة الخطر',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.red),
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.red),
            title: const Text(
              'إعادة ضبط الإعدادات',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('إعادة جميع الإعدادات إلى الوضع الافتراضي'),
            onTap: () => _showResetDialog(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A4779).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF0A4779), size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0A4779).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF0A4779), size: 20),
      ),
      activeColor: const Color(0xFF0A4779),
    );
  }

  Widget _buildLanguageTile(SettingsController controller) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0A4779).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.language, color: Color(0xFF0A4779)),
      ),
      title: const Text('اللغة'),
      subtitle: Text(controller.settings.language == 'ar' ? 'العربية' : 'English'),
      trailing: DropdownButton<String>(
        value: controller.settings.language,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'ar', child: Text('العربية')),
          DropdownMenuItem(value: 'en', child: Text('English')),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.changeLanguage(value);
          }
        },
      ),
    );
  }

  Widget _buildScanLevelTile(SettingsController controller) {
    Map<String, String> levelNames = {
      'basic': 'أساسي',
      'standard': 'قياسي',
      'deep': 'عميق',
    };

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0A4779).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.speed, color: Color(0xFF0A4779)),
      ),
      title: const Text('مستوى الفحص'),
      subtitle: Text(levelNames[controller.settings.scanLevel] ?? 'قياسي'),
      trailing: DropdownButton<String>(
        value: controller.settings.scanLevel,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'basic', child: Text('أساسي')),
          DropdownMenuItem(value: 'standard', child: Text('قياسي')),
          DropdownMenuItem(value: 'deep', child: Text('عميق')),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.setScanLevel(value);
          }
        },
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text('${value.toInt()} ثانية'),
            ],
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: const Color(0xFF0A4779),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.grey, size: 20),
      ),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
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
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showResetDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة ضبط الإعدادات'),
        content: const Text(
          'هل أنت متأكد من إعادة ضبط جميع الإعدادات إلى القيم الافتراضية؟ لا يمكن التراجع عن هذا الإجراء.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إعادة ضبط الإعدادات'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('إعادة الضبط'),
          ),
        ],
      ),
    );
  }
}