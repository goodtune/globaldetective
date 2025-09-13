import '../models/location.dart';

class LocationDataService {
  static LocationDataService? _instance;
  static LocationDataService get instance {
    _instance ??= LocationDataService._();
    return _instance!;
  }

  LocationDataService._();

  final Map<String, Location> _locations = {};
  final Map<String, List<Landmark>> _landmarks = {};

  bool get isInitialized => _locations.isNotEmpty;

  void initialize() {
    if (isInitialized) return;

    _loadInitialLocations();
    _loadInitialLandmarks();
    
    // Verify initialization completed
    if (_locations.isEmpty) {
      throw StateError('Failed to load locations during initialization');
    }
  }

  void _loadInitialLocations() {
    final locations = [
      // Europe
      const Location(
        id: 'paris_france',
        name: 'Paris',
        country: 'France',
        continent: 'Europe',
        latitude: 48.8566,
        longitude: 2.3522,
        description: 'The City of Light, known for its art, fashion, gastronomy, and culture.',
        landmarks: ['eiffel_tower', 'louvre_museum', 'notre_dame', 'champs_elysees'],
        culturalInfo: {
          'cuisine': 'French cuisine with croissants, wine, and cheese',
          'art': 'Birthplace of Impressionism, famous museums',
          'architecture': 'Haussmann architecture, Gothic cathedrals',
          'language': 'French is the official language',
        },
        timezone: 'Europe/Paris',
        currency: 'Euro (EUR)',
        languages: ['French'],
      ),
      
      const Location(
        id: 'london_uk',
        name: 'London',
        country: 'United Kingdom',
        continent: 'Europe',
        latitude: 51.5074,
        longitude: -0.1278,
        description: 'Historic capital known for its royal heritage, museums, and iconic landmarks.',
        landmarks: ['big_ben', 'tower_bridge', 'british_museum', 'buckingham_palace'],
        culturalInfo: {
          'heritage': 'Rich royal history and parliamentary democracy',
          'literature': 'Home to Shakespeare, Dickens, and many famous authors',
          'cuisine': 'Traditional British fare, afternoon tea culture',
          'language': 'English originated here',
        },
        timezone: 'Europe/London',
        currency: 'British Pound (GBP)',
        languages: ['English'],
      ),

      const Location(
        id: 'rome_italy',
        name: 'Rome',
        country: 'Italy',
        continent: 'Europe',
        latitude: 41.9028,
        longitude: 12.4964,
        description: 'The Eternal City, center of the Roman Empire and home to Vatican City.',
        landmarks: ['colosseum', 'vatican_city', 'trevi_fountain', 'pantheon'],
        culturalInfo: {
          'history': 'Ancient Roman Empire capital, over 2,800 years old',
          'religion': 'Center of Catholic Christianity',
          'art': 'Renaissance and Baroque masterpieces',
          'cuisine': 'Authentic Italian pasta, pizza, and gelato',
        },
        timezone: 'Europe/Rome',
        currency: 'Euro (EUR)',
        languages: ['Italian'],
      ),

      // Asia
      const Location(
        id: 'tokyo_japan',
        name: 'Tokyo',
        country: 'Japan',
        continent: 'Asia',
        latitude: 35.6762,
        longitude: 139.6503,
        description: 'Modern metropolis blending traditional Japanese culture with cutting-edge technology.',
        landmarks: ['tokyo_tower', 'senso_ji_temple', 'shibuya_crossing', 'imperial_palace'],
        culturalInfo: {
          'technology': 'Global leader in innovation and robotics',
          'culture': 'Traditional tea ceremony, sumo wrestling, anime',
          'cuisine': 'Sushi, ramen, and the most Michelin-starred restaurants',
          'tradition': 'Blend of ancient traditions and modern life',
        },
        timezone: 'Asia/Tokyo',
        currency: 'Japanese Yen (JPY)',
        languages: ['Japanese'],
      ),

      const Location(
        id: 'beijing_china',
        name: 'Beijing',
        country: 'China',
        continent: 'Asia',
        latitude: 39.9042,
        longitude: 116.4074,
        description: 'Ancient capital with imperial palaces and modern political significance.',
        landmarks: ['forbidden_city', 'great_wall', 'tiananmen_square', 'temple_of_heaven'],
        culturalInfo: {
          'history': 'Over 3,000 years of history, imperial dynasties',
          'architecture': 'Traditional Chinese imperial architecture',
          'cuisine': 'Peking duck, traditional Chinese medicine',
          'culture': 'Confucianism, martial arts, calligraphy',
        },
        timezone: 'Asia/Shanghai',
        currency: 'Chinese Yuan (CNY)',
        languages: ['Mandarin Chinese'],
      ),

      // Americas
      const Location(
        id: 'new_york_usa',
        name: 'New York City',
        country: 'United States',
        continent: 'North America',
        latitude: 40.7128,
        longitude: -74.0060,
        description: 'The Big Apple, global financial and cultural center.',
        landmarks: ['statue_of_liberty', 'times_square', 'central_park', 'brooklyn_bridge'],
        culturalInfo: {
          'diversity': 'Melting pot of cultures from around the world',
          'finance': 'Wall Street, global financial center',
          'arts': 'Broadway, museums, jazz and hip-hop origins',
          'architecture': 'Iconic skyscrapers and Art Deco buildings',
        },
        timezone: 'America/New_York',
        currency: 'US Dollar (USD)',
        languages: ['English', 'Spanish'],
      ),

      const Location(
        id: 'rio_de_janeiro_brazil',
        name: 'Rio de Janeiro',
        country: 'Brazil',
        continent: 'South America',
        latitude: -22.9068,
        longitude: -43.1729,
        description: 'Vibrant coastal city famous for Carnival, beaches, and Christ the Redeemer.',
        landmarks: ['christ_the_redeemer', 'copacabana_beach', 'sugarloaf_mountain', 'carnival'],
        culturalInfo: {
          'carnival': 'World-famous Carnival celebration',
          'music': 'Samba, bossa nova birthplace',
          'beach': 'Beautiful beaches and beach culture',
          'nature': 'Tropical climate, surrounded by mountains and ocean',
        },
        timezone: 'America/Sao_Paulo',
        currency: 'Brazilian Real (BRL)',
        languages: ['Portuguese'],
      ),

      // Africa
      const Location(
        id: 'cairo_egypt',
        name: 'Cairo',
        country: 'Egypt',
        continent: 'Africa',
        latitude: 30.0444,
        longitude: 31.2357,
        description: 'Ancient city home to the pyramids and rich pharaonic history.',
        landmarks: ['great_pyramid', 'sphinx', 'egyptian_museum', 'nile_river'],
        culturalInfo: {
          'ancient': 'Ancient Egyptian civilization, pharaohs and pyramids',
          'archaeology': 'Treasures of Tutankhamun and ancient artifacts',
          'river': 'Nile River, lifeblood of Egypt',
          'religion': 'Mix of Islamic and Coptic Christian heritage',
        },
        timezone: 'Africa/Cairo',
        currency: 'Egyptian Pound (EGP)',
        languages: ['Arabic'],
      ),

      // Oceania
      const Location(
        id: 'sydney_australia',
        name: 'Sydney',
        country: 'Australia',
        continent: 'Oceania',
        latitude: -33.8688,
        longitude: 151.2093,
        description: 'Harbor city famous for its opera house and beautiful coastline.',
        landmarks: ['sydney_opera_house', 'harbour_bridge', 'bondi_beach', 'royal_botanic_gardens'],
        culturalInfo: {
          'indigenous': 'Aboriginal culture and Dreamtime stories',
          'multicultural': 'Diverse population from many continents',
          'nature': 'Unique wildlife, beautiful harbors and beaches',
          'lifestyle': 'Outdoor lifestyle, surfing culture',
        },
        timezone: 'Australia/Sydney',
        currency: 'Australian Dollar (AUD)',
        languages: ['English'],
      ),
    ];

    for (final location in locations) {
      _locations[location.id] = location;
    }
  }

