import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;
  
  Database? _database;
  
  DatabaseService._internal();
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<void> initialize() async {
    await database;
  }
  
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'global_detective.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create tables
    await _createTables(db);
    
    // Populate with initial data
    await _populateInitialData(db);
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
      // Add migration logic
    }
  }
  
  Future<void> _createTables(Database db) async {
    // Countries table
    await db.execute('''
      CREATE TABLE countries (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        capital TEXT NOT NULL,
        continent TEXT NOT NULL,
        currency TEXT NOT NULL,
        population INTEGER,
        coordinates_lat REAL,
        coordinates_lng REAL,
        flag_colors TEXT,
        government TEXT,
        description TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Landmarks table
    await db.execute('''
      CREATE TABLE landmarks (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        country_id TEXT NOT NULL,
        city TEXT,
        type TEXT NOT NULL,
        significance TEXT,
        description TEXT,
        coordinates_lat REAL,
        coordinates_lng REAL,
        image_url TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (country_id) REFERENCES countries (id)
      )
    ''');
    
    // Cases table
    await db.execute('''
      CREATE TABLE cases (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        suspect_name TEXT NOT NULL,
        suspect_description TEXT,
        artifact_name TEXT NOT NULL,
        artifact_description TEXT,
        time_limit INTEGER NOT NULL,
        budget_required INTEGER NOT NULL,
        reward_amount INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Clues table
    await db.execute('''
      CREATE TABLE clues (
        id TEXT PRIMARY KEY,
        case_id TEXT NOT NULL,
        location_id TEXT NOT NULL,
        location_type TEXT NOT NULL,
        clue_type TEXT NOT NULL,
        content TEXT NOT NULL,
        is_red_herring INTEGER DEFAULT 0,
        points_to_country_id TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (case_id) REFERENCES cases (id)
      )
    ''');
    
    // Players table
    await db.execute('''
      CREATE TABLE players (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        rank TEXT DEFAULT 'Rookie',
        total_score INTEGER DEFAULT 0,
        cases_solved INTEGER DEFAULT 0,
        current_budget INTEGER DEFAULT 5000,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Game sessions table
    await db.execute('''
      CREATE TABLE game_sessions (
        id TEXT PRIMARY KEY,
        player_id TEXT NOT NULL,
        case_id TEXT NOT NULL,
        status TEXT DEFAULT 'active',
        current_location TEXT,
        time_remaining INTEGER,
        budget_remaining INTEGER,
        clues_found TEXT,
        started_at TEXT DEFAULT CURRENT_TIMESTAMP,
        completed_at TEXT,
        FOREIGN KEY (player_id) REFERENCES players (id),
        FOREIGN KEY (case_id) REFERENCES cases (id)
      )
    ''');
  }
  
  Future<void> _populateInitialData(Database db) async {
    // Insert countries
    await _insertCountries(db);
    
    // Insert landmarks
    await _insertLandmarks(db);
    
    // Insert cases
    await _insertCases(db);
    
    // Insert clues
    await _insertClues(db);
  }
  
  Future<void> _insertCountries(Database db) async {
    final countries = [
      {
        'id': 'usa',
        'name': 'United States',
        'capital': 'Washington D.C.',
        'continent': 'North America',
        'currency': 'USD',
        'population': 331900000,
        'coordinates_lat': 39.8283,
        'coordinates_lng': -98.5795,
        'flag_colors': 'Red,White,Blue',
        'government': 'Federal Republic',
        'description': 'A diverse nation spanning from sea to shining sea with rich cultural heritage.',
      },
      {
        'id': 'uk',
        'name': 'United Kingdom',
        'capital': 'London',
        'continent': 'Europe',
        'currency': 'GBP',
        'population': 67800000,
        'coordinates_lat': 55.3781,
        'coordinates_lng': -3.4360,
        'flag_colors': 'Red,White,Blue',
        'government': 'Constitutional Monarchy',
        'description': 'Island nation with rolling hills, mountains in Scotland and Wales.',
      },
      {
        'id': 'france',
        'name': 'France',
        'capital': 'Paris',
        'continent': 'Europe',
        'currency': 'EUR',
        'population': 67400000,
        'coordinates_lat': 46.2276,
        'coordinates_lng': 2.2137,
        'flag_colors': 'Blue,White,Red',
        'government': 'Semi-Presidential Republic',
        'description': 'Diverse landscapes from Alps to Mediterranean coast.',
      },
      {
        'id': 'italy',
        'name': 'Italy',
        'capital': 'Rome',
        'continent': 'Europe',
        'currency': 'EUR',
        'population': 60400000,
        'coordinates_lat': 41.8719,
        'coordinates_lng': 12.5674,
        'flag_colors': 'Green,White,Red',
        'government': 'Parliamentary Republic',
        'description': 'Boot-shaped peninsula with rich history and art.',
      },
      {
        'id': 'japan',
        'name': 'Japan',
        'capital': 'Tokyo',
        'continent': 'Asia',
        'currency': 'JPY',
        'population': 125800000,
        'coordinates_lat': 36.2048,
        'coordinates_lng': 138.2529,
        'flag_colors': 'Red,White',
        'government': 'Constitutional Monarchy',
        'description': 'Mountainous archipelago with active volcanoes.',
      },
    ];
    
    for (final country in countries) {
      await db.insert('countries', country);
    }
  }
  
  Future<void> _insertLandmarks(Database db) async {
    final landmarks = [
      {
        'id': 'statue-of-liberty',
        'name': 'Statue of Liberty',
        'country_id': 'usa',
        'city': 'New York',
        'type': 'Monument',
        'significance': 'Symbol of freedom and democracy',
        'description': 'Gift from France, symbol of liberty and democracy.',
        'coordinates_lat': 40.6892,
        'coordinates_lng': -74.0445,
      },
      {
        'id': 'big-ben',
        'name': 'Big Ben',
        'country_id': 'uk',
        'city': 'London',
        'type': 'Clock Tower',
        'significance': 'Iconic symbol of London and British government',
        'description': 'Famous clock tower at the Palace of Westminster.',
        'coordinates_lat': 51.5007,
        'coordinates_lng': -0.1246,
      },
      {
        'id': 'eiffel-tower',
        'name': 'Eiffel Tower',
        'country_id': 'france',
        'city': 'Paris',
        'type': 'Tower',
        'significance': 'Symbol of France and architectural marvel',
        'description': 'Iron lattice tower and symbol of France.',
        'coordinates_lat': 48.8584,
        'coordinates_lng': 2.2945,
      },
      {
        'id': 'colosseum',
        'name': 'Colosseum',
        'country_id': 'italy',
        'city': 'Rome',
        'type': 'Amphitheater',
        'significance': 'Ancient Roman entertainment and architectural achievement',
        'description': 'Ancient Roman amphitheater and architectural marvel.',
        'coordinates_lat': 41.8902,
        'coordinates_lng': 12.4922,
      },
      {
        'id': 'tokyo-tower',
        'name': 'Tokyo Tower',
        'country_id': 'japan',
        'city': 'Tokyo',
        'type': 'Tower',
        'significance': 'Modern symbol of Japan and broadcasting tower',
        'description': 'Red and white communications tower inspired by Eiffel Tower.',
        'coordinates_lat': 35.6586,
        'coordinates_lng': 139.7454,
      },
    ];
    
    for (final landmark in landmarks) {
      await db.insert('landmarks', landmark);
    }
  }
  
  Future<void> _insertCases(Database db) async {
    final cases = [
      {
        'id': 'crown-jewels',
        'title': 'The Missing Crown Jewels',
        'description': 'The British Crown Jewels have vanished from the Tower of London! Track down the thief across international borders.',
        'difficulty': 'Rookie',
        'suspect_name': 'Lady Agatha',
        'suspect_description': 'Sophisticated art thief with a preference for historical artifacts',
        'artifact_name': 'Crown Jewels',
        'artifact_description': 'Priceless collection including the Imperial State Crown',
        'time_limit': 120,
        'budget_required': 3000,
        'reward_amount': 5000,
      },
      {
        'id': 'venus-statue',
        'title': 'The Vanishing Venus',
        'description': 'A priceless Venus statue has disappeared from the Louvre! Follow the art smuggling trail.',
        'difficulty': 'Detective',
        'suspect_name': 'Katherine Drib',
        'suspect_description': 'International art smuggler with connections in major galleries',
        'artifact_name': 'Venus de Milo Replica',
        'artifact_description': 'Incredibly detailed ancient Greek statue replica',
        'time_limit': 90,
        'budget_required': 5000,
        'reward_amount': 8000,
      },
      {
        'id': 'liberty-bell',
        'title': 'Liberty Bell Heist',
        'description': 'The Liberty Bell has been stolen from Independence Hall! Stop this attack on American history.',
        'difficulty': 'Inspector',
        'suspect_name': 'Fast Eddie B',
        'suspect_description': 'Quick-moving thief specializing in patriotic symbols',
        'artifact_name': 'Liberty Bell',
        'artifact_description': 'Historic symbol of American independence with famous crack',
        'time_limit': 60,
        'budget_required': 8000,
        'reward_amount': 12000,
      },
    ];
    
    for (final case in cases) {
      await db.insert('cases', case);
    }
  }
  
  Future<void> _insertClues(Database db) async {
    final clues = [
      // Crown Jewels case clues
      {
        'id': 'clue-1',
        'case_id': 'crown-jewels',
        'location_id': 'big-ben',
        'location_type': 'landmark',
        'clue_type': 'Cultural',
        'content': 'A witness saw someone with a French accent near the tower.',
        'is_red_herring': 0,
        'points_to_country_id': 'france',
      },
      {
        'id': 'clue-2',
        'case_id': 'crown-jewels',
        'location_id': 'eiffel-tower',
        'location_type': 'landmark',
        'clue_type': 'Historical',
        'content': 'The suspect was asking about countries that use the Euro currency.',
        'is_red_herring': 0,
        'points_to_country_id': 'italy',
      },
      {
        'id': 'clue-3',
        'case_id': 'crown-jewels',
        'location_id': 'usa',
        'location_type': 'country',
        'clue_type': 'Geographic',
        'content': 'Someone mentioned visiting a boot-shaped country.',
        'is_red_herring': 1,
        'points_to_country_id': null,
      },
    ];
    
    for (final clue in clues) {
      await db.insert('clues', clue);
    }
  }
  
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}