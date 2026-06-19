import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/database/database_service.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/game/presentation/bloc/game_bloc.dart';
import 'features/player/presentation/bloc/player_bloc.dart';
import 'features/world/presentation/bloc/world_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseService.instance.initialize();
  
  runApp(const GlobalDetectiveApp());
}

class GlobalDetectiveApp extends StatelessWidget {
  const GlobalDetectiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GameBloc()),
        BlocProvider(create: (context) => PlayerBloc()),
        BlocProvider(create: (context) => WorldBloc()..add(LoadWorldData())),
      ],
      child: MaterialApp.router(
        title: 'Global Detective',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}