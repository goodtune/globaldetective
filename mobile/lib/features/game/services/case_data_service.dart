import 'dart:math';

import '../models/case.dart';
import '../models/villain.dart';
import '../models/location.dart';
import 'location_data_service.dart';

class CaseDataService {
  static CaseDataService? _instance;
  static CaseDataService get instance {
    _instance ??= CaseDataService._();
    return _instance!;
  }

  CaseDataService._();

  final Random _random = Random();
  final List<Villain> _villains = [];
  final List<StolenArtifact> _artifacts = [];
  final List<DetectiveCase> _preloadedCases = [];

  bool get isInitialized => _villains.isNotEmpty && _artifacts.isNotEmpty;

  void initialize() {
    if (isInitialized) return;

    _loadVillains();
    _loadArtifacts();
    _generatePreloadedCases();
  }

  void _loadVillains() {
    _villains.addAll([
      const Villain(
        id: 'carmen_sandiego',
        name: 'Carmen Sandiego',
        alias: 'The Lady in Red',
        description: 'Master thief with a love for red coats and cultural artifacts.',
        difficulty: VillainDifficulty.master,
        specialties: ['Art Theft', 'Cultural Artifacts', 'Historical Items'],
        physicalTraits: {
          'hair': 'Black, shoulder-length',
          'clothing': 'Red trench coat and fedora',
          'height': 'Tall and elegant',
          'distinguishing': 'Always wears red',
        },
        personalityTraits: ['Sophisticated', 'Cultured', 'Elusive', 'Dramatic'],
        favoriteLocations: ['paris_france', 'rome_italy', 'cairo_egypt'],
        backstory: 'Former ACME detective turned master thief, specializes in stealing cultural treasures to "preserve" them.',
        preferences: {
          'transportation': 'Private jet',
          'hideouts': 'Museums and cultural sites',
          'motivation': 'Cultural preservation',
        },
      ),

      const Villain(
        id: 'vic_the_slick',
        name: 'Vic the Slick',
        alias: 'The Smooth Operator',
        description: 'Charming con artist who steals through elaborate schemes.',
        difficulty: VillainDifficulty.expert,
        specialties: ['Jewelry', 'Precious Metals', 'Financial Instruments'],
        physicalTraits: {
          'hair': 'Slicked back, dark',
          'clothing': 'Expensive suits',
          'height': 'Medium height',
          'distinguishing': 'Gold tooth, always smiling',
        },
        personalityTraits: ['Charming', 'Manipulative', 'Greedy', 'Smooth-talking'],
        favoriteLocations: ['new_york_usa', 'london_uk', 'tokyo_japan'],
        backstory: 'Started as a small-time pickpocket, now runs elaborate heists targeting the wealthy.',
        preferences: {
          'transportation': 'Luxury cars',
          'hideouts': 'High-end hotels',
          'motivation': 'Wealth and luxury',
        },
      ),

      const Villain(
        id: 'dr_belljar',
        name: 'Dr. Belljar',
        alias: 'The Collector',
        description: 'Eccentric scientist who steals rare specimens and artifacts.',
        difficulty: VillainDifficulty.intermediate,
        specialties: ['Scientific Instruments', 'Rare Books', 'Natural Specimens'],
        physicalTraits: {
          'hair': 'Wild, white hair',
          'clothing': 'Lab coat over casual clothes',
          'height': 'Short and stocky',
          'distinguishing': 'Thick glasses, always carries a magnifying glass',
        },
        personalityTraits: ['Eccentric', 'Intellectual', 'Obsessive', 'Absent-minded'],
        favoriteLocations: ['beijing_china', 'london_uk', 'sydney_australia'],
        backstory: 'Former university professor who turned to theft to acquire rare specimens for private research.',
        preferences: {
          'transportation': 'Commercial flights',
          'hideouts': 'Libraries and laboratories',
          'motivation': 'Scientific discovery',
        },
      ),

      const Villain(
        id: 'contessa_coco',
        name: 'Contessa Coco',
        alias: 'The Fashion Phantom',
        description: 'High-society thief with impeccable taste in fashion and art.',
        difficulty: VillainDifficulty.expert,
        specialties: ['Fashion Items', 'Luxury Goods', 'Modern Art'],
        physicalTraits: {
          'hair': 'Platinum blonde, styled perfectly',
          'clothing': 'Designer outfits, changes frequently',
          'height': 'Tall and graceful',
          'distinguishing': 'Perfect makeup, expensive jewelry',
        },
        personalityTraits: ['Vain', 'Sophisticated', 'Dramatic', 'Trendsetting'],
        favoriteLocations: ['paris_france', 'new_york_usa', 'rio_de_janeiro_brazil'],
        backstory: 'Former fashion model who uses industry connections to steal from the elite.',
        preferences: {
          'transportation': 'Fashion shows and private events',
          'hideouts': 'Boutiques and galleries',
          'motivation': 'Beauty and perfection',
        },
      ),
    ]);
  }

