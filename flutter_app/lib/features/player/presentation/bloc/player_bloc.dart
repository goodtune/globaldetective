import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/player.dart';

// Events
abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object> get props => [];
}

class LoadPlayer extends PlayerEvent {
  final String playerId;
  
  const LoadPlayer(this.playerId);
  
  @override
  List<Object> get props => [playerId];
}

class CreatePlayer extends PlayerEvent {
  final String name;
  
  const CreatePlayer(this.name);
  
  @override
  List<Object> get props => [name];
}

class UpdatePlayerScore extends PlayerEvent {
  final int scoreToAdd;
  
  const UpdatePlayerScore(this.scoreToAdd);
  
  @override
  List<Object> get props => [scoreToAdd];
}

class UpdatePlayerBudget extends PlayerEvent {
  final int budgetChange;
  
  const UpdatePlayerBudget(this.budgetChange);
  
  @override
  List<Object> get props => [budgetChange];
}

class CompleteCase extends PlayerEvent {}

class PromotePlayer extends PlayerEvent {}

// States
abstract class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object> get props => [];
}

class PlayerInitial extends PlayerState {}

class PlayerLoading extends PlayerState {}

class PlayerLoaded extends PlayerState {
  final Player player;
  
  const PlayerLoaded(this.player);
  
  @override
  List<Object> get props => [player];
}

class PlayerError extends PlayerState {
  final String message;
  
  const PlayerError(this.message);
  
  @override
  List<Object> get props => [message];
}

// BLoC
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(PlayerInitial()) {
    on<LoadPlayer>(_onLoadPlayer);
    on<CreatePlayer>(_onCreatePlayer);
    on<UpdatePlayerScore>(_onUpdatePlayerScore);
    on<UpdatePlayerBudget>(_onUpdatePlayerBudget);
    on<CompleteCase>(_onCompleteCase);
    on<PromotePlayer>(_onPromotePlayer);
  }

  void _onLoadPlayer(LoadPlayer event, Emitter<PlayerState> emit) async {
    emit(PlayerLoading());
    try {
      // TODO: Load player from database
      final player = Player(
        id: event.playerId,
        name: 'Detective Player',
        rank: 'Rookie',
        totalScore: 0,
        casesSolved: 0,
        currentBudget: 5000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      emit(PlayerLoaded(player));
    } catch (e) {
      emit(PlayerError('Failed to load player: ${e.toString()}'));
    }
  }

  void _onCreatePlayer(CreatePlayer event, Emitter<PlayerState> emit) async {
    emit(PlayerLoading());
    try {
      // TODO: Save player to database
      final player = Player(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.name,
        rank: 'Rookie',
        totalScore: 0,
        casesSolved: 0,
        currentBudget: 5000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      emit(PlayerLoaded(player));
    } catch (e) {
      emit(PlayerError('Failed to create player: ${e.toString()}'));
    }
  }

  void _onUpdatePlayerScore(UpdatePlayerScore event, Emitter<PlayerState> emit) {
    if (state is PlayerLoaded) {
      final currentPlayer = (state as PlayerLoaded).player;
      final updatedPlayer = currentPlayer.copyWith(
        totalScore: currentPlayer.totalScore + event.scoreToAdd,
        updatedAt: DateTime.now(),
      );
      emit(PlayerLoaded(updatedPlayer));
    }
  }

  void _onUpdatePlayerBudget(UpdatePlayerBudget event, Emitter<PlayerState> emit) {
    if (state is PlayerLoaded) {
      final currentPlayer = (state as PlayerLoaded).player;
      final newBudget = (currentPlayer.currentBudget + event.budgetChange).clamp(0, 999999);
      final updatedPlayer = currentPlayer.copyWith(
        currentBudget: newBudget,
        updatedAt: DateTime.now(),
      );
      emit(PlayerLoaded(updatedPlayer));
    }
  }

  void _onCompleteCase(CompleteCase event, Emitter<PlayerState> emit) {
    if (state is PlayerLoaded) {
      final currentPlayer = (state as PlayerLoaded).player;
      final updatedPlayer = currentPlayer.copyWith(
        casesSolved: currentPlayer.casesSolved + 1,
        updatedAt: DateTime.now(),
      );
      emit(PlayerLoaded(updatedPlayer));
      
      // Check for promotion
      if (updatedPlayer.canBePromoted) {
        add(PromotePlayer());
      }
    }
  }

  void _onPromotePlayer(PromotePlayer event, Emitter<PlayerState> emit) {
    if (state is PlayerLoaded) {
      final currentPlayer = (state as PlayerLoaded).player;
      if (currentPlayer.canBePromoted) {
        final updatedPlayer = currentPlayer.copyWith(
          rank: currentPlayer.nextRank,
          updatedAt: DateTime.now(),
        );
        emit(PlayerLoaded(updatedPlayer));
      }
    }
  }
}