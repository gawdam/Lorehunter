import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:riverpod/riverpod.dart';

// Model class for location data (optional, can be simplified)
class Location {
  final String name;
  final String country;

  Location(this.name, this.country);
}

// Future provider to load locations from JSON data
final locationFutureProvider = FutureProvider<List<Location>>((ref) async {
  final rawData = await rootBundle
      .loadString('assets/cities/cities.json'); // Assuming your JSON file path
  final data = await json.decode(rawData) as List;
  final locations =
      data.map((item) => Location(item['name'], item['country'])).toList();
  print(locations.first);
  return locations;
});

// State provider for a list of filtered city names based on selectedCountry
final cityListProvider = StateProvider<List<String>>((ref) {
  final selectedCountry = ref.watch(selectedCountryProvider);
  return ref.watch(locationFutureProvider).when(
        data: (locations) {
          if (selectedCountry == null) {
            return locations.map((location) => location.name).toList();
          } else {
            final filteredLocations = locations
                .where((location) => location.country == selectedCountry)
                .toList();
            return filteredLocations.map((location) => location.name).toList();
          }
        },
        loading: () => [],
        error: (error, stackTrace) =>
            throw Exception('Error loading locations: $error'),
      );
});

// State provider for a list of unique country names (extracted from locations)
final countryListProvider = StateProvider<List<String>>((ref) {
  return ref.watch(locationFutureProvider).when(
        data: (locations) {
          return locations.map((location) => location.country).toList();
        },
        loading: () => [],
        error: (error, stackTrace) =>
            throw Exception('Error loading locations: $error'),
      );
});

// State provider for selected city
final selectedCityProvider = StateProvider<String?>((ref) => null);

// State provider for selected country
final selectedCountryProvider = StateProvider<String?>((ref) => null);
