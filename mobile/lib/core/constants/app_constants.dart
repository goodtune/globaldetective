class AppConstants {
  static const String appName = 'Global Detective';
  static const String appVersion = '1.0.0';
  
  // Platform identifiers
  static const String platformDesktop = 'desktop';
  static const String platformTablet = 'tablet';
  static const String platformTV = 'tv';
  static const String platformWeb = 'web';
  
  // Network constants
  static const int defaultPort = 8080;
  static const String multicastAddress = '224.0.0.1';
  static const int discoveryPort = 8081;
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration heartbeatInterval = Duration(seconds: 5);
  
  // Game constants
  static const int maxPlayers = 6;
  static const int defaultBudget = 5000;
  static const int defaultTimeLimit = 180; // minutes
  
  // UI constants
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 1000);
}