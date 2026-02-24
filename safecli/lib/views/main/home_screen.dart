import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main/main_screen.dart';
import '../scan/history_screen.dart';
import '../report/report_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../../controllers/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const MainScreen(),
    const HistoryScreen(),
    const ReportScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    'الرئيسية',
    'السجل',
    'الإبلاغ',
    'الملف الشخصي',
    'الإعدادات',
  ];

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_currentIndex]),
          centerTitle: true,
          actions: _buildAppBarActions(),
        ),
        body: _screens[_currentIndex],
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      if (_currentIndex == 0)
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: _showScanOptions,
          tooltip: 'مسح QR',
        ),
    ];
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0A4779),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'السجل',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_outlined),
            activeIcon: Icon(Icons.report),
            label: 'الإبلاغ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'الملف',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الخروج'),
            content: const Text('هل تريد الخروج من التطبيق؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('خروج'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void _showScanOptions() {
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
              'اختيار طريقة الفحص',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A4779).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.link, color: Color(0xFF0A4779)),
              ),
              title: const Text('إدخال رابط'),
              subtitle: const Text('لصق رابط لفحصه'),
              onTap: () {
                Navigator.pop(context);
                // التركيز على حقل الإدخال في الصفحة الرئيسية
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A4779).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code, color: Color(0xFF0A4779)),
              ),
              title: const Text('مسح QR Code'),
              subtitle: const Text('استخدم الكاميرا لمسح الرمز'),
              onTap: () {
                Navigator.pop(context);
                _showQRScanner();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الإشعارات'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 0, // عدد الإشعارات
            itemBuilder: (context, index) {
              return const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xFF0A4779),
                  child: Icon(Icons.notifications, color: Colors.white),
                ),
                title: Text('لا توجد إشعارات'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showQRScanner() {
    // يمكن إضافة مكتبة لمسح QR Code
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة ميزة مسح QR Code قريباً'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}