import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import '../models/platform_info.dart';
import '../constants/app_constants.dart';

class PlatformService {
  static PlatformService? _instance;
  static PlatformService get instance {
    _instance ??= PlatformService._();
    return _instance!;
  }

  PlatformService._();

  PlatformInfo? _platformInfo;
  PlatformInfo get platformInfo => _platformInfo!;

  Future<void> initialize() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    
    if (kIsWeb) {
      _platformInfo = await _getWebPlatformInfo(deviceInfoPlugin);
    } else if (Platform.isAndroid) {
      _platformInfo = await _getAndroidPlatformInfo(deviceInfoPlugin);
    } else if (Platform.isIOS) {
      _platformInfo = await _getIOSPlatformInfo(deviceInfoPlugin);
    } else if (Platform.isLinux) {
      _platformInfo = await _getLinuxPlatformInfo(deviceInfoPlugin);
    } else if (Platform.isMacOS) {
      _platformInfo = await _getMacOSPlatformInfo(deviceInfoPlugin);
    } else if (Platform.isWindows) {
      _platformInfo = await _getWindowsPlatformInfo(deviceInfoPlugin);
    } else {
      _platformInfo = _getDefaultPlatformInfo();
    }
  }

  Future<PlatformInfo> _getAndroidPlatformInfo(DeviceInfoPlugin deviceInfo) async {
    final info = await deviceInfo.androidInfo;
    final screenSize = _getScreenSize();
    
    return PlatformInfo(
      deviceType: _determineDeviceType(screenSize.width, info.isPhysicalDevice, 'android'),
      platformType: PlatformType.android,
      deviceModel: '${info.manufacturer} ${info.model}',
      osVersion: 'Android ${info.version.release}',
      isPhysicalDevice: info.isPhysicalDevice,
      screenWidth: screenSize.width,
      screenHeight: screenSize.height,
      devicePixelRatio: screenSize.devicePixelRatio,
    );
  }

  Future<PlatformInfo> _getIOSPlatformInfo(DeviceInfoPlugin deviceInfo) async {
    final info = await deviceInfo.iosInfo;
    final screenSize = _getScreenSize();
    
    return PlatformInfo(
      deviceType: _determineDeviceType(screenSize.width, info.isPhysicalDevice, 'ios'),
      platformType: PlatformType.ios,
      deviceModel: '${info.name} (${info.model})',
      osVersion: 'iOS ${info.systemVersion}',
      isPhysicalDevice: info.isPhysicalDevice,
      screenWidth: screenSize.width,
      screenHeight: screenSize.height,
      devicePixelRatio: screenSize.devicePixelRatio,
    );
  }

  Future<PlatformInfo> _getLinuxPlatformInfo(DeviceInfoPlugin deviceInfo) async {
    final info = await deviceInfo.linuxInfo;
    final screenSize = _getScreenSize();
    
    return PlatformInfo(
      deviceType: DeviceType.desktop,
      platformType: PlatformType.linux,
      deviceModel: info.name,
      osVersion: '${info.prettyName} ${info.version}',
      isPhysicalDevice: true,
      screenWidth: screenSize.width,
      screenHeight: screenSize.height,
      devicePixelRatio: screenSize.devicePixelRatio,
    );
  }

  Future<PlatformInfo> _getMacOSPlatformInfo(DeviceInfoPlugin deviceInfo) async {
    final info = await deviceInfo.macOsInfo;
    final screenSize = _getScreenSize();
    
    return PlatformInfo(
      deviceType: DeviceType.desktop,
      platformType: PlatformType.macos,
      deviceModel: info.model,
      osVersion: 'macOS ${info.osRelease}',
      isPhysicalDevice: true,
      screenWidth: screenSize.width,
      screenHeight: screenSize.height,
      devicePixelRatio: screenSize.devicePixelRatio,
    );
  }

  Future<PlatformInfo> _getWindowsPlatformInfo(DeviceInfoPlugin deviceInfo) async {
    final info = await deviceInfo.windowsInfo;
    final screenSize = _getScreenSize();
    
    return PlatformInfo(
      deviceType: DeviceType.desktop,
      platformType: PlatformType.windows,
      deviceModel: info.computerName,
      osVersion: 'Windows ${info.displayVersion}',
      isPhysicalDevice: true,
      screenWidth: screenSize.width,
      screenHeight: screenSize.height,
      devicePixelRatio: screenSize.devicePixelRatio,
    );
  }

  Future<PlatformInfo> _getWebPlatformInfo(DeviceInfoPlugin deviceInfo) async {
    final info = await deviceInfo.webBrowserInfo;
    final screenSize = _getScreenSize();
    
    return PlatformInfo(
      deviceType: _determineDeviceType(screenSize.width, false, 'web'),
      platformType: PlatformType.web,
      deviceModel: '${info.browserName} ${info.platform}',
      osVersion: info.userAgent ?? 'Unknown',
      isPhysicalDevice: false,
      screenWidth: screenSize.width,
      screenHeight: screenSize.height,
      devicePixelRatio: screenSize.devicePixelRatio,
    );
  }

  PlatformInfo _getDefaultPlatformInfo() {
    final screenSize = _getScreenSize();
    
    return PlatformInfo(
      deviceType: DeviceType.desktop,
      platformType: PlatformType.linux,
      deviceModel: 'Unknown Device',
      osVersion: 'Unknown OS',
      isPhysicalDevice: true,
      screenWidth: screenSize.width,
      screenHeight: screenSize.height,
      devicePixelRatio: screenSize.devicePixelRatio,
    );
  }

  ({double width, double height, double devicePixelRatio}) _getScreenSize() {
    final view = PlatformDispatcher.instance.views.first;
    final size = view.physicalSize;
    final devicePixelRatio = view.devicePixelRatio;
    
    return (
      width: size.width / devicePixelRatio,
      height: size.height / devicePixelRatio,
      devicePixelRatio: devicePixelRatio,
    );
  }

  DeviceType _determineDeviceType(double screenWidth, bool isPhysicalDevice, String platform) {
    if (platform == 'web') {
      if (screenWidth < AppConstants.mobileBreakpoint) {
        return DeviceType.mobile;
      } else if (screenWidth < AppConstants.desktopBreakpoint) {
        return DeviceType.tablet;
      } else {
        return DeviceType.desktop;
      }
    }

    if (platform == 'android') {
      if (screenWidth > 1000 && !isPhysicalDevice) {
        return DeviceType.tv;
      } else if (screenWidth >= AppConstants.tabletBreakpoint) {
        return DeviceType.tablet;
      } else {
        return DeviceType.mobile;
      }
    }

    if (platform == 'ios') {
      return screenWidth >= AppConstants.tabletBreakpoint 
          ? DeviceType.tablet 
          : DeviceType.mobile;
    }

    return DeviceType.desktop;
  }
}