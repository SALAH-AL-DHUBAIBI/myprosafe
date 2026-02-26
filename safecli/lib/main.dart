import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/scan_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/report_controller.dart';
import 'services/notification_service.dart';
import 'views/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/main/home_screen.dart';
import 'theme/app_theme.dart';

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
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsController.settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: Consumer<AuthController>(
              builder: (context, authController, child) {
                if (authController.isLoading) {
                  return const SplashScreen();
                }
                return authController.isAuthenticated ? const HomeScreen() : const LoginScreen();
              },
            ),
            routes: _buildRoutes(),
          );
        },
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
