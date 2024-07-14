import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lorehunter/models/place_details.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/providers/place_details_provider.dart';
import 'dart:convert';

import 'package:riverpod/riverpod.dart';

final tourProvider = StateProvider<Tour?>((ref) => null);

Tour getTourFromJson(String jsonString) {
  var jsonMap = jsonDecode(jsonString);

  print("JSONMAP: ${(jsonMap['places'] as List)}");
// Create a Tour object from the JSON data
  final tour = Tour(
    name: jsonMap['name'] as String,
    brief: jsonMap['brief'] as String,
    bestExperiencedAt: jsonMap['best_experienced_at'] as String,
    greeting: jsonMap['greetings'] as String,
    outro: jsonMap['outro'] as String,
    places: (jsonMap['places'] as List)
        .map((placeJson) => getPlaceDetailsFromJson(placeJson))
        .toList(),
  );

  return tour;
}
