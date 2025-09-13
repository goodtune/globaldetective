import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../core/models/game_state.dart';

part 'game_state_event.dart';
part 'game_state_state.dart';

class GameStateBloc extends HydratedBloc<GameStateEvent, GameStateBlocState> {
  GameStateBloc() : super(const GameStateBlocState()) {
    on<GameStateInitialized>(_onGameStateInitialized);
    on<GameStateUpdated>(_onGameStateUpdated);
    on<GameStateCleared>(_onGameStateCleared);
    on<PlayerJoined>(_onPlayerJoined);
    on<PlayerLeft>(_onPlayerLeft);
    on<GamePhaseChanged>(_onGamePhaseChanged);
  }

  void _onGameStateInitialized(
    GameStateInitialized event,
    Emitter<GameStateBlocState> emit,
  ) {
    emit(state.copyWith(
      gameState: event.gameState,
      status: GameStateStatus.loaded,
    ));
  }

  void _onGameStateUpdated(
    GameStateUpdated event,
    Emitter<GameStateBlocState> emit,
  ) {
    emit(state.copyWith(
      gameState: event.gameState,
      status: GameStateStatus.loaded,
    ));
  }

  void _onGameStateCleared(
    GameStateCleared event,
    Emitter<GameStateBlocState> emit,
  ) {
    emit(const GameStateBlocState());
  }

  void _onPlayerJoined(
    PlayerJoined event,
    Emitter<GameStateBlocState> emit,
  ) {
    if (state.gameState == null) return;

    final updatedPlayers = [...state.gameState!.session.players, event.player];
    final updatedSession = state.gameState!.session.copyWith(players: updatedPlayers);
    final updatedGameState = state.gameState!.copyWith(
      session: updatedSession,
      lastUpdate: DateTime.now(),
    );

    emit(state.copyWith(gameState: updatedGameState));
  }

  void _onPlayerLeft(
    PlayerLeft event,
    Emitter<GameStateBlocState> emit,
  ) {
    if (state.gameState == null) return;

    final updatedPlayers = state.gameState!.session.players
        .where((p) => p.id != event.playerId)
        .toList();
    final updatedSession = state.gameState!.session.copyWith(players: updatedPlayers);
    final updatedGameState = state.gameState!.copyWith(
      session: updatedSession,
      lastUpdate: DateTime.now(),
    );

    emit(state.copyWith(gameState: updatedGameState));
  }

  void _onGamePhaseChanged(
    GamePhaseChanged event,
    Emitter<GameStateBlocState> emit,
  ) {
    if (state.gameState == null) return;

    final updatedSession = state.gameState!.session.copyWith(
      currentPhase: event.newPhase,
    );
    final updatedGameState = state.gameState!.copyWith(
      session: updatedSession,
      lastUpdate: DateTime.now(),
    );

    emit(state.copyWith(gameState: updatedGameState));
  }

  @override
  GameStateBlocState? fromJson(Map<String, dynamic> json) {
    try {
      return GameStateBlocState.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(GameStateBlocState state) {
    try {
      return state.toJson();
    } catch (e) {
      return null;
    }
  }
}