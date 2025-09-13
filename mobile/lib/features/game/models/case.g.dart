// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Clue _$ClueFromJson(Map<String, dynamic> json) => Clue(
  id: json['id'] as String,
  type: $enumDecode(_$ClueTypeEnumMap, json['type']),
  title: json['title'] as String,
  description: json['description'] as String,
  question: json['question'] as String,
  options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
  correctAnswerIndex: (json['correctAnswerIndex'] as num).toInt(),
  explanation: json['explanation'] as String,
  hints:
      (json['hints'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  keywords:
      (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  imageUrl: json['imageUrl'] as String?,
  difficultyPoints: (json['difficultyPoints'] as num?)?.toInt() ?? 10,
);

Map<String, dynamic> _$ClueToJson(Clue instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$ClueTypeEnumMap[instance.type]!,
  'title': instance.title,
  'description': instance.description,
  'question': instance.question,
  'options': instance.options,
  'correctAnswerIndex': instance.correctAnswerIndex,
  'explanation': instance.explanation,
  'hints': instance.hints,
  'keywords': instance.keywords,
  'imageUrl': instance.imageUrl,
  'difficultyPoints': instance.difficultyPoints,
};

const _$ClueTypeEnumMap = {
  ClueType.location: 'location',
  ClueType.cultural: 'cultural',
  ClueType.historical: 'historical',
  ClueType.visual: 'visual',
  ClueType.interview: 'interview',
  ClueType.evidence: 'evidence',
};

CaseProgress _$CaseProgressFromJson(Map<String, dynamic> json) => CaseProgress(
  caseId: json['caseId'] as String,
  currentLocationId: json['currentLocationId'] as String,
  visitedLocations:
      (json['visitedLocations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  solvedClues:
      (json['solvedClues'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  incorrectAnswers:
      (json['incorrectAnswers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
  timeElapsedMinutes: (json['timeElapsedMinutes'] as num?)?.toInt() ?? 0,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  isCompleted: json['isCompleted'] as bool? ?? false,
  isSuccessful: json['isSuccessful'] as bool? ?? false,
);

Map<String, dynamic> _$CaseProgressToJson(CaseProgress instance) =>
    <String, dynamic>{
      'caseId': instance.caseId,
      'currentLocationId': instance.currentLocationId,
      'visitedLocations': instance.visitedLocations,
      'solvedClues': instance.solvedClues,
      'incorrectAnswers': instance.incorrectAnswers,
      'totalScore': instance.totalScore,
      'timeElapsedMinutes': instance.timeElapsedMinutes,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'isSuccessful': instance.isSuccessful,
    };

DetectiveCase _$DetectiveCaseFromJson(Map<String, dynamic> json) =>
    DetectiveCase(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      briefing: json['briefing'] as String,
      difficulty: $enumDecode(_$CaseDifficultyEnumMap, json['difficulty']),
      villain: Villain.fromJson(json['villain'] as Map<String, dynamic>),
      artifact: StolenArtifact.fromJson(
        json['artifact'] as Map<String, dynamic>,
      ),
      startLocationId: json['startLocationId'] as String,
      possibleLocations: (json['possibleLocations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      locationClues: (json['locationClues'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map((e) => Clue.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ),
      redHerringLocations:
          (json['redHerringLocations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      timeLimit: (json['timeLimit'] as num?)?.toInt() ?? 180,
      budgetLimit: (json['budgetLimit'] as num?)?.toInt() ?? 5000,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DetectiveCaseToJson(DetectiveCase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'briefing': instance.briefing,
      'difficulty': _$CaseDifficultyEnumMap[instance.difficulty]!,
      'villain': instance.villain,
      'artifact': instance.artifact,
      'startLocationId': instance.startLocationId,
      'possibleLocations': instance.possibleLocations,
      'locationClues': instance.locationClues,
      'redHerringLocations': instance.redHerringLocations,
      'timeLimit': instance.timeLimit,
      'budgetLimit': instance.budgetLimit,
      'metadata': instance.metadata,
    };

const _$CaseDifficultyEnumMap = {
  CaseDifficulty.rookie: 'rookie',
  CaseDifficulty.detective: 'detective',
  CaseDifficulty.inspector: 'inspector',
  CaseDifficulty.master: 'master',
};
