import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class CaseSelectionPage extends StatelessWidget {
  const CaseSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Case'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Case Selection - Coming Soon'),
      ),
    );
  }
}

class MissionBriefingPage extends StatelessWidget {
  final String caseId;
  
  const MissionBriefingPage({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission Briefing'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Mission Briefing for Case: $caseId'),
      ),
    );
  }
}

class GlobePage extends StatelessWidget {
  const GlobePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Globe'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Interactive Globe - Coming Soon'),
      ),
    );
  }
}

class CountryDetailPage extends StatelessWidget {
  final String countryId;
  
  const CountryDetailPage({super.key, required this.countryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Country Details for: $countryId'),
      ),
    );
  }
}

class LandmarkDetailPage extends StatelessWidget {
  final String landmarkId;
  
  const LandmarkDetailPage({super.key, required this.landmarkId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landmark Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Landmark Details for: $landmarkId'),
      ),
    );
  }
}

class CaseInvestigationPage extends StatelessWidget {
  final String caseId;
  
  const CaseInvestigationPage({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investigation'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Case Investigation for: $caseId'),
      ),
    );
  }
}