  void _loadArtifacts() {
    _artifacts.addAll([
      const StolenArtifact(
        id: 'mona_lisa_copy',
        name: 'Perfect Copy of Mona Lisa',
        description: 'An incredibly detailed replica that fools even experts.',
        category: 'Painting',
        originLocation: 'paris_france',
        estimatedValue: 100000000,
        historicalSignificance: {
          'artist': 'Leonardo da Vinci (original)',
          'period': 'Renaissance',
          'significance': 'Most famous painting in the world',
          'mystery': 'The enigmatic smile',
        },
        clueKeywords: ['Renaissance', 'Italian', 'Smile', 'Portrait'],
      ),

      const StolenArtifact(
        id: 'crown_jewels_replica',
        name: 'Replica Crown Jewels',
        description: 'Stunning replicas of the British Crown Jewels.',
        category: 'Jewelry',
        originLocation: 'london_uk',
        estimatedValue: 50000000,
        historicalSignificance: {
          'period': 'Various centuries',
          'significance': 'Symbols of British monarchy',
          'materials': 'Gold, precious gems, historical metals',
          'ceremony': 'Used in coronations',
        },
        clueKeywords: ['Royal', 'Crown', 'Gems', 'British'],
      ),

      const StolenArtifact(
        id: 'terracotta_warrior',
        name: 'Ancient Terracotta Warrior',
        description: 'One of the famous terracotta warriors from Xi\'an.',
        category: 'Sculpture',
        originLocation: 'beijing_china',
        estimatedValue: 25000000,
        historicalSignificance: {
          'period': 'Qin Dynasty (210-209 BC)',
          'significance': 'Part of terracotta army',
          'purpose': 'Burial goods for Emperor Qin Shi Huang',
          'discovery': 'Discovered in 1974',
        },
        clueKeywords: ['Ancient', 'Chinese', 'Clay', 'Warrior', 'Emperor'],
      ),

      const StolenArtifact(
        id: 'golden_mask',
        name: 'Golden Pharaoh Mask',
        description: 'Ancient Egyptian golden burial mask.',
        category: 'Artifact',
        originLocation: 'cairo_egypt',
        estimatedValue: 75000000,
        historicalSignificance: {
          'period': 'Ancient Egypt',
          'significance': 'Pharaonic burial treasure',
          'materials': 'Gold and precious stones',
          'purpose': 'Afterlife protection',
        },
        clueKeywords: ['Gold', 'Pharaoh', 'Ancient', 'Egypt', 'Burial'],
      ),

      const StolenArtifact(
        id: 'samurai_sword',
        name: 'Legendary Samurai Katana',
        description: 'A perfectly crafted samurai sword with historical significance.',
        category: 'Weapon',
        originLocation: 'tokyo_japan',
        estimatedValue: 15000000,
        historicalSignificance: {
          'period': 'Edo Period',
          'significance': 'Belonged to famous samurai',
          'craftsmanship': 'Master swordsmith creation',
          'material': 'Folded steel',
        },
        clueKeywords: ['Samurai', 'Steel', 'Japanese', 'Warrior', 'Honor'],
      ),
    ]);
  }

