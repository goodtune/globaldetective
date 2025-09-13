import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/network_message.dart';
import '../services/game_server.dart';
import '../services/network_discovery_service.dart';
import '../../../core/models/game_state.dart';

part 'network_event.dart';
part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  late StreamSubscription<SessionAnnouncement> _sessionsSubscription;
  late StreamSubscription<GameState> _gameStateSubscription;
  late StreamSubscription<Player> _playerJoinedSubscription;
  late StreamSubscription<String> _playerLeftSubscription;

  NetworkBloc() : super(const NetworkState()) {
    on<NetworkInitialized>(_onNetworkInitialized);
    on<DiscoveryStarted>(_onDiscoveryStarted);
    on<DiscoverySessionFound>(_onDiscoverySessionFound);
    on<DiscoveryStopped>(_onDiscoveryStopped);
    on<ServerStarted>(_onServerStarted);
    on<ServerStopped>(_onServerStopped);
    on<ServerStatusUpdated>(_onServerStatusUpdated);

    _initializeSubscriptions();
  }

  void _initializeSubscriptions() {
    // Listen to network discovery sessions
    _sessionsSubscription = NetworkDiscoveryService.instance.sessionsStream.listen(
      (announcement) => add(DiscoverySessionFound(announcement)),
    );

    // Listen to game server events
    _gameStateSubscription = GameServer.instance.gameStateStream.listen(
      (gameState) => add(ServerStatusUpdated(
        isRunning: true,
        connectedPlayers: gameState.session.players.length,
      )),
    );

    _playerJoinedSubscription = GameServer.instance.playerJoinedStream.listen(
      (player) => add(ServerStatusUpdated(
        isRunning: true,
        connectedPlayers: GameServer.instance.connectedPlayers.length,
      )),
    );

    _playerLeftSubscription = GameServer.instance.playerLeftStream.listen(
      (playerId) => add(ServerStatusUpdated(
        isRunning: true,
        connectedPlayers: GameServer.instance.connectedPlayers.length,
      )),
    );
  }

  void _onNetworkInitialized(
    NetworkInitialized event,
    Emitter<NetworkState> emit,
  ) async {
    emit(state.copyWith(status: NetworkStatus.initializing));
    
    try {
      await NetworkDiscoveryService.instance.initialize();
      emit(state.copyWith(status: NetworkStatus.ready));
    } catch (e) {
      emit(state.copyWith(
        status: NetworkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onDiscoveryStarted(
    DiscoveryStarted event,
    Emitter<NetworkState> emit,
  ) async {
    emit(state.copyWith(
      discoveryStatus: DiscoveryStatus.discovering,
      availableSessions: [],
    ));

    try {
      await NetworkDiscoveryService.instance.startDiscovery();
    } catch (e) {
      emit(state.copyWith(
        discoveryStatus: DiscoveryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onDiscoverySessionFound(
    DiscoverySessionFound event,
    Emitter<NetworkState> emit,
  ) {
    final sessions = List<SessionAnnouncement>.from(state.availableSessions);
    
    // Remove existing session from same host if exists
    sessions.removeWhere((s) => s.hostId == event.session.hostId);
    
    // Add new/updated session
    sessions.add(event.session);
    
    emit(state.copyWith(
      availableSessions: sessions,
      discoveryStatus: DiscoveryStatus.found,
    ));
  }

  void _onDiscoveryStopped(
    DiscoveryStopped event,
    Emitter<NetworkState> emit,
  ) async {
    await NetworkDiscoveryService.instance.stopDiscovery();
    
    emit(state.copyWith(
      discoveryStatus: DiscoveryStatus.idle,
      availableSessions: [],
    ));
  }

  void _onServerStarted(
    ServerStarted event,
    Emitter<NetworkState> emit,
  ) async {
    emit(state.copyWith(serverStatus: ServerStatus.starting));

    try {
      final success = await GameServer.instance.startServer(
        sessionName: event.sessionName,
        hostPlayerName: event.hostPlayerName,
        port: event.port,
      );

      if (success) {
        emit(state.copyWith(
          serverStatus: ServerStatus.running,
          sessionName: event.sessionName,
          hostPlayerName: event.hostPlayerName,
          serverPort: event.port,
        ));
      } else {
        emit(state.copyWith(
          serverStatus: ServerStatus.error,
          errorMessage: 'Failed to start server',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        serverStatus: ServerStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onServerStopped(
    ServerStopped event,
    Emitter<NetworkState> emit,
  ) async {
    emit(state.copyWith(serverStatus: ServerStatus.stopping));

    try {
      await GameServer.instance.stopServer();
      emit(state.copyWith(
        serverStatus: ServerStatus.stopped,
        sessionName: null,
        hostPlayerName: null,
        serverPort: null,
        connectedPlayers: 0,
      ));
    } catch (e) {
      emit(state.copyWith(
        serverStatus: ServerStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onServerStatusUpdated(
    ServerStatusUpdated event,
    Emitter<NetworkState> emit,
  ) {
    emit(state.copyWith(
      serverStatus: event.isRunning ? ServerStatus.running : ServerStatus.stopped,
      connectedPlayers: event.connectedPlayers,
    ));
  }

  @override
  Future<void> close() {
    _sessionsSubscription.cancel();
    _gameStateSubscription.cancel();
    _playerJoinedSubscription.cancel();
    _playerLeftSubscription.cancel();
    return super.close();
  }
}