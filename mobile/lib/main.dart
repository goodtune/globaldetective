import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart' as rf;

import 'core/services/platform_service.dart';
import 'core/constants/app_constants.dart';
import 'shared/themes/app_theme.dart';
import 'features/ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize platform service
  await PlatformService.instance.initialize();
  
  runApp(const ProviderScope(child: GlobalDetectiveApp()));
}

class GlobalDetectiveApp extends ConsumerWidget {
  const GlobalDetectiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      
      // Responsive framework setup
      builder: (context, child) => rf.ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const rf.Breakpoint(start: 0, end: 450, name: rf.MOBILE),
          const rf.Breakpoint(start: 451, end: 800, name: rf.TABLET),
          const rf.Breakpoint(start: 801, end: 1920, name: rf.DESKTOP),
          const rf.Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      
      home: const SplashScreen(),
    );
  }
}

