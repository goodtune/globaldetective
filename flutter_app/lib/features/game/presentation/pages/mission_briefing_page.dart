import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

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