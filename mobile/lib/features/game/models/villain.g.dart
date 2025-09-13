// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'villain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Villain _$VillainFromJson(Map<String, dynamic> json) => Villain(
  id: json['id'] as String,
  name: json['name'] as String,
  alias: json['alias'] as String,
  description: json['description'] as String,
  difficulty: $enumDecode(_$VillainDifficultyEnumMap, json['difficulty']),
  specialties:
      (json['specialties'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  physicalTraits:
      (json['physicalTraits'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  personalityTraits:
      (json['personalityTraits'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  portraitUrl: json['portraitUrl'] as String?,
  knownAssociates:
      (json['knownAssociates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  favoriteLocations:
      (json['favoriteLocations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  backstory: json['backstory'] as String,
  preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$VillainToJson(Villain instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'alias': instance.alias,
  'description': instance.description,
  'difficulty': _$VillainDifficultyEnumMap[instance.difficulty]!,
  'specialties': instance.specialties,
  'physicalTraits': instance.physicalTraits,
  'personalityTraits': instance.personalityTraits,
  'portraitUrl': instance.portraitUrl,
  'knownAssociates': instance.knownAssociates,
  'favoriteLocations': instance.favoriteLocations,
  'backstory': instance.backstory,
  'preferences': instance.preferences,
};

const _$VillainDifficultyEnumMap = {
  VillainDifficulty.rookie: 'rookie',
  VillainDifficulty.intermediate: 'intermediate',
  VillainDifficulty.expert: 'expert',
  VillainDifficulty.master: 'master',
};

StolenArtifact _$StolenArtifactFromJson(Map<String, dynamic> json) =>
    StolenArtifact(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      originLocation: json['originLocation'] as String,
      estimatedValue: (json['estimatedValue'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      historicalSignificance:
          (json['historicalSignificance'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      clueKeywords:
          (json['clueKeywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$StolenArtifactToJson(StolenArtifact instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'originLocation': instance.originLocation,
      'estimatedValue': instance.estimatedValue,
      'imageUrl': instance.imageUrl,
      'historicalSignificance': instance.historicalSignificance,
      'clueKeywords': instance.clueKeywords,
    };
