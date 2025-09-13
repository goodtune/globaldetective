import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/game_state.dart';
import '../models/network_message.dart';
import 'network_discovery_service.dart';

class GameServer {
  static GameServer? _instance;
  static GameServer get instance {
    _instance ??= GameServer._();
    return _instance!;
  }

  GameServer._();

  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  HttpServer? _httpServer;
  GameState? _gameState;
  final Map<String, WebSocketChannel> _clients = {};
  final Map<String, Player> _players = {};
  
  Timer? _heartbeatTimer;
  bool _isRunning = false;
  
  final StreamController<GameState> _gameStateController = 
      StreamController<GameState>.broadcast();
  final StreamController<Player> _playerJoinedController = 
      StreamController<Player>.broadcast();
  final StreamController<String> _playerLeftController = 
      StreamController<String>.broadcast();

  Stream<GameState> get gameStateStream => _gameStateController.stream;
  Stream<Player> get playerJoinedStream => _playerJoinedController.stream;
  Stream<String> get playerLeftStream => _playerLeftController.stream;

  bool get isRunning => _isRunning;
  GameState? get currentGameState => _gameState;
  List<Player> get connectedPlayers => _players.values.toList();

  Future<bool> startServer({
    required String sessionName,
    required String hostPlayerName,
    int port = AppConstants.defaultPort,
  }) async {
    if (_isRunning) {
      _logger.w('Server is already running');
      return false;
    }

    try {
      final hostPlayer = Player(
        id: _uuid.v4(),
        name: hostPlayerName,
        role: PlayerRole.host,
        rank: DetectiveRank.detective,
      );

      final session = GameSession(
        sessionId: _uuid.v4(),
        hostId: hostPlayer.id,
        sessionName: sessionName,
        players: [hostPlayer],
        createdAt: DateTime.now(),
      );

      _gameState = GameState(
        session: session,
        lastUpdate: DateTime.now(),
      );

      _players[hostPlayer.id] = hostPlayer;

      final handler = shelf.Pipeline()
          .addMiddleware(shelf.logRequests())
          .addHandler(_createHandler());

      _httpServer = await shelf_io.serve(
        handler,
        InternetAddress.anyIPv4,
        port,
      );

      _startHeartbeat();
      _startAnnouncing();
      
      _isRunning = true;
      _logger.i('Game server started on port $port');
      
      return true;
    } catch (e) {
      _logger.e('Failed to start server: $e');
      return false;
    }
  }

  Future<void> stopServer() async {
    if (!_isRunning) return;

    _heartbeatTimer?.cancel();
    await NetworkDiscoveryService.instance.stopAnnouncing();
    
    // Disconnect all clients
    for (final client in _clients.values) {
      try {
        client.sink.close();
      } catch (e) {
        _logger.w('Error closing client connection: $e');
      }
    }
    _clients.clear();
    _players.clear();

    await _httpServer?.close();
    _httpServer = null;
    _gameState = null;
    
    _isRunning = false;
    _logger.i('Game server stopped');
  }

  shelf.Handler _createHandler() {
    return shelf.Cascade()
        .add(_createWebSocketHandler())
        .add(_createApiHandler())
        .handler;
  }

  shelf.Handler _createWebSocketHandler() {
    return webSocketHandler((WebSocketChannel webSocket) {
      final clientId = _uuid.v4();
      _clients[clientId] = webSocket;
      
      _logger.i('Client connected: $clientId');
      
      webSocket.stream.listen(
        (data) => _handleClientMessage(clientId, data),
        onDone: () => _handleClientDisconnect(clientId),
        onError: (error) => _handleClientError(clientId, error),
      );
    });
  }

