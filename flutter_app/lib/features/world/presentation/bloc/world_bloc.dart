import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/country.dart';
import '../../domain/entities/landmark.dart';

// Events
abstract class WorldEvent extends Equatable {
  const WorldEvent();

  @override
  List<Object> get props => [];
}

class LoadWorldData extends WorldEvent {}

class LoadCountries extends WorldEvent {}

class LoadLandmarks extends WorldEvent {
  final String? countryId;
  
  const LoadLandmarks({this.countryId});
  
  @override
  List<Object> get props => [countryId ?? ''];
}

class SelectCountry extends WorldEvent {
  final String countryId;
  
  const SelectCountry(this.countryId);
  
  @override
  List<Object> get props => [countryId];
}

class SelectLandmark extends WorldEvent {
  final String landmarkId;
  
  const SelectLandmark(this.landmarkId);
  
  @override
  List<Object> get props => [landmarkId];
}

// States
abstract class WorldState extends Equatable {
  const WorldState();

  @override
  List<Object> get props => [];
}

class WorldInitial extends WorldState {}

class WorldLoading extends WorldState {}

class WorldLoaded extends WorldState {
  final List<Country> countries;
  final List<Landmark> landmarks;
  final Country? selectedCountry;
  final Landmark? selectedLandmark;
  
  const WorldLoaded({
    required this.countries,
    required this.landmarks,
    this.selectedCountry,
    this.selectedLandmark,
  });
  
  @override
  List<Object> get props => [
    countries,
    landmarks,
    selectedCountry ?? '',
    selectedLandmark ?? '',
  ];
  
  WorldLoaded copyWith({
    List<Country>? countries,
    List<Landmark>? landmarks,
    Country? selectedCountry,
    Landmark? selectedLandmark,
  }) {
    return WorldLoaded(
      countries: countries ?? this.countries,
      landmarks: landmarks ?? this.landmarks,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedLandmark: selectedLandmark ?? this.selectedLandmark,
    );
  }
}

class WorldError extends WorldState {
  final String message;
  
  const WorldError(this.message);
  
  @override
  List<Object> get props => [message];
}

// BLoC
class WorldBloc extends Bloc<WorldEvent, WorldState> {
  WorldBloc() : super(WorldInitial()) {
    on<LoadWorldData>(_onLoadWorldData);
    on<LoadCountries>(_onLoadCountries);
    on<LoadLandmarks>(_onLoadLandmarks);
    on<SelectCountry>(_onSelectCountry);
    on<SelectLandmark>(_onSelectLandmark);
  }

  void _onLoadWorldData(LoadWorldData event, Emitter<WorldState> emit) async {
    emit(WorldLoading());
    try {
      // TODO: Load from database
      final countries = _getMockCountries();
      final landmarks = _getMockLandmarks();
      
      emit(WorldLoaded(
        countries: countries,
        landmarks: landmarks,
      ));
    } catch (e) {
      emit(WorldError('Failed to load world data: ${e.toString()}'));
    }
  }

  void _onLoadCountries(LoadCountries event, Emitter<WorldState> emit) async {
    emit(WorldLoading());
    try {
      final countries = _getMockCountries();
      
      if (state is WorldLoaded) {
        final currentState = state as WorldLoaded;
        emit(currentState.copyWith(countries: countries));
      } else {
        emit(WorldLoaded(countries: countries, landmarks: []));
      }
    } catch (e) {
      emit(WorldError('Failed to load countries: ${e.toString()}'));
    }
  }

  void _onLoadLandmarks(LoadLandmarks event, Emitter<WorldState> emit) async {
    try {
      final landmarks = _getMockLandmarks()
          .where((landmark) => event.countryId == null || landmark.countryId == event.countryId)
          .toList();
      
      if (state is WorldLoaded) {
        final currentState = state as WorldLoaded;
        emit(currentState.copyWith(landmarks: landmarks));
      } else {
        emit(WorldLoaded(countries: [], landmarks: landmarks));
      }
    } catch (e) {
      emit(WorldError('Failed to load landmarks: ${e.toString()}'));
    }
  }

  void _onSelectCountry(SelectCountry event, Emitter<WorldState> emit) {
    if (state is WorldLoaded) {
      final currentState = state as WorldLoaded;
      final selectedCountry = currentState.countries
          .where((country) => country.id == event.countryId)
          .firstOrNull;
      
      emit(currentState.copyWith(selectedCountry: selectedCountry));
    }
  }

  void _onSelectLandmark(SelectLandmark event, Emitter<WorldState> emit) {
    if (state is WorldLoaded) {
      final currentState = state as WorldLoaded;
      final selectedLandmark = currentState.landmarks
          .where((landmark) => landmark.id == event.landmarkId)
          .firstOrNull;
      
      emit(currentState.copyWith(selectedLandmark: selectedLandmark));
    }
  }

