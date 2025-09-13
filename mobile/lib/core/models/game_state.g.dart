// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
  id: json['id'] as String,
  name: json['name'] as String,
  role: $enumDecode(_$PlayerRoleEnumMap, json['role']),
  rank:
      $enumDecodeNullable(_$DetectiveRankEnumMap, json['rank']) ??
      DetectiveRank.rookie,
  avatarUrl: json['avatarUrl'] as String?,
  isConnected: json['isConnected'] as bool? ?? true,
);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'role': _$PlayerRoleEnumMap[instance.role]!,
  'rank': _$DetectiveRankEnumMap[instance.rank]!,
  'avatarUrl': instance.avatarUrl,
  'isConnected': instance.isConnected,
};

const _$PlayerRoleEnumMap = {
  PlayerRole.host: 'host',
  PlayerRole.detective: 'detective',
  PlayerRole.observer: 'observer',
};

const _$DetectiveRankEnumMap = {
  DetectiveRank.rookie: 'rookie',
  DetectiveRank.detective: 'detective',
  DetectiveRank.seniorDetective: 'seniorDetective',
  DetectiveRank.inspector: 'inspector',
  DetectiveRank.chiefInspector: 'chiefInspector',
  DetectiveRank.superintendent: 'superintendent',
};

GameSession _$GameSessionFromJson(Map<String, dynamic> json) => GameSession(
  sessionId: json['sessionId'] as String,
  hostId: json['hostId'] as String,
  sessionName: json['sessionName'] as String,
  players: (json['players'] as List<dynamic>)
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .toList(),
  currentPhase:
      $enumDecodeNullable(_$GamePhaseEnumMap, json['currentPhase']) ??
      GamePhase.lobby,
  maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 6,
  createdAt: DateTime.parse(json['createdAt'] as String),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  settings: json['settings'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$GameSessionToJson(GameSession instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'hostId': instance.hostId,
      'sessionName': instance.sessionName,
      'players': instance.players,
      'currentPhase': _$GamePhaseEnumMap[instance.currentPhase]!,
      'maxPlayers': instance.maxPlayers,
      'createdAt': instance.createdAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'settings': instance.settings,
    };

const _$GamePhaseEnumMap = {
  GamePhase.lobby: 'lobby',
  GamePhase.briefing: 'briefing',
  GamePhase.investigation: 'investigation',
  GamePhase.travel: 'travel',
  GamePhase.results: 'results',
  GamePhase.gameOver: 'gameOver',
};

GameState _$GameStateFromJson(Map<String, dynamic> json) => GameState(
  session: GameSession.fromJson(json['session'] as Map<String, dynamic>),
  currentCaseId: json['currentCaseId'] as String?,
  currentBudget: (json['currentBudget'] as num?)?.toInt() ?? 5000,
  remainingTime: (json['remainingTime'] as num?)?.toInt() ?? 180,
  visitedLocations:
      (json['visitedLocations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  gameData: json['gameData'] as Map<String, dynamic>? ?? const {},
  lastUpdate: DateTime.parse(json['lastUpdate'] as String),
);

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
  'session': instance.session,
  'currentCaseId': instance.currentCaseId,
  'currentBudget': instance.currentBudget,
  'remainingTime': instance.remainingTime,
  'visitedLocations': instance.visitedLocations,
  'gameData': instance.gameData,
  'lastUpdate': instance.lastUpdate.toIso8601String(),
};
