import 'package:json_annotation/json_annotation.dart';

part 'game_state.g.dart';

enum GamePhase {
  lobby,
  briefing,
  investigation,
  travel,
  results,
  gameOver,
}

enum PlayerRole {
  host,
  detective,
  observer,
}

enum DetectiveRank {
  rookie,
  detective,
  seniorDetective,
  inspector,
  chiefInspector,
  superintendent,
}

@JsonSerializable()
class Player {
  final String id;
  final String name;
  final PlayerRole role;
  final DetectiveRank rank;
  final String? avatarUrl;
  final bool isConnected;
  
  const Player({
    required this.id,
    required this.name,
    required this.role,
    this.rank = DetectiveRank.rookie,
    this.avatarUrl,
    this.isConnected = true,
  });

  Player copyWith({
    String? id,
    String? name,
    PlayerRole? role,
    DetectiveRank? rank,
    String? avatarUrl,
    bool? isConnected,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      rank: rank ?? this.rank,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}

@JsonSerializable()
class GameSession {
  final String sessionId;
  final String hostId;
  final String sessionName;
  final List<Player> players;
  final GamePhase currentPhase;
  final int maxPlayers;
  final DateTime createdAt;
  final DateTime? startedAt;
  final Map<String, dynamic> settings;
  
  const GameSession({
    required this.sessionId,
    required this.hostId,
    required this.sessionName,
    required this.players,
    this.currentPhase = GamePhase.lobby,
    this.maxPlayers = 6,
    required this.createdAt,
    this.startedAt,
    this.settings = const {},
  });

  GameSession copyWith({
    String? sessionId,
    String? hostId,
    String? sessionName,
    List<Player>? players,
    GamePhase? currentPhase,
    int? maxPlayers,
    DateTime? createdAt,
    DateTime? startedAt,
    Map<String, dynamic>? settings,
  }) {
    return GameSession(
      sessionId: sessionId ?? this.sessionId,
      hostId: hostId ?? this.hostId,
      sessionName: sessionName ?? this.sessionName,
      players: players ?? this.players,
      currentPhase: currentPhase ?? this.currentPhase,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      settings: settings ?? this.settings,
    );
  }

  bool get isHost => players.any((p) => p.role == PlayerRole.host);
  bool get canStart => players.length >= 2;
  bool get isFull => players.length >= maxPlayers;
  
  Player? getPlayerById(String playerId) {
    try {
      return players.firstWhere((p) => p.id == playerId);
    } catch (e) {
      return null;
    }
  }

  factory GameSession.fromJson(Map<String, dynamic> json) => _$GameSessionFromJson(json);
  Map<String, dynamic> toJson() => _$GameSessionToJson(this);
}

@JsonSerializable()
class GameState {
  final GameSession session;
  final String? currentCaseId;
  final int currentBudget;
  final int remainingTime;
  final List<String> visitedLocations;
  final Map<String, dynamic> gameData;
  final DateTime lastUpdate;
  
  const GameState({
    required this.session,
    this.currentCaseId,
    this.currentBudget = 5000,
    this.remainingTime = 180,
    this.visitedLocations = const [],
    this.gameData = const {},
    required this.lastUpdate,
  });

  GameState copyWith({
    GameSession? session,
    String? currentCaseId,
    int? currentBudget,
    int? remainingTime,
    List<String>? visitedLocations,
    Map<String, dynamic>? gameData,
    DateTime? lastUpdate,
  }) {
    return GameState(
      session: session ?? this.session,
      currentCaseId: currentCaseId ?? this.currentCaseId,
      currentBudget: currentBudget ?? this.currentBudget,
      remainingTime: remainingTime ?? this.remainingTime,
      visitedLocations: visitedLocations ?? this.visitedLocations,
      gameData: gameData ?? this.gameData,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  factory GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);
  Map<String, dynamic> toJson() => _$GameStateToJson(this);
}