  void _loadInitialLandmarks() {
    final landmarks = [
      // Paris landmarks
      const Landmark(
        id: 'eiffel_tower',
        name: 'Eiffel Tower',
        locationId: 'paris_france',
        latitude: 48.8584,
        longitude: 2.2945,
        description: 'Iron lattice tower and symbol of Paris, built for the 1889 World\'s Fair.',
        category: 'Monument',
        historicalInfo: {
          'built': '1889',
          'architect': 'Gustave Eiffel',
          'height': '330 meters',
          'purpose': 'Originally built for the 1889 World\'s Fair',
        },
        entryFee: 25.90,
        openingHours: '9:30 AM - 11:45 PM',
        popularity: 10,
      ),

      const Landmark(
        id: 'louvre_museum',
        name: 'Louvre Museum',
        locationId: 'paris_france',
        latitude: 48.8606,
        longitude: 2.3376,
        description: 'World\'s largest art museum, home to the Mona Lisa.',
        category: 'Museum',
        historicalInfo: {
          'opened': '1793',
          'collection': 'Over 380,000 objects',
          'famous_works': 'Mona Lisa, Venus de Milo, Winged Victory',
          'architecture': 'Former royal palace with glass pyramid entrance',
        },
        entryFee: 17.00,
        openingHours: '9:00 AM - 6:00 PM (closed Tuesdays)',
        popularity: 10,
      ),

      // London landmarks
      const Landmark(
        id: 'big_ben',
        name: 'Big Ben',
        locationId: 'london_uk',
        latitude: 51.4994,
        longitude: -0.1245,
        description: 'Iconic clock tower and symbol of London and Britain.',
        category: 'Monument',
        historicalInfo: {
          'completed': '1859',
          'height': '96 meters',
          'bell_weight': '13.7 tons',
          'architect': 'Augustus Pugin',
        },
        openingHours: 'External viewing only (tours occasionally available)',
        popularity: 10,
      ),

      const Landmark(
        id: 'tower_bridge',
        name: 'Tower Bridge',
        locationId: 'london_uk',
        latitude: 51.5055,
        longitude: -0.0754,
        description: 'Victorian bascule bridge crossing the River Thames.',
        category: 'Bridge',
        historicalInfo: {
          'opened': '1894',
          'construction_time': '8 years',
          'style': 'Victorian Gothic',
          'mechanism': 'Bascule and suspension bridge combination',
        },
        entryFee: 10.60,
        openingHours: '9:30 AM - 6:00 PM',
        popularity: 9,
      ),

      // Rome landmarks
      const Landmark(
        id: 'colosseum',
        name: 'Colosseum',
        locationId: 'rome_italy',
        latitude: 41.8902,
        longitude: 12.4922,
        description: 'Ancient amphitheater where gladiators fought.',
        category: 'Ancient Site',
        historicalInfo: {
          'built': '70-80 AD',
          'capacity': '50,000-80,000 spectators',
          'purpose': 'Gladiatorial contests and public spectacles',
          'architecture': 'Roman concrete and stone',
        },
        entryFee: 16.00,
        openingHours: '8:30 AM - 7:00 PM',
        popularity: 10,
      ),

      // Tokyo landmarks
      const Landmark(
        id: 'tokyo_tower',
        name: 'Tokyo Tower',
        locationId: 'tokyo_japan',
        latitude: 35.6586,
        longitude: 139.7454,
        description: 'Communications tower inspired by the Eiffel Tower.',
        category: 'Tower',
        historicalInfo: {
          'completed': '1958',
          'height': '333 meters',
          'purpose': 'Broadcasting and tourism',
          'design': 'Based on Eiffel Tower but taller',
        },
        entryFee: 1200.00, // Japanese Yen
        openingHours: '9:00 AM - 11:00 PM',
        popularity: 8,
      ),

      // New York landmarks
      const Landmark(
        id: 'statue_of_liberty',
        name: 'Statue of Liberty',
        locationId: 'new_york_usa',
        latitude: 40.6892,
        longitude: -74.0445,
        description: 'Symbol of freedom and democracy, gift from France.',
        category: 'Monument',
        historicalInfo: {
          'dedicated': '1886',
          'height': '93 meters including base',
          'designer': 'Frédéric Auguste Bartholdi',
          'significance': 'Symbol of freedom and democracy',
        },
        entryFee: 23.50,
        openingHours: '8:30 AM - 4:00 PM',
        popularity: 10,
      ),
    ];

    for (final landmark in landmarks) {
      if (!_landmarks.containsKey(landmark.locationId)) {
        _landmarks[landmark.locationId] = [];
      }
      _landmarks[landmark.locationId]!.add(landmark);
    }
  }

