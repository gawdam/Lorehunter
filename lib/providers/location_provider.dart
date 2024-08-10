import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lorehunter/models/location_details.dart';
import 'dart:convert';

import 'package:riverpod/riverpod.dart';

final locationFutureProvider = FutureProvider<List<CityCountry>>((ref) async {
  final rawData = await rootBundle
      .loadString('assets/cities/cities.json'); // Assuming your JSON file path
  final data = await json.decode(rawData) as Map<String, dynamic>;
  final locations = <CityCountry>[];

  data.forEach((countryName, countryData) {
    final countryCode = countryData['country_code'] as String;
    final lore = countryData['lore'] as String;
    final cities = countryData['cities'] as Map<String, dynamic>;

    cities.forEach((cityName, cityData) {
      final city = CityCountry.fromJson(
          countryName, countryCode, lore, {'name': cityName, ...cityData});
      locations.add(city);
    });
  });

  return locations;
});

// State provider for a list of filtered city names based on selectedCountry
final cityListProvider = StateProvider<List<CityCountry>>((ref) {
  final selectedCountry = ref.watch(selectedCountryProvider);
  return ref.watch(locationFutureProvider).when(
        data: (locations) {
          if (selectedCountry == null) {
            return locations;
          } else {
            final filteredLocations = locations
                .where((location) => location.countryName == selectedCountry)
                .toSet()
                .toList();
            return filteredLocations;
          }
        },
        loading: () => [],
        error: (error, stackTrace) =>
            throw Exception('Error loading locations: $error'),
      );
});

final countryListProvider = StateProvider<List<CityCountry>>((ref) {
  return ref.watch(locationFutureProvider).when(
        data: (locations) {
          return locations;
        },
        loading: () => [],
        error: (error, stackTrace) =>
            throw Exception('Error loading locations: $error'),
      );
});

// State provider for selected city
final selectedCityProvider = StateProvider<String?>((ref) => "Paris");

// State provider for selected country
final selectedCountryProvider = StateProvider<String?>((ref) => "France");