  void _generatePreloadedCases() {
    // Generate a few sample cases for different difficulty levels
    _preloadedCases.addAll([
      _generateCase(CaseDifficulty.rookie),
      _generateCase(CaseDifficulty.detective),
      _generateCase(CaseDifficulty.inspector),
      _generateCase(CaseDifficulty.master),
    ]);
  }

  DetectiveCase generateRandomCase(CaseDifficulty difficulty) {
    return _generateCase(difficulty);
  }

  DetectiveCase _generateCase(CaseDifficulty difficulty) {
    final villain = _getRandomVillain(difficulty);
    final artifact = _getRandomArtifact();
    final locations = LocationDataService.instance.getAllLocations();
    
    // Select locations based on villain preferences and random selection
    final possibleLocations = _selectPossibleLocations(villain, locations, difficulty);
    final startLocation = possibleLocations.first;
    final correctLocation = possibleLocations[1 + _random.nextInt(possibleLocations.length - 1)];
    
    // Generate clues for each location
    final locationClues = <String, List<Clue>>{};
    for (final locationId in possibleLocations) {
      locationClues[locationId] = _generateCluesForLocation(
        locationId, 
        correctLocation, 
        villain, 
        artifact, 
        difficulty
      );
    }

    return DetectiveCase(
      id: 'case_${DateTime.now().millisecondsSinceEpoch}',
      title: 'The Case of the ${artifact.name}',
      description: 'A priceless ${artifact.category.toLowerCase()} has been stolen! '
                  'Follow the clues to track down ${villain.alias} and recover the treasure.',
      briefing: _generateBriefing(villain, artifact),
      difficulty: difficulty,
      villain: villain,
      artifact: artifact,
      startLocationId: startLocation,
      possibleLocations: possibleLocations,
      locationClues: locationClues,
      redHerringLocations: _selectRedHerringLocations(possibleLocations, locations),
      timeLimit: _getTimeLimit(difficulty),
      budgetLimit: _getBudgetLimit(difficulty),
    );
  }

  Villain _getRandomVillain(CaseDifficulty difficulty) {
    final villainDifficulty = _mapCaseDifficultyToVillain(difficulty);
    final suitableVillains = _villains.where((v) => 
        _getDifficultyOrder(v.difficulty) <= _getDifficultyOrder(villainDifficulty)
    ).toList();
    
    return suitableVillains[_random.nextInt(suitableVillains.length)];
  }

  VillainDifficulty _mapCaseDifficultyToVillain(CaseDifficulty caseDifficulty) {
    switch (caseDifficulty) {
      case CaseDifficulty.rookie:
        return VillainDifficulty.rookie;
      case CaseDifficulty.detective:
        return VillainDifficulty.intermediate;
      case CaseDifficulty.inspector:
        return VillainDifficulty.expert;
      case CaseDifficulty.master:
        return VillainDifficulty.master;
    }
  }

  int _getDifficultyOrder(VillainDifficulty difficulty) {
    switch (difficulty) {
      case VillainDifficulty.rookie: return 0;
      case VillainDifficulty.intermediate: return 1;
      case VillainDifficulty.expert: return 2;
      case VillainDifficulty.master: return 3;
    }
  }

  StolenArtifact _getRandomArtifact() {
    return _artifacts[_random.nextInt(_artifacts.length)];
  }

  List<String> _selectPossibleLocations(Villain villain, List<Location> allLocations, CaseDifficulty difficulty) {
    final numLocations = _getNumLocations(difficulty);
    final selected = <String>[];

    // Always include villain's favorite locations if available
    for (final favLocation in villain.favoriteLocations) {
      if (selected.length < numLocations && 
          allLocations.any((l) => l.id == favLocation)) {
        selected.add(favLocation);
      }
    }

    // Fill remaining slots with random locations
    final remaining = allLocations
        .where((l) => !selected.contains(l.id))
        .map((l) => l.id)
        .toList();
    remaining.shuffle(_random);

    while (selected.length < numLocations && remaining.isNotEmpty) {
      selected.add(remaining.removeAt(0));
    }

    return selected;
  }

