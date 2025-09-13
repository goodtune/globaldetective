part of 'game_state_bloc.dart';

abstract class GameStateEvent extends Equatable {
  const GameStateEvent();

  @override
  List<Object?> get props => [];
}

class GameStateInitialized extends GameStateEvent {
  final GameState gameState;

  const GameStateInitialized(this.gameState);

  @override
  List<Object> get props => [gameState];
}

class GameStateUpdated extends GameStateEvent {
  final GameState gameState;

  const GameStateUpdated(this.gameState);

  @override
  List<Object> get props => [gameState];
}

class GameStateCleared extends GameStateEvent {
  const GameStateCleared();
}

class PlayerJoined extends GameStateEvent {
  final Player player;

  const PlayerJoined(this.player);

  @override
  List<Object> get props => [player];
}

class PlayerLeft extends GameStateEvent {
  final String playerId;

  const PlayerLeft(this.playerId);

  @override
  List<Object> get props => [playerId];
}

class GamePhaseChanged extends GameStateEvent {
  final GamePhase newPhase;

  const GamePhaseChanged(this.newPhase);

  @override
  List<Object> get props => [newPhase];
}