  List<Location> getAllLocations() {
    return _locations.values.toList();
  }

  Location? getLocationById(String id) {
    return _locations[id];
  }

  List<Location> getLocationsByContinent(String continent) {
    return _locations.values
        .where((location) => location.continent == continent)
        .toList();
  }

  List<Landmark> getLandmarksForLocation(String locationId) {
    return _landmarks[locationId] ?? [];
  }

  Landmark? getLandmarkById(String landmarkId) {
    for (final landmarks in _landmarks.values) {
      try {
        return landmarks.firstWhere((landmark) => landmark.id == landmarkId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  List<Location> searchLocations(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _locations.values.where((location) {
      return location.name.toLowerCase().contains(lowercaseQuery) ||
             location.country.toLowerCase().contains(lowercaseQuery) ||
             location.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  List<TravelRoute> getRoutesFromLocation(String fromLocationId) {
    // For now, return basic routes - in a real implementation, 
    // this would come from a comprehensive travel database
    final routes = <TravelRoute>[];
    final allLocations = getAllLocations();
    final fromLocation = getLocationById(fromLocationId);
    
    if (fromLocation == null) return routes;

    for (final location in allLocations) {
      if (location.id == fromLocationId) continue;

      // Calculate basic travel info (simplified)
      final distance = _calculateDistance(
        fromLocation.latitude, fromLocation.longitude,
        location.latitude, location.longitude,
      );

      routes.add(TravelRoute(
        fromLocationId: fromLocationId,
        toLocationId: location.id,
        transportMethod: distance > 1000 ? 'Flight' : 'Train',
        durationMinutes: distance > 1000 ? (distance ~/ 10) : (distance ~/ 5),
        cost: distance > 1000 ? (distance * 0.5) : (distance * 0.3),
        isDirectRoute: distance < 2000,
      ));
    }

    return routes;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simplified distance calculation (not accurate, just for demo)
    final dLat = (lat2 - lat1).abs();
    final dLon = (lon2 - lon1).abs();
    return (dLat + dLon) * 111; // Rough km conversion
  }
}