  int _getNumLocations(CaseDifficulty difficulty) {
    switch (difficulty) {
      case CaseDifficulty.rookie: return 3;
      case CaseDifficulty.detective: return 4;
      case CaseDifficulty.inspector: return 5;
      case CaseDifficulty.master: return 6;
    }
  }

  List<String> _selectRedHerringLocations(List<String> possibleLocations, List<Location> allLocations) {
    final redHerrings = allLocations
        .where((l) => !possibleLocations.contains(l.id))
        .map((l) => l.id)
        .toList();
    redHerrings.shuffle(_random);
    return redHerrings.take(2).toList();
  }

  List<Clue> _generateCluesForLocation(
    String locationId, 
    String correctLocationId, 
    Villain villain, 
    StolenArtifact artifact, 
    CaseDifficulty difficulty
  ) {
    final location = LocationDataService.instance.getLocationById(locationId);
    if (location == null) return [];

    final isCorrectLocation = locationId == correctLocationId;
    final clues = <Clue>[];

    // Generate 2-4 clues per location based on difficulty
    final numClues = 2 + (difficulty.index);
    
    for (int i = 0; i < numClues; i++) {
      clues.add(_generateSingleClue(location, villain, artifact, isCorrectLocation, i));
    }

    return clues;
  }

  Clue _generateSingleClue(Location location, Villain villain, StolenArtifact artifact, bool isCorrect, int index) {
    final clueTypes = ClueType.values;
    final clueType = clueTypes[_random.nextInt(clueTypes.length)];

    return Clue(
      id: 'clue_${location.id}_$index',
      type: clueType,
      title: _generateClueTitle(clueType, location),
      description: _generateClueDescription(clueType, location, villain),
      question: _generateClueQuestion(clueType, location, villain, artifact),
      options: _generateClueOptions(clueType, location, isCorrect),
      correctAnswerIndex: isCorrect ? 0 : _random.nextInt(4),
      explanation: _generateClueExplanation(clueType, location, villain),
      difficultyPoints: 10 + (clueType.index * 5),
    );
  }

  String _generateClueTitle(ClueType type, Location location) {
    switch (type) {
      case ClueType.location: return 'Geographic Clue';
      case ClueType.cultural: return 'Cultural Evidence';
      case ClueType.historical: return 'Historical Reference';
      case ClueType.visual: return 'Visual Sighting';
      case ClueType.interview: return 'Witness Interview';
      case ClueType.evidence: return 'Physical Evidence';
    }
  }

  String _generateClueDescription(ClueType type, Location location, Villain villain) {
    switch (type) {
      case ClueType.location:
        return 'A travel agent remembers selling tickets to someone matching the suspect\'s description.';
      case ClueType.cultural:
        return 'Local cultural experts noticed someone asking unusual questions about ${location.culturalInfo.keys.first}.';
      case ClueType.historical:
        return 'Museum records show someone researching historical artifacts similar to the stolen item.';
      case ClueType.visual:
        return 'Security cameras captured footage of a suspicious person near famous landmarks.';
      case ClueType.interview:
        return 'A local witness saw someone matching ${villain.alias}\'s description acting suspiciously.';
      case ClueType.evidence:
        return 'Forensic analysis found traces that could indicate the thief\'s next destination.';
    }
  }

  String _generateClueQuestion(ClueType type, Location location, Villain villain, StolenArtifact artifact) {
    switch (type) {
      case ClueType.location:
        return 'Based on the geographic clues, what type of climate is the suspect headed to?';
      case ClueType.cultural:
        return 'What cultural tradition was the suspect most interested in learning about?';
      case ClueType.historical:
        return 'Which historical period seems to fascinate this criminal?';
      case ClueType.visual:
        return 'What distinctive item was the suspect wearing in the security footage?';
      case ClueType.interview:
        return 'According to the witness, what did the suspect ask about?';
      case ClueType.evidence:
        return 'What type of evidence suggests the suspect\'s expertise?';
    }
  }

