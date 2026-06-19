import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

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