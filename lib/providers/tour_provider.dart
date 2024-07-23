import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/providers/place_details_provider.dart';
import 'dart:convert';

import 'package:riverpod/riverpod.dart';

final tourProvider = StateProvider<Tour?>((ref) => null);

Tour getTourFromJson(String jsonString, String city) {
  var jsonMap = jsonDecode(jsonString);

  final tour = Tour(
    name: jsonMap['name'] as String,
    city: city,
    brief: jsonMap['brief'] as String,
    bestExperiencedAt: jsonMap['best_experienced_at'] as String,
    greeting: jsonMap['greetings'] as String,
    outro: jsonMap['outro'] as String,
    places: (jsonMap['places'] as List)
        .map((placeJson) => getPlaceDetailsFromJson(placeJson))
        .toList(),
    distance: jsonMap['distance'] as double,
    updatedPlaces: jsonMap['updatedPlaces'],
    routeCoordinates: (jsonMap['polylineCoordinates'] as List)
        .map((e) => LatLng(e[0]! as double, e[1]! as double))
        .toList(),
    updateTime: DateTime.parse(jsonMap['updateTime'] as String),
  );

  return tour;
}