  List<Country> _getMockCountries() {
    return [
      Country(
        id: 'usa',
        name: 'United States',
        capital: 'Washington D.C.',
        continent: 'North America',
        currency: 'USD',
        population: 331900000,
        coordinatesLat: 39.8283,
        coordinatesLng: -98.5795,
        flagColors: ['Red', 'White', 'Blue'],
        government: 'Federal Republic',
        description: 'A diverse nation spanning from sea to shining sea with rich cultural heritage.',
        createdAt: DateTime.now(),
      ),
      Country(
        id: 'uk',
        name: 'United Kingdom',
        capital: 'London',
        continent: 'Europe',
        currency: 'GBP',
        population: 67800000,
        coordinatesLat: 55.3781,
        coordinatesLng: -3.4360,
        flagColors: ['Red', 'White', 'Blue'],
        government: 'Constitutional Monarchy',
        description: 'Island nation with rolling hills, mountains in Scotland and Wales.',
        createdAt: DateTime.now(),
      ),
      Country(
        id: 'france',
        name: 'France',
        capital: 'Paris',
        continent: 'Europe',
        currency: 'EUR',
        population: 67400000,
        coordinatesLat: 46.2276,
        coordinatesLng: 2.2137,
        flagColors: ['Blue', 'White', 'Red'],
        government: 'Semi-Presidential Republic',
        description: 'Diverse landscapes from Alps to Mediterranean coast.',
        createdAt: DateTime.now(),
      ),
      Country(
        id: 'italy',
        name: 'Italy',
        capital: 'Rome',
        continent: 'Europe',
        currency: 'EUR',
        population: 60400000,
        coordinatesLat: 41.8719,
        coordinatesLng: 12.5674,
        flagColors: ['Green', 'White', 'Red'],
        government: 'Parliamentary Republic',
        description: 'Boot-shaped peninsula with rich history and art.',
        createdAt: DateTime.now(),
      ),
      Country(
        id: 'japan',
        name: 'Japan',
        capital: 'Tokyo',
        continent: 'Asia',
        currency: 'JPY',
        population: 125800000,
        coordinatesLat: 36.2048,
        coordinatesLng: 138.2529,
        flagColors: ['Red', 'White'],
        government: 'Constitutional Monarchy',
        description: 'Mountainous archipelago with active volcanoes.',
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<Landmark> _getMockLandmarks() {
    return [
      Landmark(
        id: 'statue-of-liberty',
        name: 'Statue of Liberty',
        countryId: 'usa',
        city: 'New York',
        type: 'Monument',
        significance: 'Symbol of freedom and democracy',
        description: 'Gift from France, symbol of liberty and democracy.',
        coordinatesLat: 40.6892,
        coordinatesLng: -74.0445,
        createdAt: DateTime.now(),
      ),
      Landmark(
        id: 'big-ben',
        name: 'Big Ben',
        countryId: 'uk',
        city: 'London',
        type: 'Clock Tower',
        significance: 'Iconic symbol of London and British government',
        description: 'Famous clock tower at the Palace of Westminster.',
        coordinatesLat: 51.5007,
        coordinatesLng: -0.1246,
        createdAt: DateTime.now(),
      ),
      Landmark(
        id: 'eiffel-tower',
        name: 'Eiffel Tower',
        countryId: 'france',
        city: 'Paris',
        type: 'Tower',
        significance: 'Symbol of France and architectural marvel',
        description: 'Iron lattice tower and symbol of France.',
        coordinatesLat: 48.8584,
        coordinatesLng: 2.2945,
        createdAt: DateTime.now(),
      ),
      Landmark(
        id: 'colosseum',
        name: 'Colosseum',
        countryId: 'italy',
        city: 'Rome',
        type: 'Amphitheater',
        significance: 'Ancient Roman entertainment and architectural achievement',
        description: 'Ancient Roman amphitheater and architectural marvel.',
        coordinatesLat: 41.8902,
        coordinatesLng: 12.4922,
        createdAt: DateTime.now(),
      ),
      Landmark(
        id: 'tokyo-tower',
        name: 'Tokyo Tower',
        countryId: 'japan',
        city: 'Tokyo',
        type: 'Tower',
        significance: 'Modern symbol of Japan and broadcasting tower',
        description: 'Red and white communications tower inspired by Eiffel Tower.',
        coordinatesLat: 35.6586,
        coordinatesLng: 139.7454,
        createdAt: DateTime.now(),
      ),
    ];
  }
}