import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/auth_controller.dart';
import 'controllers/scan_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/report_controller.dart';
import 'services/notification_service.dart';
import 'views/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/main/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة الإشعارات
  await NotificationService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ScanController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => ReportController()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsController, child) {
          return MaterialApp(
            title: 'SafeClik',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(settingsController.settings.darkMode),
            home: Consumer<AuthController>(
              builder: (context, authController, child) {
                if (authController.isLoading) {
                  return const SplashScreen();
                }
                
                if (authController.isAuthenticated) {
                  return const HomeScreen();
                }
                
                return const LoginScreen();
              },
            ),
            routes: _buildRoutes(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(bool isDarkMode) {
    if (isDarkMode) {
      return ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF0A4779),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A4779),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A4779),
            foregroundColor: Colors.white,
          ),
        ),
      );
    }
    
    return ThemeData.light().copyWith(
      primaryColor: const Color(0xFF0A4779),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A4779),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A4779),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/login': (context) => const LoginScreen(),
      '/home': (context) => const HomeScreen(),
    };
  }
}