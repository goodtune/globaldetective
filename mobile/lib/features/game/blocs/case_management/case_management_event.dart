part of 'case_management_bloc.dart';

abstract class CaseManagementEvent extends Equatable {
  const CaseManagementEvent();

  @override
  List<Object?> get props => [];
}

class CaseStarted extends CaseManagementEvent {
  final CaseDifficulty difficulty;

  const CaseStarted(this.difficulty);

  @override
  List<Object?> get props => [difficulty];
}

class ClueAttempted extends CaseManagementEvent {
  final Clue clue;
  final int selectedAnswerIndex;

  const ClueAttempted({
    required this.clue,
    required this.selectedAnswerIndex,
  });

  @override
  List<Object?> get props => [clue, selectedAnswerIndex];
}

class LocationChanged extends CaseManagementEvent {
  final String locationId;

  const LocationChanged(this.locationId);

  @override
  List<Object?> get props => [locationId];
}

class CaseCompleted extends CaseManagementEvent {
  const CaseCompleted();
}

class CaseAbandoned extends CaseManagementEvent {
  const CaseAbandoned();
}

class TimerTicked extends CaseManagementEvent {
  const TimerTicked();
}

class HintRequested extends CaseManagementEvent {
  final Clue clue;

  const HintRequested(this.clue);

  @override
  List<Object?> get props => [clue];
}