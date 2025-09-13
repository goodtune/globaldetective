import 'package:json_annotation/json_annotation.dart';

part 'villain.g.dart';

enum VillainDifficulty {
  rookie,
  intermediate,
  expert,
  master,
}

@JsonSerializable()
class Villain {
  final String id;
  final String name;
  final String alias;
  final String description;
  final VillainDifficulty difficulty;
  final List<String> specialties;
  final Map<String, String> physicalTraits;
  final List<String> personalityTraits;
  final String? portraitUrl;
  final List<String> knownAssociates;
  final List<String> favoriteLocations;
  final String backstory;
  final Map<String, dynamic> preferences;

  const Villain({
    required this.id,
    required this.name,
    required this.alias,
    required this.description,
    required this.difficulty,
    this.specialties = const [],
    this.physicalTraits = const {},
    this.personalityTraits = const [],
    this.portraitUrl,
    this.knownAssociates = const [],
    this.favoriteLocations = const [],
    required this.backstory,
    this.preferences = const {},
  });

  factory Villain.fromJson(Map<String, dynamic> json) => _$VillainFromJson(json);
  Map<String, dynamic> toJson() => _$VillainToJson(this);
}

@JsonSerializable()
class StolenArtifact {
  final String id;
  final String name;
  final String description;
  final String category;
  final String originLocation;
  final double estimatedValue;
  final String? imageUrl;
  final Map<String, String> historicalSignificance;
  final List<String> clueKeywords;

  const StolenArtifact({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.originLocation,
    required this.estimatedValue,
    this.imageUrl,
    this.historicalSignificance = const {},
    this.clueKeywords = const [],
  });

  factory StolenArtifact.fromJson(Map<String, dynamic> json) => _$StolenArtifactFromJson(json);
  Map<String, dynamic> toJson() => _$StolenArtifactToJson(this);
}