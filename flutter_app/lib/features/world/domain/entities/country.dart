class Country {
  final String id;
  final String name;
  final String capital;
  final String continent;
  final String currency;
  final int? population;
  final double? coordinatesLat;
  final double? coordinatesLng;
  final List<String> flagColors;
  final String? government;
  final String? description;
  final DateTime createdAt;

  const Country({
    required this.id,
    required this.name,
    required this.capital,
    required this.continent,
    required this.currency,
    this.population,
    this.coordinatesLat,
    this.coordinatesLng,
    required this.flagColors,
    this.government,
    this.description,
    required this.createdAt,
  });

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      id: map['id'] as String,
      name: map['name'] as String,
      capital: map['capital'] as String,
      continent: map['continent'] as String,
      currency: map['currency'] as String,
      population: map['population'] as int?,
      coordinatesLat: map['coordinates_lat'] as double?,
      coordinatesLng: map['coordinates_lng'] as double?,
      flagColors: (map['flag_colors'] as String? ?? '').split(','),
      government: map['government'] as String?,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'capital': capital,
      'continent': continent,
      'currency': currency,
      'population': population,
      'coordinates_lat': coordinatesLat,
      'coordinates_lng': coordinatesLng,
      'flag_colors': flagColors.join(','),
      'government': government,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Country(id: $id, name: $name, capital: $capital)';
  }
}