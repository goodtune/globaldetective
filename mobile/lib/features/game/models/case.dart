import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import 'villain.dart';

part 'case.g.dart';

enum CaseDifficulty {
  rookie,
  detective,
  inspector,
  master,
}

enum ClueType {
  location,
  cultural,
  historical,
  visual,
  interview,
  evidence,
}

@JsonSerializable()
class Clue extends Equatable {
  final String id;
  final ClueType type;
  final String title;
  final String description;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final Map<String, String> hints;
  final List<String> keywords;
  final String? imageUrl;
  final int difficultyPoints;

  const Clue({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.hints = const {},
    this.keywords = const [],
    this.imageUrl,
    this.difficultyPoints = 10,
  });

  factory Clue.fromJson(Map<String, dynamic> json) => _$ClueFromJson(json);
  Map<String, dynamic> toJson() => _$ClueToJson(this);

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        question,
        options,
        correctAnswerIndex,
        explanation,
        hints,
        keywords,
        imageUrl,
        difficultyPoints,
      ];

  String get correctAnswer => options[correctAnswerIndex];
  
  bool isCorrectAnswer(int selectedIndex) => selectedIndex == correctAnswerIndex;
}

@JsonSerializable()
class CaseProgress extends Equatable {
  final String caseId;
  final String currentLocationId;
  final List<String> visitedLocations;
  final List<String> solvedClues;
  final List<String> incorrectAnswers;
  final int totalScore;
  final int timeElapsedMinutes;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final bool isSuccessful;

  const CaseProgress({
    required this.caseId,
    required this.currentLocationId,
    this.visitedLocations = const [],
    this.solvedClues = const [],
    this.incorrectAnswers = const [],
    this.totalScore = 0,
    this.timeElapsedMinutes = 0,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.isSuccessful = false,
  });

  factory CaseProgress.fromJson(Map<String, dynamic> json) => _$CaseProgressFromJson(json);
  Map<String, dynamic> toJson() => _$CaseProgressToJson(this);

  CaseProgress copyWith({
    String? caseId,
    String? currentLocationId,
    List<String>? visitedLocations,
    List<String>? solvedClues,
    List<String>? incorrectAnswers,
    int? totalScore,
    int? timeElapsedMinutes,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    bool? isSuccessful,
  }) {
    return CaseProgress(
      caseId: caseId ?? this.caseId,
      currentLocationId: currentLocationId ?? this.currentLocationId,
      visitedLocations: visitedLocations ?? this.visitedLocations,
      solvedClues: solvedClues ?? this.solvedClues,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      totalScore: totalScore ?? this.totalScore,
      timeElapsedMinutes: timeElapsedMinutes ?? this.timeElapsedMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      isSuccessful: isSuccessful ?? this.isSuccessful,
    );
  }

  @override
  List<Object?> get props => [
        caseId,
        currentLocationId,
        visitedLocations,
        solvedClues,
        incorrectAnswers,
        totalScore,
        timeElapsedMinutes,
        startTime,
        endTime,
        isCompleted,
        isSuccessful,
      ];

  double get accuracyPercentage {
    final totalAttempts = solvedClues.length + incorrectAnswers.length;
    if (totalAttempts == 0) return 0.0;
    return (solvedClues.length / totalAttempts) * 100;
  }
}

@JsonSerializable()
class DetectiveCase extends Equatable {
  final String id;
  final String title;
  final String description;
  final String briefing;
  final CaseDifficulty difficulty;
  final Villain villain;
  final StolenArtifact artifact;
  final String startLocationId;
  final List<String> possibleLocations;
  final Map<String, List<Clue>> locationClues;
  final List<String> redHerringLocations;
  final int timeLimit; // in minutes
  final int budgetLimit;
  final Map<String, dynamic> metadata;

  const DetectiveCase({
    required this.id,
    required this.title,
    required this.description,
    required this.briefing,
    required this.difficulty,
    required this.villain,
    required this.artifact,
    required this.startLocationId,
    required this.possibleLocations,
    required this.locationClues,
    this.redHerringLocations = const [],
    this.timeLimit = 180,
    this.budgetLimit = 5000,
    this.metadata = const {},
  });

  factory DetectiveCase.fromJson(Map<String, dynamic> json) => _$DetectiveCaseFromJson(json);
  Map<String, dynamic> toJson() => _$DetectiveCaseToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        briefing,
        difficulty,
        villain,
        artifact,
        startLocationId,
        possibleLocations,
        locationClues,
        redHerringLocations,
        timeLimit,
        budgetLimit,
        metadata,
      ];

  List<Clue> getCluesForLocation(String locationId) {
    return locationClues[locationId] ?? [];
  }

  bool isValidLocation(String locationId) {
    return possibleLocations.contains(locationId) || 
           redHerringLocations.contains(locationId);
  }

  int get totalClues {
    return locationClues.values.fold(0, (sum, clues) => sum + clues.length);
  }

  int get maxPossibleScore {
    return locationClues.values.fold(0, (sum, clues) => 
        sum + clues.fold(0, (clueSum, clue) => clueSum + clue.difficultyPoints));
  }
}