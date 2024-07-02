import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lorehunter/models/location_details.dart';
import 'dart:convert';

import 'package:riverpod/riverpod.dart';

// Future provider to load locations from JSON data
final locationFutureProvider = FutureProvider<List<CityCountry>>((ref) async {
  final rawData = await rootBundle
      .loadString('assets/cities/cities.json'); // Assuming your JSON file path
  final data = await json.decode(rawData) as List;
  final locations =
      data.map((item) => CityCountry(item['name'], item['country'])).toList();
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
                .toSet()
                .toList();
            return filteredLocations
                .map((location) => location.name)
                .toSet()
                .toList();
          }
        },
        loading: () => ['none'],
        error: (error, stackTrace) =>
            throw Exception('Error loading locations: $error'),
      );
});

// State provider for a list of unique country names (extracted from locations)
final countryListProvider = StateProvider<List<String>>((ref) {
  return ref.watch(locationFutureProvider).when(
        data: (locations) {
          return locations.map((location) => location.country).toSet().toList();
        },
        loading: () => ['none'],
        error: (error, stackTrace) =>
            throw Exception('Error loading locations: $error'),
      );
});

// State provider for selected city
final selectedCityProvider = StateProvider<String?>((ref) => "New York");

// State provider for selected country
final selectedCountryProvider = StateProvider<String?>((ref) => "US");
