import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../models/case.dart';
import '../../models/location.dart';
import '../../services/case_data_service.dart';
import '../../services/location_data_service.dart';

part 'case_management_event.dart';
part 'case_management_state.dart';

class CaseManagementBloc extends HydratedBloc<CaseManagementEvent, CaseManagementState> {
  final CaseDataService _caseDataService;
  final LocationDataService _locationDataService;
  Timer? _gameTimer;

  CaseManagementBloc({
    CaseDataService? caseDataService,
    LocationDataService? locationDataService,
  })  : _caseDataService = caseDataService ?? CaseDataService.instance,
        _locationDataService = locationDataService ?? LocationDataService.instance,
        super(const CaseManagementState()) {
    // Initialize the services if not already initialized
    _caseDataService.initialize();
    _locationDataService.initialize();
    on<CaseStarted>(_onCaseStarted);
    on<ClueAttempted>(_onClueAttempted);
    on<LocationChanged>(_onLocationChanged);
    on<CaseCompleted>(_onCaseCompleted);
    on<CaseAbandoned>(_onCaseAbandoned);
    on<TimerTicked>(_onTimerTicked);
    on<HintRequested>(_onHintRequested);
  }

  Future<void> _onCaseStarted(CaseStarted event, Emitter<CaseManagementState> emit) async {
    try {
      emit(state.copyWith(status: CaseManagementStatus.loading));

      final detectiveCase = _caseDataService.generateRandomCase(event.difficulty);
      final startLocation = _locationDataService.getLocationById(detectiveCase.startLocationId);

      if (startLocation == null) {
        emit(state.copyWith(
          status: CaseManagementStatus.error,
          errorMessage: 'Could not find starting location',
        ));
        return;
      }

      final progress = CaseProgress(
        caseId: detectiveCase.id,
        currentLocationId: detectiveCase.startLocationId,
        startTime: DateTime.now(),
        visitedLocations: [detectiveCase.startLocationId],
      );

      emit(state.copyWith(
        status: CaseManagementStatus.active,
        currentCase: detectiveCase,
        progress: progress,
        currentLocation: startLocation,
        availableClues: detectiveCase.getCluesForLocation(detectiveCase.startLocationId),
        errorMessage: null,
      ));

      // Start the game timer
      _startTimer();
    } catch (e) {
      emit(state.copyWith(
        status: CaseManagementStatus.error,
        errorMessage: 'Failed to start case: ${e.toString()}',
      ));
    }
  }

  Future<void> _onClueAttempted(ClueAttempted event, Emitter<CaseManagementState> emit) async {
    if (state.currentCase == null || state.progress == null) return;

    final clue = event.clue;
    final isCorrect = clue.isCorrectAnswer(event.selectedAnswerIndex);
    
    final updatedSolvedClues = isCorrect 
        ? [...state.progress!.solvedClues, clue.id]
        : state.progress!.solvedClues;
    
    final updatedIncorrectAnswers = !isCorrect
        ? [...state.progress!.incorrectAnswers, clue.id]
        : state.progress!.incorrectAnswers;

    final scoreIncrease = isCorrect ? clue.difficultyPoints : 0;
    final newScore = state.progress!.totalScore + scoreIncrease;

    final updatedProgress = state.progress!.copyWith(
      solvedClues: updatedSolvedClues,
      incorrectAnswers: updatedIncorrectAnswers,
      totalScore: newScore,
    );

    // Remove the attempted clue from available clues
    final remainingClues = state.availableClues.where((c) => c.id != clue.id).toList();

    emit(state.copyWith(
      progress: updatedProgress,
      availableClues: remainingClues,
      lastAttemptedClue: clue,
      lastAttemptCorrect: isCorrect,
    ));

    // Check if case is complete (all clues in current location solved)
    if (remainingClues.isEmpty) {
      final allLocationsSolved = _areAllLocationsSolved(state.currentCase!, updatedProgress);
      if (allLocationsSolved) {
        add(const CaseCompleted());
      }
    }
  }

