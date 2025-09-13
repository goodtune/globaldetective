import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_framework/responsive_framework.dart' as rf;

import 'core/services/platform_service.dart';
import 'core/constants/app_constants.dart';
import 'shared/themes/app_theme.dart';
import 'shared/blocs/app_bloc_observer.dart';
import 'features/ui/screens/splash_screen.dart';
import 'features/game/blocs/game_state/game_state_bloc.dart';
import 'features/game/blocs/case_management/case_management_bloc.dart';
import 'features/networking/blocs/network_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize platform service
  await PlatformService.instance.initialize();
  
  // Initialize HydratedBloc for state persistence
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  
  // Set up BLoC observer for debugging
  Bloc.observer = AppBlocObserver();
  
  runApp(const GlobalDetectiveApp());
}

class GlobalDetectiveApp extends StatelessWidget {
  const GlobalDetectiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GameStateBloc>(
          create: (context) => GameStateBloc(),
        ),
        BlocProvider<CaseManagementBloc>(
          create: (context) => CaseManagementBloc(),
        ),
        BlocProvider<NetworkBloc>(
          create: (context) => NetworkBloc()..add(const NetworkInitialized()),
        ),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}

