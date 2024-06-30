import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'dart:convert';

import 'package:riverpod/riverpod.dart';

final tourProvider = StateProvider<Tour?>((ref) => null);

Tour getTourFromJson(String jsonString) {
  var jsonMap = jsonDecode(jsonString);

// Create a Tour object from the JSON data
  final tour = Tour(
    name: jsonMap['name'] as String,
    places: List<String>.from(jsonMap['places'] as List),
    types: List<String>.from(jsonMap['types'] as List),
    icons: List<String>.from(jsonMap['icons'] as List),
    time_of_day: jsonMap['best_experienced_at'] as String,
  );
  return tour;
}
