part of 'network_bloc.dart';

abstract class NetworkEvent extends Equatable {
  const NetworkEvent();

  @override
  List<Object?> get props => [];
}

class NetworkInitialized extends NetworkEvent {
  const NetworkInitialized();
}

class DiscoveryStarted extends NetworkEvent {
  const DiscoveryStarted();
}

class DiscoverySessionFound extends NetworkEvent {
  final SessionAnnouncement session;

  const DiscoverySessionFound(this.session);

  @override
  List<Object> get props => [session];
}

class DiscoveryStopped extends NetworkEvent {
  const DiscoveryStopped();
}

class ServerStarted extends NetworkEvent {
  final String sessionName;
  final String hostPlayerName;
  final int port;

  const ServerStarted({
    required this.sessionName,
    required this.hostPlayerName,
    this.port = 8080,
  });

  @override
  List<Object> get props => [sessionName, hostPlayerName, port];
}

class ServerStopped extends NetworkEvent {
  const ServerStopped();
}

class ServerStatusUpdated extends NetworkEvent {
  final bool isRunning;
  final int connectedPlayers;

  const ServerStatusUpdated({
    required this.isRunning,
    required this.connectedPlayers,
  });

  @override
  List<Object> get props => [isRunning, connectedPlayers];
}