  Future<void> _onLocationChanged(LocationChanged event, Emitter<CaseManagementState> emit) async {
    if (state.currentCase == null || state.progress == null) return;

    final newLocation = _locationDataService.getLocationById(event.locationId);
    if (newLocation == null) {
      emit(state.copyWith(
        errorMessage: 'Invalid location selected',
      ));
      return;
    }

    final updatedVisitedLocations = state.progress!.visitedLocations.contains(event.locationId)
        ? state.progress!.visitedLocations
        : [...state.progress!.visitedLocations, event.locationId];

    final updatedProgress = state.progress!.copyWith(
      currentLocationId: event.locationId,
      visitedLocations: updatedVisitedLocations,
    );

    final newClues = state.currentCase!.getCluesForLocation(event.locationId)
        .where((clue) => !updatedProgress.solvedClues.contains(clue.id))
        .toList();

    emit(state.copyWith(
      progress: updatedProgress,
      currentLocation: newLocation,
      availableClues: newClues,
      lastAttemptedClue: null,
      lastAttemptCorrect: null,
    ));
  }

  Future<void> _onCaseCompleted(CaseCompleted event, Emitter<CaseManagementState> emit) async {
    if (state.currentCase == null || state.progress == null) return;

    _stopTimer();

    final completedProgress = state.progress!.copyWith(
      isCompleted: true,
      isSuccessful: true,
      endTime: DateTime.now(),
      timeElapsedMinutes: state.elapsedTimeMinutes,
    );

    emit(state.copyWith(
      status: CaseManagementStatus.completed,
      progress: completedProgress,
    ));
  }

  Future<void> _onCaseAbandoned(CaseAbandoned event, Emitter<CaseManagementState> emit) async {
    _stopTimer();

    final abandonedProgress = state.progress?.copyWith(
      isCompleted: true,
      isSuccessful: false,
      endTime: DateTime.now(),
      timeElapsedMinutes: state.elapsedTimeMinutes,
    );

    emit(state.copyWith(
      status: CaseManagementStatus.idle,
      currentCase: null,
      progress: abandonedProgress,
      currentLocation: null,
      availableClues: const [],
      lastAttemptedClue: null,
      lastAttemptCorrect: null,
    ));
  }

  void _onTimerTicked(TimerTicked event, Emitter<CaseManagementState> emit) {
    if (state.status == CaseManagementStatus.active && state.currentCase != null) {
      final elapsedMinutes = state.elapsedTimeMinutes + 1;
      
      // Check if time limit exceeded
      if (elapsedMinutes >= state.currentCase!.timeLimit) {
        add(const CaseCompleted());
        return;
      }

      emit(state.copyWith(elapsedTimeMinutes: elapsedMinutes));
    }
  }

  void _onHintRequested(HintRequested event, Emitter<CaseManagementState> emit) {
    final clue = event.clue;
    final hintKeys = clue.hints.keys.toList();
    
    if (hintKeys.isNotEmpty) {
      final usedHints = state.usedHints[clue.id] ?? [];
      final availableHints = hintKeys.where((key) => !usedHints.contains(key)).toList();
      
      if (availableHints.isNotEmpty) {
        final nextHintKey = availableHints.first;
        final updatedUsedHints = {
          ...state.usedHints,
          clue.id: [...usedHints, nextHintKey],
        };
        
        emit(state.copyWith(
          usedHints: updatedUsedHints,
          lastHintKey: nextHintKey,
          lastHintText: clue.hints[nextHintKey],
        ));
      }
    }
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      add(const TimerTicked());
    });
  }

  void _stopTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  bool _areAllLocationsSolved(DetectiveCase detectiveCase, CaseProgress progress) {
    for (final locationId in detectiveCase.possibleLocations) {
      final locationClues = detectiveCase.getCluesForLocation(locationId);
      for (final clue in locationClues) {
        if (!progress.solvedClues.contains(clue.id)) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }

  @override
  CaseManagementState? fromJson(Map<String, dynamic> json) {
    try {
      return CaseManagementState.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(CaseManagementState state) {
    try {
      return state.toJson();
    } catch (e) {
      return null;
    }
  }
}