part of 'case_management_bloc.dart';

enum CaseManagementStatus {
  idle,
  loading,
  active,
  completed,
  error,
}

class CaseManagementState extends Equatable {
  final CaseManagementStatus status;
  final DetectiveCase? currentCase;
  final CaseProgress? progress;
  final Location? currentLocation;
  final List<Clue> availableClues;
  final Clue? lastAttemptedClue;
  final bool? lastAttemptCorrect;
  final int elapsedTimeMinutes;
  final Map<String, List<String>> usedHints;
  final String? lastHintKey;
  final String? lastHintText;
  final String? errorMessage;

  const CaseManagementState({
    this.status = CaseManagementStatus.idle,
    this.currentCase,
    this.progress,
    this.currentLocation,
    this.availableClues = const [],
    this.lastAttemptedClue,
    this.lastAttemptCorrect,
    this.elapsedTimeMinutes = 0,
    this.usedHints = const {},
    this.lastHintKey,
    this.lastHintText,
    this.errorMessage,
  });

  CaseManagementState copyWith({
    CaseManagementStatus? status,
    DetectiveCase? currentCase,
    CaseProgress? progress,
    Location? currentLocation,
    List<Clue>? availableClues,
    Clue? lastAttemptedClue,
    bool? lastAttemptCorrect,
    int? elapsedTimeMinutes,
    Map<String, List<String>>? usedHints,
    String? lastHintKey,
    String? lastHintText,
    String? errorMessage,
  }) {
    return CaseManagementState(
      status: status ?? this.status,
      currentCase: currentCase ?? this.currentCase,
      progress: progress ?? this.progress,
      currentLocation: currentLocation ?? this.currentLocation,
      availableClues: availableClues ?? this.availableClues,
      lastAttemptedClue: lastAttemptedClue ?? this.lastAttemptedClue,
      lastAttemptCorrect: lastAttemptCorrect ?? this.lastAttemptCorrect,
      elapsedTimeMinutes: elapsedTimeMinutes ?? this.elapsedTimeMinutes,
      usedHints: usedHints ?? this.usedHints,
      lastHintKey: lastHintKey ?? this.lastHintKey,
      lastHintText: lastHintText ?? this.lastHintText,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentCase,
        progress,
        currentLocation,
        availableClues,
        lastAttemptedClue,
        lastAttemptCorrect,
        elapsedTimeMinutes,
        usedHints,
        lastHintKey,
        lastHintText,
        errorMessage,
      ];

  // Computed properties
  bool get isActive => status == CaseManagementStatus.active;
  bool get isCompleted => status == CaseManagementStatus.completed;
  bool get hasError => status == CaseManagementStatus.error;
  bool get isLoading => status == CaseManagementStatus.loading;

  int get remainingTimeMinutes {
    if (currentCase == null) return 0;
    return (currentCase!.timeLimit - elapsedTimeMinutes).clamp(0, currentCase!.timeLimit);
  }

  double get progressPercentage {
    if (currentCase == null || progress == null) return 0.0;
    final totalClues = currentCase!.totalClues;
    if (totalClues == 0) return 0.0;
    return (progress!.solvedClues.length / totalClues) * 100;
  }

  bool get canRequestHint {
    return lastAttemptedClue != null && 
           lastAttemptedClue!.hints.isNotEmpty &&
           (usedHints[lastAttemptedClue!.id]?.length ?? 0) < lastAttemptedClue!.hints.length;
  }

  // JSON serialization for HydratedBloc
  factory CaseManagementState.fromJson(Map<String, dynamic> json) {
    return CaseManagementState(
      status: CaseManagementStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CaseManagementStatus.idle,
      ),
      currentCase: json['currentCase'] != null
          ? DetectiveCase.fromJson(json['currentCase'] as Map<String, dynamic>)
          : null,
      progress: json['progress'] != null
          ? CaseProgress.fromJson(json['progress'] as Map<String, dynamic>)
          : null,
      currentLocation: json['currentLocation'] != null
          ? Location.fromJson(json['currentLocation'] as Map<String, dynamic>)
          : null,
      availableClues: (json['availableClues'] as List<dynamic>?)
              ?.map((clue) => Clue.fromJson(clue as Map<String, dynamic>))
              .toList() ??
          const [],
      lastAttemptedClue: json['lastAttemptedClue'] != null
          ? Clue.fromJson(json['lastAttemptedClue'] as Map<String, dynamic>)
          : null,
      lastAttemptCorrect: json['lastAttemptCorrect'] as bool?,
      elapsedTimeMinutes: json['elapsedTimeMinutes'] as int? ?? 0,
      usedHints: (json['usedHints'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value as List)),
          ) ??
          const {},
      lastHintKey: json['lastHintKey'] as String?,
      lastHintText: json['lastHintText'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'currentCase': currentCase?.toJson(),
      'progress': progress?.toJson(),
      'currentLocation': currentLocation?.toJson(),
      'availableClues': availableClues.map((clue) => clue.toJson()).toList(),
      'lastAttemptedClue': lastAttemptedClue?.toJson(),
      'lastAttemptCorrect': lastAttemptCorrect,
      'elapsedTimeMinutes': elapsedTimeMinutes,
      'usedHints': usedHints,
      'lastHintKey': lastHintKey,
      'lastHintText': lastHintText,
      'errorMessage': errorMessage,
    };
  }
}