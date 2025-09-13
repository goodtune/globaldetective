import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/platform_service.dart';
import '../../../core/constants/app_constants.dart';
import '../layouts/responsive_layout.dart';
import '../widgets/platform_info_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platformInfo = PlatformService.instance.platformInfo;
    
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context, platformInfo),
      tablet: _buildTabletLayout(context, platformInfo),
      desktop: _buildDesktopLayout(context, platformInfo),
    );
  }

  Widget _buildMobileLayout(BuildContext context, platformInfo) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlatformInfoCard(platformInfo: platformInfo),
            const SizedBox(height: 24),
            _buildMainMenu(context, true),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, platformInfo) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: PlatformInfoCard(platformInfo: platformInfo),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: _buildMainMenu(context, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, platformInfo) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        centerTitle: true,
        toolbarHeight: 70,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  PlatformInfoCard(platformInfo: platformInfo),
                  const SizedBox(height: 24),
                  _buildQuickStats(context),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              flex: 3,
              child: _buildMainMenu(context, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenu(BuildContext context, bool isMobile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome, Detective!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your adventure mode',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            _buildMenuButton(
              context,
              icon: Icons.wifi_outlined,
              title: 'Host Game',
              subtitle: 'Start a new multiplayer session',
              onTap: () => _showFeatureDialog(context, 'Host Game'),
              isMobile: isMobile,
            ),
            
            const SizedBox(height: 16),
            
            _buildMenuButton(
              context,
              icon: Icons.group_add_outlined,
              title: 'Join Game',
              subtitle: 'Connect to an existing session',
              onTap: () => _showFeatureDialog(context, 'Join Game'),
              isMobile: isMobile,
            ),
            
            const SizedBox(height: 16),
            
            _buildMenuButton(
              context,
              icon: Icons.person_outline,
              title: 'Solo Practice',
              subtitle: 'Explore the world on your own',
              onTap: () => _showFeatureDialog(context, 'Solo Practice'),
              isMobile: isMobile,
            ),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showFeatureDialog(context, 'Settings'),
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Settings'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showFeatureDialog(context, 'About'),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('About'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: isMobile ? 24 : 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(context, 'Detective Rank', 'Rookie'),
            const SizedBox(height: 8),
            _buildStatRow(context, 'Cases Solved', '0'),
            const SizedBox(height: 8),
            _buildStatRow(context, 'Countries Visited', '0'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  void _showFeatureDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('$feature feature is coming soon!\n\nThis is a demo of the multi-platform responsive UI.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}