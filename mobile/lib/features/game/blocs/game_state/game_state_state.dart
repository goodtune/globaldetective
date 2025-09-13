part of 'game_state_bloc.dart';

enum GameStateStatus {
  initial,
  loading,
  loaded,
  error,
}

class GameStateBlocState extends Equatable {
  final GameState? gameState;
  final GameStateStatus status;
  final String? errorMessage;

  const GameStateBlocState({
    this.gameState,
    this.status = GameStateStatus.initial,
    this.errorMessage,
  });

  GameStateBlocState copyWith({
    GameState? gameState,
    GameStateStatus? status,
    String? errorMessage,
  }) {
    return GameStateBlocState(
      gameState: gameState ?? this.gameState,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [gameState, status, errorMessage];

  // Computed properties
  bool get hasGameState => gameState != null;
  bool get isHost => gameState?.session.players.any((p) => p.role == PlayerRole.host) ?? false;
  bool get canStartGame => 
      gameState?.session.canStart == true && 
      gameState?.session.currentPhase == GamePhase.lobby;
  
  Player? get currentPlayer => 
      gameState?.session.players.isNotEmpty == true
          ? gameState!.session.players.first 
          : null;

  List<Player> get connectedPlayers => gameState?.session.players ?? [];

  // JSON serialization for HydratedBloc
  factory GameStateBlocState.fromJson(Map<String, dynamic> json) {
    return GameStateBlocState(
      gameState: json['gameState'] != null 
          ? GameState.fromJson(json['gameState'] as Map<String, dynamic>)
          : null,
      status: GameStateStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GameStateStatus.initial,
      ),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameState': gameState?.toJson(),
      'status': status.name,
      'errorMessage': errorMessage,
    };
  }
}