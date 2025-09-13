part of 'network_bloc.dart';

enum NetworkStatus {
  initial,
  initializing,
  ready,
  error,
}

enum DiscoveryStatus {
  idle,
  discovering,
  found,
  error,
}

enum ServerStatus {
  stopped,
  starting,
  running,
  stopping,
  error,
}

class NetworkState extends Equatable {
  final NetworkStatus status;
  final DiscoveryStatus discoveryStatus;
  final ServerStatus serverStatus;
  final List<SessionAnnouncement> availableSessions;
  final String? sessionName;
  final String? hostPlayerName;
  final int? serverPort;
  final int connectedPlayers;
  final String? errorMessage;

  const NetworkState({
    this.status = NetworkStatus.initial,
    this.discoveryStatus = DiscoveryStatus.idle,
    this.serverStatus = ServerStatus.stopped,
    this.availableSessions = const [],
    this.sessionName,
    this.hostPlayerName,
    this.serverPort,
    this.connectedPlayers = 0,
    this.errorMessage,
  });

  NetworkState copyWith({
    NetworkStatus? status,
    DiscoveryStatus? discoveryStatus,
    ServerStatus? serverStatus,
    List<SessionAnnouncement>? availableSessions,
    String? sessionName,
    String? hostPlayerName,
    int? serverPort,
    int? connectedPlayers,
    String? errorMessage,
  }) {
    return NetworkState(
      status: status ?? this.status,
      discoveryStatus: discoveryStatus ?? this.discoveryStatus,
      serverStatus: serverStatus ?? this.serverStatus,
      availableSessions: availableSessions ?? this.availableSessions,
      sessionName: sessionName ?? this.sessionName,
      hostPlayerName: hostPlayerName ?? this.hostPlayerName,
      serverPort: serverPort ?? this.serverPort,
      connectedPlayers: connectedPlayers ?? this.connectedPlayers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        discoveryStatus,
        serverStatus,
        availableSessions,
        sessionName,
        hostPlayerName,
        serverPort,
        connectedPlayers,
        errorMessage,
      ];

  // Computed properties
  bool get isNetworkReady => status == NetworkStatus.ready;
  bool get isDiscovering => discoveryStatus == DiscoveryStatus.discovering;
  bool get isServerRunning => serverStatus == ServerStatus.running;
  bool get isServerStopped => serverStatus == ServerStatus.stopped;
  bool get hasError => status == NetworkStatus.error || 
                       discoveryStatus == DiscoveryStatus.error || 
                       serverStatus == ServerStatus.error;
  bool get hasAvailableSessions => availableSessions.isNotEmpty;
}