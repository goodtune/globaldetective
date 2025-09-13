// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  id: json['id'] as String,
  name: json['name'] as String,
  country: json['country'] as String,
  continent: json['continent'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  description: json['description'] as String,
  landmarks:
      (json['landmarks'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  culturalInfo:
      (json['culturalInfo'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  imageUrl: json['imageUrl'] as String?,
  timezone: json['timezone'] as String,
  currency: json['currency'] as String,
  languages:
      (json['languages'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'country': instance.country,
  'continent': instance.continent,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'description': instance.description,
  'landmarks': instance.landmarks,
  'culturalInfo': instance.culturalInfo,
  'imageUrl': instance.imageUrl,
  'timezone': instance.timezone,
  'currency': instance.currency,
  'languages': instance.languages,
};

Landmark _$LandmarkFromJson(Map<String, dynamic> json) => Landmark(
  id: json['id'] as String,
  name: json['name'] as String,
  locationId: json['locationId'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  description: json['description'] as String,
  category: json['category'] as String,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  historicalInfo:
      (json['historicalInfo'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  entryFee: (json['entryFee'] as num?)?.toDouble(),
  openingHours: json['openingHours'] as String?,
  popularity: (json['popularity'] as num?)?.toInt() ?? 5,
);

Map<String, dynamic> _$LandmarkToJson(Landmark instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'locationId': instance.locationId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'description': instance.description,
  'category': instance.category,
  'imageUrls': instance.imageUrls,
  'historicalInfo': instance.historicalInfo,
  'entryFee': instance.entryFee,
  'openingHours': instance.openingHours,
  'popularity': instance.popularity,
};

TravelRoute _$TravelRouteFromJson(Map<String, dynamic> json) => TravelRoute(
  fromLocationId: json['fromLocationId'] as String,
  toLocationId: json['toLocationId'] as String,
  transportMethod: json['transportMethod'] as String,
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  cost: (json['cost'] as num).toDouble(),
  connections:
      (json['connections'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isDirectRoute: json['isDirectRoute'] as bool? ?? true,
);

Map<String, dynamic> _$TravelRouteToJson(TravelRoute instance) =>
    <String, dynamic>{
      'fromLocationId': instance.fromLocationId,
      'toLocationId': instance.toLocationId,
      'transportMethod': instance.transportMethod,
      'durationMinutes': instance.durationMinutes,
      'cost': instance.cost,
      'connections': instance.connections,
      'isDirectRoute': instance.isDirectRoute,
    };
