import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lorehunter/models/place_details.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/widgets/routes.dart';
import 'dart:convert';

import 'package:riverpod/riverpod.dart';

final placeDetailsProvider = StateProvider<List<PlaceDetails?>?>((ref) => null);

PlaceDetails getPlaceDetailsFromJson(String jsonString) {
  var jsonMap = jsonDecode(jsonString);

// Create a Tour object from the JSON data
  final placeDetails = PlaceDetails(
    name: jsonMap['name'],
    brief: jsonMap['brief'],
    wikiURL: jsonMap['wikiURL'],
    tourDuration: jsonMap['duration'],
    audioTourHeaders: List<String>.from(jsonMap['audioTourHeaders'] as List),
    audioTourDescriptions:
        List<String>.from(jsonMap['audioTourDescriptions'] as List),
    audioTourGreeting: jsonMap['audioTourGreeting'],
    audioTourOutro: jsonMap['audioTourOutro'],
  );
  return placeDetails;
}
