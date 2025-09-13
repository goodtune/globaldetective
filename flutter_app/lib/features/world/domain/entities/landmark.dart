class Landmark {
  final String id;
  final String name;
  final String countryId;
  final String? city;
  final String type;
  final String? significance;
  final String? description;
  final double? coordinatesLat;
  final double? coordinatesLng;
  final String? imageUrl;
  final DateTime createdAt;

  const Landmark({
    required this.id,
    required this.name,
    required this.countryId,
    this.city,
    required this.type,
    this.significance,
    this.description,
    this.coordinatesLat,
    this.coordinatesLng,
    this.imageUrl,
    required this.createdAt,
  });

  factory Landmark.fromMap(Map<String, dynamic> map) {
    return Landmark(
      id: map['id'] as String,
      name: map['name'] as String,
      countryId: map['country_id'] as String,
      city: map['city'] as String?,
      type: map['type'] as String,
      significance: map['significance'] as String?,
      description: map['description'] as String?,
      coordinatesLat: map['coordinates_lat'] as double?,
      coordinatesLng: map['coordinates_lng'] as double?,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'country_id': countryId,
      'city': city,
      'type': type,
      'significance': significance,
      'description': description,
      'coordinates_lat': coordinatesLat,
      'coordinates_lng': coordinatesLng,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Landmark(id: $id, name: $name, countryId: $countryId)';
  }
}