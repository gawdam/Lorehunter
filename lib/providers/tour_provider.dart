import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/providers/place_details_provider.dart';
import 'dart:convert';

import 'package:riverpod/riverpod.dart';

final tourProvider = StateProvider<Tour?>((ref) => null);

Tour getTourFromJson(String jsonString, String city) {
  Map jsonMap = jsonDecode(jsonString);

  final tour = Tour(
    name: jsonMap['name'] as String,
    city: jsonMap.containsKey('city') ? jsonMap['city'] : city,
    brief: jsonMap['brief'] as String,
    bestExperiencedAt: jsonMap['bestExperiencedAt'] as String,
    greeting: jsonMap['greeting'] as String,
    outro: jsonMap['outro'] as String,
    places: (jsonMap['places'] as List)
        .map((placeJson) => getPlaceDetailsFromJson(placeJson))
        .toList(),
    distance:
        jsonMap.containsKey("distance") ? jsonMap['distance'] as double : null,
    updatedPlaces: jsonMap.containsKey("updatedPlaces")
        ? List<String>.from(jsonMap['updatedPlaces'] as List)
        : null,
    routeCoordinates: jsonMap.containsKey("routeCoordinates")
        ? (jsonMap['routeCoordinates'] as List)
            .map((e) => LatLng(e[0]! as double, e[1]! as double))
            .toList()
        : null,
    updateTime: jsonMap.containsKey("updateTime")
        ? DateTime.parse(jsonMap['updateTime'] as String)
        : null,
  );

  return tour;
}
