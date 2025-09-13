import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../core/models/platform_info.dart';

class PlatformInfoCard extends StatelessWidget {
  final PlatformInfo platformInfo;

  const PlatformInfoCard({
    super.key,
    required this.platformInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getPlatformIcon(),
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Platform Info',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Device Type',
              _getDeviceTypeString(),
              Icons.devices_outlined,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Platform',
              _getPlatformString(),
              _getPlatformIcon(),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Screen',
              '${platformInfo.screenWidth.toInt()} × ${platformInfo.screenHeight.toInt()}',
              Icons.monitor_outlined,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Capabilities',
              _getCapabilitiesString(),
              Icons.check_circle_outline,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getOptimizationMessage(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  IconData _getPlatformIcon() {
    switch (platformInfo.platformType) {
      case PlatformType.android:
        return MdiIcons.android;
      case PlatformType.ios:
        return MdiIcons.apple;
      case PlatformType.linux:
        return MdiIcons.linux;
      case PlatformType.macos:
        return MdiIcons.apple;
      case PlatformType.windows:
        return MdiIcons.microsoft;
      case PlatformType.web:
        return MdiIcons.web;
    }
  }

  String _getDeviceTypeString() {
    switch (platformInfo.deviceType) {
      case DeviceType.mobile:
        return 'Mobile Phone';
      case DeviceType.tablet:
        return 'Tablet';
      case DeviceType.desktop:
        return 'Desktop Computer';
      case DeviceType.tv:
        return 'Android TV';
      case DeviceType.web:
        return 'Web Browser';
    }
  }

  String _getPlatformString() {
    switch (platformInfo.platformType) {
      case PlatformType.android:
        return 'Android';
      case PlatformType.ios:
        return 'iOS/iPadOS';
      case PlatformType.linux:
        return 'Linux';
      case PlatformType.macos:
        return 'macOS';
      case PlatformType.windows:
        return 'Windows';
      case PlatformType.web:
        return 'Web';
    }
  }

  String _getCapabilitiesString() {
    final capabilities = <String>[];
    
    if (platformInfo.supportsLocalNetworking) {
      capabilities.add('Local Network');
    }
    
    if (platformInfo.supportsFileSystem) {
      capabilities.add('File System');
    }
    
    if (platformInfo.supportsMultipleWindows) {
      capabilities.add('Multi-Window');
    }
    
    if (capabilities.isEmpty) {
      capabilities.add('Basic Features');
    }
    
    return capabilities.join(', ');
  }

  String _getOptimizationMessage() {
    switch (platformInfo.deviceType) {
      case DeviceType.mobile:
        return 'Optimized for touch navigation and mobile performance';
      case DeviceType.tablet:
        return 'Enhanced tablet layout with split-screen support';
      case DeviceType.desktop:
        return 'Full-featured desktop experience with keyboard shortcuts';
      case DeviceType.tv:
        return 'TV-optimized interface for big screen gaming';
      case DeviceType.web:
        return 'Cross-platform web experience with responsive design';
    }
  }
}