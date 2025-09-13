// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkMessage _$NetworkMessageFromJson(Map<String, dynamic> json) =>
    NetworkMessage(
      messageId: json['messageId'] as String,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      senderId: json['senderId'] as String,
      sessionId: json['sessionId'] as String?,
      payload: json['payload'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$NetworkMessageToJson(NetworkMessage instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'senderId': instance.senderId,
      'sessionId': instance.sessionId,
      'payload': instance.payload,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$MessageTypeEnumMap = {
  MessageType.sessionDiscovery: 'sessionDiscovery',
  MessageType.sessionAnnouncement: 'sessionAnnouncement',
  MessageType.joinRequest: 'joinRequest',
  MessageType.joinResponse: 'joinResponse',
  MessageType.playerUpdate: 'playerUpdate',
  MessageType.gameStateUpdate: 'gameStateUpdate',
  MessageType.gameAction: 'gameAction',
  MessageType.heartbeat: 'heartbeat',
  MessageType.disconnect: 'disconnect',
  MessageType.error: 'error',
};

SessionDiscoveryRequest _$SessionDiscoveryRequestFromJson(
  Map<String, dynamic> json,
) => SessionDiscoveryRequest(
  requesterId: json['requesterId'] as String,
  requesterName: json['requesterName'] as String,
  deviceInfo: json['deviceInfo'] as String,
);

Map<String, dynamic> _$SessionDiscoveryRequestToJson(
  SessionDiscoveryRequest instance,
) => <String, dynamic>{
  'requesterId': instance.requesterId,
  'requesterName': instance.requesterName,
  'deviceInfo': instance.deviceInfo,
};

SessionAnnouncement _$SessionAnnouncementFromJson(Map<String, dynamic> json) =>
    SessionAnnouncement(
      sessionId: json['sessionId'] as String,
      sessionName: json['sessionName'] as String,
      hostId: json['hostId'] as String,
      hostName: json['hostName'] as String,
      currentPlayers: (json['currentPlayers'] as num).toInt(),
      maxPlayers: (json['maxPlayers'] as num).toInt(),
      gamePhase: json['gamePhase'] as String,
      requiresPassword: json['requiresPassword'] as bool,
      hostAddress: json['hostAddress'] as String,
      hostPort: (json['hostPort'] as num).toInt(),
    );

Map<String, dynamic> _$SessionAnnouncementToJson(
  SessionAnnouncement instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'sessionName': instance.sessionName,
  'hostId': instance.hostId,
  'hostName': instance.hostName,
  'currentPlayers': instance.currentPlayers,
  'maxPlayers': instance.maxPlayers,
  'gamePhase': instance.gamePhase,
  'requiresPassword': instance.requiresPassword,
  'hostAddress': instance.hostAddress,
  'hostPort': instance.hostPort,
};

JoinRequest _$JoinRequestFromJson(Map<String, dynamic> json) => JoinRequest(
  playerId: json['playerId'] as String,
  playerName: json['playerName'] as String,
  deviceInfo: json['deviceInfo'] as String,
  password: json['password'] as String?,
);

Map<String, dynamic> _$JoinRequestToJson(JoinRequest instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'playerName': instance.playerName,
      'deviceInfo': instance.deviceInfo,
      'password': instance.password,
    };

JoinResponse _$JoinResponseFromJson(Map<String, dynamic> json) => JoinResponse(
  accepted: json['accepted'] as bool,
  reason: json['reason'] as String?,
  assignedPlayerId: json['assignedPlayerId'] as String?,
  gameState: json['gameState'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$JoinResponseToJson(JoinResponse instance) =>
    <String, dynamic>{
      'accepted': instance.accepted,
      'reason': instance.reason,
      'assignedPlayerId': instance.assignedPlayerId,
      'gameState': instance.gameState,
    };