  List<String> _generateClueOptions(ClueType type, Location location, bool isCorrect) {
    // Generate 4 options, with the correct one based on location if isCorrect
    final options = <String>[];
    
    if (isCorrect) {
      options.add(_getCorrectAnswer(type, location));
    } else {
      options.add(_getIncorrectAnswer(type));
    }

    // Add 3 more plausible but incorrect options
    while (options.length < 4) {
      final option = _getRandomAnswer(type);
      if (!options.contains(option)) {
        options.add(option);
      }
    }

    options.shuffle(_random);
    return options;
  }

  String _getCorrectAnswer(ClueType type, Location location) {
    switch (type) {
      case ClueType.location:
        return location.continent;
      case ClueType.cultural:
        return location.culturalInfo.values.first;
      case ClueType.historical:
        return 'Ancient civilizations';
      case ClueType.visual:
        return 'Red coat and hat';
      case ClueType.interview:
        return 'Famous landmarks';
      case ClueType.evidence:
        return 'Art expertise';
    }
  }

  String _getIncorrectAnswer(ClueType type) {
    switch (type) {
      case ClueType.location:
        return 'Different continent';
      case ClueType.cultural:
        return 'Wrong cultural aspect';
      case ClueType.historical:
        return 'Wrong period';
      case ClueType.visual:
        return 'Wrong clothing';
      case ClueType.interview:
        return 'Wrong interest';
      case ClueType.evidence:
        return 'Wrong expertise';
    }
  }

  String _getRandomAnswer(ClueType type) {
    final answers = [
      'Option A', 'Option B', 'Option C', 'Option D',
      'Choice 1', 'Choice 2', 'Choice 3', 'Choice 4'
    ];
    return answers[_random.nextInt(answers.length)];
  }

  String _generateClueExplanation(ClueType type, Location location, Villain villain) {
    return 'This clue points to ${location.name} because of its connection to ${villain.specialties.first}.';
  }

  String _generateBriefing(Villain villain, StolenArtifact artifact) {
    return '''
INTERPOL CASE BRIEFING

SUSPECT: ${villain.name} (aka "${villain.alias}")
STOLEN ITEM: ${artifact.name}
ESTIMATED VALUE: \$${artifact.estimatedValue.toStringAsFixed(0)}

DESCRIPTION:
${villain.description}

The suspect is known for their expertise in ${villain.specialties.join(', ')} and has been spotted in various international locations. They are considered ${villain.difficulty.name} level difficulty.

PHYSICAL DESCRIPTION:
${villain.physicalTraits.entries.map((e) => '${e.key}: ${e.value}').join('\n')}

YOUR MISSION:
Track down the suspect by following clues across multiple international locations. Use your detective skills to identify the correct trail and apprehend the criminal before they escape with the stolen treasure.

Time is of the essence. Good luck, Detective!
''';
  }

  int _getTimeLimit(CaseDifficulty difficulty) {
    switch (difficulty) {
      case CaseDifficulty.rookie: return 240; // 4 hours
      case CaseDifficulty.detective: return 180; // 3 hours
      case CaseDifficulty.inspector: return 120; // 2 hours
      case CaseDifficulty.master: return 90; // 1.5 hours
    }
  }

  int _getBudgetLimit(CaseDifficulty difficulty) {
    switch (difficulty) {
      case CaseDifficulty.rookie: return 8000;
      case CaseDifficulty.detective: return 6000;
      case CaseDifficulty.inspector: return 4000;
      case CaseDifficulty.master: return 3000;
    }
  }

  List<DetectiveCase> getPreloadedCases() {
    return List.unmodifiable(_preloadedCases);
  }

  DetectiveCase? getCaseById(String caseId) {
    try {
      return _preloadedCases.firstWhere((c) => c.id == caseId);
    } catch (e) {
      return null;
    }
  }
}