  shelf.Handler _createApiHandler() {
    return (shelf.Request request) {
      if (request.method == 'GET' && request.url.path == 'status') {
        return shelf.Response.ok(
          jsonEncode({
            'status': 'running',
            'session': _gameState?.session.toJson(),
            'players': _players.length,
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      return shelf.Response.notFound('Not Found');
    };
  }

  void _handleClientMessage(String clientId, dynamic data) {
    try {
      final messageJson = jsonDecode(data as String) as Map<String, dynamic>;
      final message = NetworkMessage.fromJson(messageJson);
      
      switch (message.type) {
        case MessageType.joinRequest:
          _handleJoinRequest(clientId, message);
          break;
        case MessageType.playerUpdate:
          _handlePlayerUpdate(clientId, message);
          break;
        case MessageType.gameAction:
          _handleGameAction(clientId, message);
          break;
        case MessageType.heartbeat:
          // Client is alive, no action needed
          break;
        default:
          _logger.w('Unhandled message type: ${message.type}');
      }
    } catch (e) {
      _logger.e('Failed to handle client message: $e');
      _sendErrorToClient(clientId, 'Invalid message format');
    }
  }

  void _handleJoinRequest(String clientId, NetworkMessage message) {
    try {
      final joinRequest = JoinRequest.fromJson(message.payload);
      
      if (_gameState == null) {
        _sendJoinResponse(clientId, false, 'Server not ready');
        return;
      }

      if (_gameState!.session.isFull) {
        _sendJoinResponse(clientId, false, 'Session is full');
        return;
      }

      if (_gameState!.session.currentPhase != GamePhase.lobby) {
        _sendJoinResponse(clientId, false, 'Game already in progress');
        return;
      }

      final newPlayer = Player(
        id: joinRequest.playerId,
        name: joinRequest.playerName,
        role: PlayerRole.detective,
      );

      _players[newPlayer.id] = newPlayer;
      
      final updatedSession = _gameState!.session.copyWith(
        players: [..._gameState!.session.players, newPlayer],
      );
      
      _gameState = _gameState!.copyWith(
        session: updatedSession,
        lastUpdate: DateTime.now(),
      );

      _sendJoinResponse(clientId, true, null, newPlayer.id);
      _broadcastGameState();
      _playerJoinedController.add(newPlayer);
      
      _logger.i('Player joined: ${newPlayer.name}');
    } catch (e) {
      _logger.e('Failed to handle join request: $e');
      _sendJoinResponse(clientId, false, 'Internal server error');
    }
  }

  void _handlePlayerUpdate(String clientId, NetworkMessage message) {
    // Handle player status updates
  }

  void _handleGameAction(String clientId, NetworkMessage message) {
    // Handle game actions from players
  }

  void _handleClientDisconnect(String clientId) {
    _clients.remove(clientId);
    
    // Find and remove the player associated with this client
    final disconnectedPlayerId = _players.entries
        .where((entry) => entry.key == clientId)
        .map((entry) => entry.value.id)
        .firstOrNull;
    
    if (disconnectedPlayerId != null) {
      _players.remove(disconnectedPlayerId);
      _playerLeftController.add(disconnectedPlayerId);
      
      if (_gameState != null) {
        final updatedPlayers = _gameState!.session.players
            .where((p) => p.id != disconnectedPlayerId)
            .toList();
        
        final updatedSession = _gameState!.session.copyWith(players: updatedPlayers);
        _gameState = _gameState!.copyWith(
          session: updatedSession,
          lastUpdate: DateTime.now(),
        );
        
        _broadcastGameState();
      }
    }
    
    _logger.i('Client disconnected: $clientId');
  }

  void _handleClientError(String clientId, dynamic error) {
    _logger.e('Client error ($clientId): $error');
  }

  void _sendJoinResponse(String clientId, bool accepted, String? reason, [String? playerId]) {
    final response = JoinResponse(
      accepted: accepted,
      reason: reason,
      assignedPlayerId: playerId,
      gameState: accepted ? _gameState?.toJson() : null,
    );

    final message = NetworkMessage(
      messageId: _uuid.v4(),
      type: MessageType.joinResponse,
      senderId: _gameState?.session.hostId ?? '',
      payload: response.toJson(),
      timestamp: DateTime.now(),
    );

    _sendToClient(clientId, message);
  }

  void _sendErrorToClient(String clientId, String error) {
    final message = NetworkMessage(
      messageId: _uuid.v4(),
      type: MessageType.error,
      senderId: _gameState?.session.hostId ?? '',
      payload: {'error': error},
      timestamp: DateTime.now(),
    );

    _sendToClient(clientId, message);
  }

  void _sendToClient(String clientId, NetworkMessage message) {
    final client = _clients[clientId];
    if (client != null) {
      try {
        client.sink.add(jsonEncode(message.toJson()));
      } catch (e) {
        _logger.e('Failed to send message to client $clientId: $e');
      }
    }
  }

  void _broadcastMessage(NetworkMessage message) {
    for (final clientId in _clients.keys) {
      _sendToClient(clientId, message);
    }
  }

  void _broadcastGameState() {
    if (_gameState == null) return;

    final message = NetworkMessage(
      messageId: _uuid.v4(),
      type: MessageType.gameStateUpdate,
      senderId: _gameState!.session.hostId,
      sessionId: _gameState!.session.sessionId,
      payload: _gameState!.toJson(),
      timestamp: DateTime.now(),
    );

    _broadcastMessage(message);
    _gameStateController.add(_gameState!);
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(AppConstants.heartbeatInterval, (_) {
      final message = NetworkMessage(
        messageId: _uuid.v4(),
        type: MessageType.heartbeat,
        senderId: _gameState?.session.hostId ?? '',
        payload: {'timestamp': DateTime.now().toIso8601String()},
        timestamp: DateTime.now(),
      );

      _broadcastMessage(message);
    });
  }

  void _startAnnouncing() async {
    if (_gameState == null) return;

    final announcement = SessionAnnouncement(
      sessionId: _gameState!.session.sessionId,
      sessionName: _gameState!.session.sessionName,
      hostId: _gameState!.session.hostId,
      hostName: _players[_gameState!.session.hostId]?.name ?? 'Host',
      currentPlayers: _gameState!.session.players.length,
      maxPlayers: _gameState!.session.maxPlayers,
      gamePhase: _gameState!.session.currentPhase.name,
      requiresPassword: false,
      hostAddress: '0.0.0.0', // Will be determined by clients
      hostPort: _httpServer?.port ?? AppConstants.defaultPort,
    );

    await NetworkDiscoveryService.instance.startAnnouncing(announcement);
  }

  void dispose() {
    stopServer();
    _gameStateController.close();
    _playerJoinedController.close();
    _playerLeftController.close();
  }
}