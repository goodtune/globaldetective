import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/game/presentation/pages/game_home_page.dart';
import '../../features/game/presentation/pages/case_selection_page.dart';
import '../../features/game/presentation/pages/mission_briefing_page.dart';
import '../../features/world/presentation/pages/globe_page.dart';
import '../../features/world/presentation/pages/country_detail_page.dart';
import '../../features/world/presentation/pages/landmark_detail_page.dart';
import '../../features/cases/presentation/pages/case_investigation_page.dart';
import '../../features/player/presentation/pages/player_profile_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const GameHomePage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const PlayerProfilePage(),
      ),
      GoRoute(
        path: '/cases',
        name: 'cases',
        builder: (context, state) => const CaseSelectionPage(),
      ),
      GoRoute(
        path: '/briefing/:caseId',
        name: 'briefing',
        builder: (context, state) {
          final caseId = state.pathParameters['caseId']!;
          return MissionBriefingPage(caseId: caseId);
        },
      ),
      GoRoute(
        path: '/globe',
        name: 'globe',
        builder: (context, state) => const GlobePage(),
      ),
      GoRoute(
        path: '/country/:countryId',
        name: 'country',
        builder: (context, state) {
          final countryId = state.pathParameters['countryId']!;
          return CountryDetailPage(countryId: countryId);
        },
      ),
      GoRoute(
        path: '/landmark/:landmarkId',
        name: 'landmark',
        builder: (context, state) {
          final landmarkId = state.pathParameters['landmarkId']!;
          return LandmarkDetailPage(landmarkId: landmarkId);
        },
      ),
      GoRoute(
        path: '/investigation/:caseId',
        name: 'investigation',
        builder: (context, state) {
          final caseId = state.pathParameters['caseId']!;
          return CaseInvestigationPage(caseId: caseId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}