import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class StartSinglePlayerGame extends GameEvent {}

class StartMultiplayerGame extends GameEvent {}

class LoadGameSession extends GameEvent {
  final String sessionId;
  
  const LoadGameSession(this.sessionId);
  
  @override
  List<Object> get props => [sessionId];
}

class PauseGame extends GameEvent {}

class ResumeGame extends GameEvent {}

class EndGame extends GameEvent {}

// States
abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object> get props => [];
}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameSinglePlayer extends GameState {}

class GameMultiplayer extends GameState {
  final String sessionId;
  
  const GameMultiplayer(this.sessionId);
  
  @override
  List<Object> get props => [sessionId];
}

class GamePaused extends GameState {}

class GameEnded extends GameState {
  final bool isWon;
  final int score;
  
  const GameEnded({
    required this.isWon,
    required this.score,
  });
  
  @override
  List<Object> get props => [isWon, score];
}

class GameError extends GameState {
  final String message;
  
  const GameError(this.message);
  
  @override
  List<Object> get props => [message];
}

// BLoC
class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(GameInitial()) {
    on<StartSinglePlayerGame>(_onStartSinglePlayerGame);
    on<StartMultiplayerGame>(_onStartMultiplayerGame);
    on<LoadGameSession>(_onLoadGameSession);
    on<PauseGame>(_onPauseGame);
    on<ResumeGame>(_onResumeGame);
    on<EndGame>(_onEndGame);
  }

  void _onStartSinglePlayerGame(StartSinglePlayerGame event, Emitter<GameState> emit) {
    emit(GameLoading());
    // Simulate loading
    Future.delayed(const Duration(milliseconds: 500), () {
      emit(GameSinglePlayer());
    });
  }

  void _onStartMultiplayerGame(StartMultiplayerGame event, Emitter<GameState> emit) {
    emit(GameLoading());
    // TODO: Implement multiplayer logic
    emit(const GameError('Multiplayer mode not yet implemented'));
  }

  void _onLoadGameSession(LoadGameSession event, Emitter<GameState> emit) {
    emit(GameLoading());
    try {
      // TODO: Load game session from database
      emit(GameMultiplayer(event.sessionId));
    } catch (e) {
      emit(GameError('Failed to load game session: ${e.toString()}'));
    }
  }

  void _onPauseGame(PauseGame event, Emitter<GameState> emit) {
    if (state is GameSinglePlayer || state is GameMultiplayer) {
      emit(GamePaused());
    }
  }

  void _onResumeGame(ResumeGame event, Emitter<GameState> emit) {
    if (state is GamePaused) {
      // Resume to previous state
      emit(GameSinglePlayer()); // TODO: Track previous state
    }
  }

  void _onEndGame(EndGame event, Emitter<GameState> emit) {
    // TODO: Calculate final score and win condition
    emit(const GameEnded(isWon: true, score: 1000));
  }
}