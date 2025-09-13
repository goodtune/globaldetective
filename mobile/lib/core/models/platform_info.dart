import 'package:flutter/foundation.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
  tv,
  web,
}

enum PlatformType {
  android,
  ios,
  linux,
  macos,
  windows,
  web,
}

class PlatformInfo {
  final DeviceType deviceType;
  final PlatformType platformType;
  final String deviceModel;
  final String osVersion;
  final bool isPhysicalDevice;
  final double screenWidth;
  final double screenHeight;
  final double devicePixelRatio;

  const PlatformInfo({
    required this.deviceType,
    required this.platformType,
    required this.deviceModel,
    required this.osVersion,
    required this.isPhysicalDevice,
    required this.screenWidth,
    required this.screenHeight,
    required this.devicePixelRatio,
  });

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;
  bool get isTV => deviceType == DeviceType.tv;
  bool get isWeb => deviceType == DeviceType.web;

  bool get isAndroid => platformType == PlatformType.android;
  bool get isIOS => platformType == PlatformType.ios;
  bool get isLinux => platformType == PlatformType.linux;
  bool get isMacOS => platformType == PlatformType.macos;
  bool get isWindows => platformType == PlatformType.windows;

  bool get supportsLocalNetworking => !kIsWeb;
  bool get supportsFileSystem => !kIsWeb;
  bool get supportsMultipleWindows => isDesktop;

  @override
  String toString() {
    return 'PlatformInfo(deviceType: $deviceType, platformType: $platformType, '
           'deviceModel: $deviceModel, osVersion: $osVersion, '
           'screenSize: ${screenWidth}x$screenHeight)';
  }
}