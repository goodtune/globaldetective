import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/platform_service.dart';
import '../models/network_message.dart';

class NetworkDiscoveryService {
  static NetworkDiscoveryService? _instance;
  static NetworkDiscoveryService get instance {
    _instance ??= NetworkDiscoveryService._();
    return _instance!;
  }

  NetworkDiscoveryService._();

  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();
  
  RawDatagramSocket? _discoverySocket;
  Timer? _discoveryTimer;
  Timer? _announcementTimer;
  
  final StreamController<SessionAnnouncement> _sessionsController = 
      StreamController<SessionAnnouncement>.broadcast();
  
  Stream<SessionAnnouncement> get sessionsStream => _sessionsController.stream;
  
  bool _isDiscovering = false;
  bool _isAnnouncing = false;
  
  String? _localIPAddress;
  SessionAnnouncement? _currentSession;

  Future<void> initialize() async {
    if (!PlatformService.instance.platformInfo.supportsLocalNetworking) {
      _logger.w('Platform does not support local networking');
      return;
    }

    try {
      _localIPAddress = await _getLocalIPAddress();
      _logger.i('Network discovery service initialized with IP: $_localIPAddress');
    } catch (e) {
      _logger.e('Failed to initialize network discovery: $e');
    }
  }

  Future<void> startDiscovery() async {
    if (_isDiscovering || !_canUseLocalNetworking()) return;

    try {
      _discoverySocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        AppConstants.discoveryPort,
      );

      _discoverySocket!.broadcastEnabled = true;
      _discoverySocket!.listen(_handleDiscoveryData);

      _discoveryTimer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _sendDiscoveryRequest(),
      );

      _isDiscovering = true;
      _logger.i('Started network discovery');
    } catch (e) {
      _logger.e('Failed to start discovery: $e');
    }
  }

  Future<void> stopDiscovery() async {
    if (!_isDiscovering) return;

    _discoveryTimer?.cancel();
    _discoverySocket?.close();
    
    _isDiscovering = false;
    _logger.i('Stopped network discovery');
  }

  Future<void> startAnnouncing(SessionAnnouncement session) async {
    if (_isAnnouncing || !_canUseLocalNetworking()) return;

    _currentSession = session;

    try {
      _announcementTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => _sendSessionAnnouncement(),
      );

      _isAnnouncing = true;
      _logger.i('Started announcing session: ${session.sessionName}');
    } catch (e) {
      _logger.e('Failed to start announcing: $e');
    }
  }

  Future<void> stopAnnouncing() async {
    if (!_isAnnouncing) return;

    _announcementTimer?.cancel();
    _currentSession = null;
    
    _isAnnouncing = true;
    _logger.i('Stopped announcing session');
  }

  void dispose() {
    stopDiscovery();
    stopAnnouncing();
    _sessionsController.close();
  }

  Future<void> _sendDiscoveryRequest() async {
    if (_discoverySocket == null) return;

    try {
      final request = SessionDiscoveryRequest(
        requesterId: _uuid.v4(),
        requesterName: _getDeviceName(),
        deviceInfo: _getDeviceInfo(),
      );

      final message = NetworkMessage(
        messageId: _uuid.v4(),
        type: MessageType.sessionDiscovery,
        senderId: request.requesterId,
        payload: request.toJson(),
        timestamp: DateTime.now(),
      );

      final data = utf8.encode(jsonEncode(message.toJson()));
      
      _discoverySocket!.send(
        data,
        InternetAddress(AppConstants.multicastAddress),
        AppConstants.discoveryPort,
      );
    } catch (e) {
      _logger.e('Failed to send discovery request: $e');
    }
  }

  Future<void> _sendSessionAnnouncement() async {
    if (_discoverySocket == null || _currentSession == null) return;

    try {
      final message = NetworkMessage(
        messageId: _uuid.v4(),
        type: MessageType.sessionAnnouncement,
        senderId: _currentSession!.hostId,
        sessionId: _currentSession!.sessionId,
        payload: _currentSession!.toJson(),
        timestamp: DateTime.now(),
      );

      final data = utf8.encode(jsonEncode(message.toJson()));
      
      _discoverySocket!.send(
        data,
        InternetAddress(AppConstants.multicastAddress),
        AppConstants.discoveryPort,
      );
    } catch (e) {
      _logger.e('Failed to send session announcement: $e');
    }
  }

  void _handleDiscoveryData(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;

    try {
      final packet = _discoverySocket!.receive();
      if (packet == null) return;

      final data = utf8.decode(packet.data);
      final messageJson = jsonDecode(data) as Map<String, dynamic>;
      final message = NetworkMessage.fromJson(messageJson);

      switch (message.type) {
        case MessageType.sessionDiscovery:
          _handleSessionDiscoveryRequest(message);
          break;
        case MessageType.sessionAnnouncement:
          _handleSessionAnnouncement(message);
          break;
        default:
          break;
      }
    } catch (e) {
      _logger.w('Failed to handle discovery data: $e');
    }
  }

  void _handleSessionDiscoveryRequest(NetworkMessage message) {
    if (_isAnnouncing && _currentSession != null) {
      _sendSessionAnnouncement();
    }
  }

  void _handleSessionAnnouncement(NetworkMessage message) {
    try {
      final announcement = SessionAnnouncement.fromJson(message.payload);
      
      // Don't announce our own session back to ourselves
      if (announcement.hostId == _currentSession?.hostId) {
        return;
      }
      
      _sessionsController.add(announcement);
    } catch (e) {
      _logger.w('Failed to parse session announcement: $e');
    }
  }

  Future<String?> _getLocalIPAddress() async {
    try {
      final info = NetworkInfo();
      return await info.getWifiIP();
    } catch (e) {
      _logger.w('Failed to get local IP address: $e');
      return null;
    }
  }

  String _getDeviceName() {
    final platformInfo = PlatformService.instance.platformInfo;
    return platformInfo.deviceModel;
  }

  String _getDeviceInfo() {
    final platformInfo = PlatformService.instance.platformInfo;
    return '${platformInfo.deviceType.name} - ${platformInfo.platformType.name}';
  }

  bool _canUseLocalNetworking() {
    return PlatformService.instance.platformInfo.supportsLocalNetworking;
  }
}