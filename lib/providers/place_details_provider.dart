import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lorehunter/models/place_details.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/widgets/routes.dart';
import 'dart:convert';

import 'package:riverpod/riverpod.dart';

final placeDetailsProvider = StateProvider<List<PlaceDetails?>?>((ref) => null);

PlaceDetails getPlaceDetailsFromJson(Map jsonMap) {
// Create a Tour object from the JSON data
  final placeDetails = PlaceDetails(
    name: jsonMap['place_name'],
    brief: jsonMap['place_brief'],
    wikiURL: jsonMap['place_wikiURL'],
    tourDuration: jsonMap['place_duration'],
    type: jsonMap['place_type'],
  );
  return placeDetails;
}
