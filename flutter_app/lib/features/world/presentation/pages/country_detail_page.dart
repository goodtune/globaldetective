import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

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