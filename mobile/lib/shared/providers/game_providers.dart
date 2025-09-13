import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/game_state.dart';
import '../../core/services/platform_service.dart';
import '../../features/networking/services/game_server.dart';
import '../../features/networking/services/network_discovery_service.dart';
import '../../features/networking/models/network_message.dart';

// Platform provider
final platformProvider = Provider((ref) {
  return PlatformService.instance.platformInfo;
});

// Current game state provider
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState?>((ref) {
  return GameStateNotifier();
});

// Available sessions provider for discovery
final availableSessionsProvider = StateNotifierProvider<AvailableSessionsNotifier, List<SessionAnnouncement>>((ref) {
  return AvailableSessionsNotifier();
});

// Server status provider
final serverStatusProvider = StateNotifierProvider<ServerStatusNotifier, ServerStatus>((ref) {
  return ServerStatusNotifier();
});

// Connected players provider
final connectedPlayersProvider = StateNotifierProvider<ConnectedPlayersNotifier, List<Player>>((ref) {
  return ConnectedPlayersNotifier();
});

// Game state notifier
class GameStateNotifier extends StateNotifier<GameState?> {
  GameStateNotifier() : super(null) {
    _initializeListeners();
  }

  void _initializeListeners() {
    // Listen to game server state changes
    GameServer.instance.gameStateStream.listen((gameState) {
      state = gameState;
    });
  }

  void updateGameState(GameState newState) {
    state = newState;
  }

  void clearGameState() {
    state = null;
  }
}

// Available sessions notifier
class AvailableSessionsNotifier extends StateNotifier<List<SessionAnnouncement>> {
  AvailableSessionsNotifier() : super([]) {
    _initializeDiscovery();
  }

  void _initializeDiscovery() {
    NetworkDiscoveryService.instance.sessionsStream.listen((announcement) {
      // Remove existing announcement from same host if exists
      final filteredSessions = state.where((s) => s.hostId != announcement.hostId).toList();
      state = [...filteredSessions, announcement];
    });
  }

  Future<void> startDiscovery() async {
    await NetworkDiscoveryService.instance.initialize();
    await NetworkDiscoveryService.instance.startDiscovery();
  }

  Future<void> stopDiscovery() async {
    await NetworkDiscoveryService.instance.stopDiscovery();
    state = [];
  }

  void clearSessions() {
    state = [];
  }
}

// Server status
enum ServerState {
  stopped,
  starting,
  running,
  stopping,
  error,
}

class ServerStatus {
  final ServerState state;
  final String? sessionName;
  final int? port;
  final String? errorMessage;
  final int connectedPlayers;

  const ServerStatus({
    required this.state,
    this.sessionName,
    this.port,
    this.errorMessage,
    this.connectedPlayers = 0,
  });

  ServerStatus copyWith({
    ServerState? state,
    String? sessionName,
    int? port,
    String? errorMessage,
    int? connectedPlayers,
  }) {
    return ServerStatus(
      state: state ?? this.state,
      sessionName: sessionName ?? this.sessionName,
      port: port ?? this.port,
      errorMessage: errorMessage ?? this.errorMessage,
      connectedPlayers: connectedPlayers ?? this.connectedPlayers,
    );
  }

  bool get isRunning => state == ServerState.running;
  bool get isStopped => state == ServerState.stopped;
  bool get hasError => state == ServerState.error;
}

// Server status notifier
class ServerStatusNotifier extends StateNotifier<ServerStatus> {
  ServerStatusNotifier() : super(const ServerStatus(state: ServerState.stopped)) {
    _initializeListeners();
  }

  void _initializeListeners() {
    // Listen to server state changes
    GameServer.instance.gameStateStream.listen((gameState) {
      if (GameServer.instance.isRunning) {
        state = state.copyWith(
          state: ServerState.running,
          sessionName: gameState.session.sessionName,
          connectedPlayers: gameState.session.players.length,
        );
      }
    });
  }

  Future<void> startServer({
    required String sessionName,
    required String hostPlayerName,
    int? port,
  }) async {
    state = state.copyWith(state: ServerState.starting);

    try {
      final success = await GameServer.instance.startServer(
        sessionName: sessionName,
        hostPlayerName: hostPlayerName,
        port: port ?? 8080,
      );

      if (success) {
        state = state.copyWith(
          state: ServerState.running,
          sessionName: sessionName,
          port: port ?? 8080,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          state: ServerState.error,
          errorMessage: 'Failed to start server',
        );
      }
    } catch (e) {
      state = state.copyWith(
        state: ServerState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> stopServer() async {
    state = state.copyWith(state: ServerState.stopping);

    try {
      await GameServer.instance.stopServer();
      state = const ServerStatus(state: ServerState.stopped);
    } catch (e) {
      state = state.copyWith(
        state: ServerState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() {
    if (state.hasError) {
      state = state.copyWith(
        state: ServerState.stopped,
        errorMessage: null,
      );
    }
  }
}

// Connected players notifier
class ConnectedPlayersNotifier extends StateNotifier<List<Player>> {
  ConnectedPlayersNotifier() : super([]) {
    _initializeListeners();
  }

  void _initializeListeners() {
    // Listen to player join events
    GameServer.instance.playerJoinedStream.listen((player) {
      state = [...state, player];
    });

    // Listen to player leave events
    GameServer.instance.playerLeftStream.listen((playerId) {
      state = state.where((p) => p.id != playerId).toList();
    });

    // Listen to game state updates to sync player list
    GameServer.instance.gameStateStream.listen((gameState) {
      state = gameState.session.players;
    });
  }

  void updatePlayers(List<Player> players) {
    state = players;
  }

  void addPlayer(Player player) {
    if (!state.any((p) => p.id == player.id)) {
      state = [...state, player];
    }
  }

  void removePlayer(String playerId) {
    state = state.where((p) => p.id != playerId).toList();
  }

  void clearPlayers() {
    state = [];
  }
}

// Utility providers for computed values
final isHostProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameStateProvider);
  
  if (gameState == null) return false;
  
  final hostPlayer = gameState.session.players
      .where((p) => p.role == PlayerRole.host)
      .firstOrNull;
  
  return hostPlayer != null;
});

final canStartGameProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameStateProvider);
  
  if (gameState == null) return false;
  
  return gameState.session.canStart && 
         gameState.session.currentPhase == GamePhase.lobby;
});

final currentPlayerProvider = Provider<Player?>((ref) {
  final gameState = ref.watch(gameStateProvider);
  
  if (gameState == null) return null;
  
  // In a real implementation, you'd track the current device's player ID
  // For now, return the first player as a placeholder
  return gameState.session.players.isNotEmpty 
      ? gameState.session.players.first 
      : null;
});