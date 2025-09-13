import 'package:json_annotation/json_annotation.dart';

part 'network_message.g.dart';

enum MessageType {
  sessionDiscovery,
  sessionAnnouncement,
  joinRequest,
  joinResponse,
  playerUpdate,
  gameStateUpdate,
  gameAction,
  heartbeat,
  disconnect,
  error,
}

@JsonSerializable()
class NetworkMessage {
  final String messageId;
  final MessageType type;
  final String senderId;
  final String? sessionId;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  const NetworkMessage({
    required this.messageId,
    required this.type,
    required this.senderId,
    this.sessionId,
    required this.payload,
    required this.timestamp,
  });

  factory NetworkMessage.fromJson(Map<String, dynamic> json) => _$NetworkMessageFromJson(json);
  Map<String, dynamic> toJson() => _$NetworkMessageToJson(this);
  
  @override
  String toString() {
    return 'NetworkMessage(id: $messageId, type: $type, sender: $senderId, session: $sessionId)';
  }
}

@JsonSerializable()
class SessionDiscoveryRequest {
  final String requesterId;
  final String requesterName;
  final String deviceInfo;

  const SessionDiscoveryRequest({
    required this.requesterId,
    required this.requesterName,
    required this.deviceInfo,
  });

  factory SessionDiscoveryRequest.fromJson(Map<String, dynamic> json) => _$SessionDiscoveryRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SessionDiscoveryRequestToJson(this);
}

@JsonSerializable()
class SessionAnnouncement {
  final String sessionId;
  final String sessionName;
  final String hostId;
  final String hostName;
  final int currentPlayers;
  final int maxPlayers;
  final String gamePhase;
  final bool requiresPassword;
  final String hostAddress;
  final int hostPort;

  const SessionAnnouncement({
    required this.sessionId,
    required this.sessionName,
    required this.hostId,
    required this.hostName,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.gamePhase,
    required this.requiresPassword,
    required this.hostAddress,
    required this.hostPort,
  });

  factory SessionAnnouncement.fromJson(Map<String, dynamic> json) => _$SessionAnnouncementFromJson(json);
  Map<String, dynamic> toJson() => _$SessionAnnouncementToJson(this);
}

@JsonSerializable()
class JoinRequest {
  final String playerId;
  final String playerName;
  final String deviceInfo;
  final String? password;

  const JoinRequest({
    required this.playerId,
    required this.playerName,
    required this.deviceInfo,
    this.password,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) => _$JoinRequestFromJson(json);
  Map<String, dynamic> toJson() => _$JoinRequestToJson(this);
}

@JsonSerializable()
class JoinResponse {
  final bool accepted;
  final String? reason;
  final String? assignedPlayerId;
  final Map<String, dynamic>? gameState;

  const JoinResponse({
    required this.accepted,
    this.reason,
    this.assignedPlayerId,
    this.gameState,
  });

  factory JoinResponse.fromJson(Map<String, dynamic> json) => _$JoinResponseFromJson(json);
  Map<String, dynamic> toJson() => _$JoinResponseToJson(this);
}