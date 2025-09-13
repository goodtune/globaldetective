import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

@JsonSerializable()
class Location {
  final String id;
  final String name;
  final String country;
  final String continent;
  final double latitude;
  final double longitude;
  final String description;
  final List<String> landmarks;
  final Map<String, String> culturalInfo;
  final String? imageUrl;
  final String timezone;
  final String currency;
  final List<String> languages;

  const Location({
    required this.id,
    required this.name,
    required this.country,
    required this.continent,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.landmarks = const [],
    this.culturalInfo = const {},
    this.imageUrl,
    required this.timezone,
    required this.currency,
    this.languages = const [],
  });

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);

  Location copyWith({
    String? id,
    String? name,
    String? country,
    String? continent,
    double? latitude,
    double? longitude,
    String? description,
    List<String>? landmarks,
    Map<String, String>? culturalInfo,
    String? imageUrl,
    String? timezone,
    String? currency,
    List<String>? languages,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      continent: continent ?? this.continent,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      landmarks: landmarks ?? this.landmarks,
      culturalInfo: culturalInfo ?? this.culturalInfo,
      imageUrl: imageUrl ?? this.imageUrl,
      timezone: timezone ?? this.timezone,
      currency: currency ?? this.currency,
      languages: languages ?? this.languages,
    );
  }
}

@JsonSerializable()
class Landmark {
  final String id;
  final String name;
  final String locationId;
  final double latitude;
  final double longitude;
  final String description;
  final String category;
  final List<String> imageUrls;
  final Map<String, String> historicalInfo;
  final double? entryFee;
  final String? openingHours;
  final int popularity; // 1-10 scale

  const Landmark({
    required this.id,
    required this.name,
    required this.locationId,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.category,
    this.imageUrls = const [],
    this.historicalInfo = const {},
    this.entryFee,
    this.openingHours,
    this.popularity = 5,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) => _$LandmarkFromJson(json);
  Map<String, dynamic> toJson() => _$LandmarkToJson(this);
}

@JsonSerializable()
class TravelRoute {
  final String fromLocationId;
  final String toLocationId;
  final String transportMethod;
  final int durationMinutes;
  final double cost;
  final List<String> connections;
  final bool isDirectRoute;

  const TravelRoute({
    required this.fromLocationId,
    required this.toLocationId,
    required this.transportMethod,
    required this.durationMinutes,
    required this.cost,
    this.connections = const [],
    this.isDirectRoute = true,
  });

  factory TravelRoute.fromJson(Map<String, dynamic> json) => _$TravelRouteFromJson(json);
  Map<String, dynamic> toJson() => _$TravelRouteToJson(this);
}