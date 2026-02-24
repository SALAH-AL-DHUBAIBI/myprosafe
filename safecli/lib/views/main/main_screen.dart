import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeclik/views/report/report_screen.dart';
import 'package:safeclik/views/scan/history_screen.dart';
import '../../controllers/scan_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/scan_result.dart';
import '../../widgets/stats_card.dart';
import '../scan/result_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final TextEditingController _linkController = TextEditingController();
  final FocusNode _linkFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _linkController.dispose();
    _linkFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanController = context.watch<ScanController>();
    final settingsController = context.watch<SettingsController>();

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildScanCard(scanController, settingsController),
              const SizedBox(height: 20),
              if (scanController.lastError != null) _buildErrorWidget(scanController),
              const SizedBox(height: 30),
              _buildQuickActions(),
              const SizedBox(height: 30),
              _buildStats(scanController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A4779),
            Color(0xFF4D82B8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A4779).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.security_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Safe Clik',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'حماية ذكية من الروابط الضارة والتصيد الإلكتروني',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScanCard(ScanController scanController, SettingsController settingsController) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A4779).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Color(0xFF0A4779),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'فحص رابط جديد',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _linkController,
              focusNode: _linkFocusNode,
              decoration: InputDecoration(
                hintText: 'https://example.com',
                labelText: 'أدخل الرابط هنا',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0A4779), width: 2),
                ),
                prefixIcon: const Icon(Icons.link, color: Color(0xFF0A4779)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _linkController.clear(),
                ),
              ),
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: scanController.isScanning
                        ? null
                        : () => _performScan(context, scanController),
                    icon: const Icon(Icons.search),
                    label: scanController.isScanning
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('فحص الرابط'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A4779),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (settingsController.settings.autoScan)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  // children: [
                  //   // Icon(
                  //   //   Icons.auto_awesome,
                  //   //   size: 16,
                  //   //   color: Colors.grey.shade600,
                  //   // ),
                  //   // const SizedBox(width: 5),
                  //   // Text(
                  //   //   'المسح التلقائي مفعل',
                  //   //   style: TextStyle(
                  //   //     fontSize: 12,
                  //   //     color: Colors.grey.shade600,
                  //   //   ),
                  //   // ),
                  // ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ScanController scanController) {
    return Container(
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
              scanController.lastError!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: scanController.clearError,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 8),
          child: Text(
            'إجراءات سريعة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildQuickActionButton(
              icon: Icons.history,
              label: 'السجل',
              color: Colors.blue,
              onTap: () {
                // Navigator.push(
                //  context,
                //   MaterialPageRoute(builder: (context) => const HistoryScreen()),
                //   );
              },
            ),
            const SizedBox(width: 10),
            _buildQuickActionButton(
              icon: Icons.report,
              label: 'الإبلاغ',
              color: Colors.orange,
              onTap: () {
                // Navigator.push(
                //  context,
                //   MaterialPageRoute(builder: (context) => const ReportScreen()),
                //   );
              },
            ),
            const SizedBox(width: 10),
            _buildQuickActionButton(
              icon: Icons.share,
              label: 'مشاركة',
              color: Colors.green,
              onTap: () {
                _shareApp();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(ScanController scanController) {
    final stats = scanController.getStats();
    
    return StatsCard(
      scannedCount: stats['total'].toString(),
      maliciousCount: stats['dangerous'].toString(),
      blockedCount: stats['dangerous'].toString(),
    );
  }

  Future<void> _performScan(BuildContext context, ScanController scanController) async {
    if (_linkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رابط لفحصه'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result = await scanController.scanLink(_linkController.text.trim());
    
    if (result != null && mounted) {
      _linkController.clear();
      _linkFocusNode.unfocus();
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(scanResult: result),
        ),
      );
    }
  }

  void _shareApp() {
    // يمكن إضافة مكتبة مشاركة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة ميزة المشاركة قريباً'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}