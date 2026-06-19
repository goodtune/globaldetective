import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

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