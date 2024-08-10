import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:riverpod/riverpod.dart';

final tourProvider = StateProvider<Tour?>((ref) => null);

Tour getTourFromJson(String jsonString, String city) {
  var uuid = Uuid();

  Map jsonMap = jsonDecode(jsonString);

  final tour = Tour(
    id: jsonMap.containsKey('id') ? jsonMap['id'] : uuid.v1(),
    name: jsonMap['name'] as String,
    city: jsonMap.containsKey('city') ? jsonMap['city'] : city,
    brief: jsonMap['brief'] as String,
    bestExperiencedAt: jsonMap['bestExperiencedAt'] as String,
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

final placeDetailsProvider = StateProvider<List<PlaceDetails?>?>((ref) => null);

PlaceDetails getPlaceDetailsFromJson(Map jsonMap) {
// Create a Tour object from the JSON data
  final placeDetails = PlaceDetails(
      name: jsonMap['place_name'],
      brief: jsonMap['place_brief'],
      wikiURL: jsonMap['place_wikiURL'],
      tourDuration: jsonMap['place_duration'],
      type: jsonMap['place_type'],
      coordinates: jsonMap.containsKey('coordinates')
          ? LatLng(jsonMap['coordinates'][0] as double,
              jsonMap['coordinates'][1] as double)
          : null,
      imageURL: jsonMap.containsKey('place_imageURL')
          ? (jsonMap['place_imageURL'])
          : null);
  return placeDetails;
}
