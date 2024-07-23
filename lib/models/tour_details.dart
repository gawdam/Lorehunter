import 'dart:convert';
import 'dart:io';
import 'package:lorehunter/providers/tour_provider.dart';
import 'package:path/path.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lorehunter/models/place_details.dart';
import 'package:path_provider/path_provider.dart';

class Tour {
  Tour({
    required this.name,
    required this.city,
    required this.places,
    required this.brief,
    required this.bestExperiencedAt,
    required this.greeting,
    required this.outro,
    this.distance,
    this.updatedPlaces,
    this.routeCoordinates,
    this.updateTime,
  });

  String name;
  String city;
  String brief;
  String bestExperiencedAt;

  List<PlaceDetails> places;

  String greeting;
  String outro;

  double? distance;
  List<String>? updatedPlaces;
  List<LatLng>? routeCoordinates;

  DateTime? updateTime;

  Map<String, dynamic> toJson() => {
        'name': name,
        'city': city,
        'brief': brief,
        'bestExperiencedAt': bestExperiencedAt,
        'places': places.map((place) => place.toJson()).toList(),
        'greeting': greeting,
        'outro': outro,
        'distance': distance,
        'updatedPlaces': updatedPlaces,
        'routeCoordinates':
            routeCoordinates?.map((point) => point.toJson()).toList(),
        'updateTime': DateTime.now().toString(),
      };
  Future<void> toJsonFile(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename.json');
      final jsonData = jsonEncode(toJson());
      print(jsonData);
      await file.writeAsString(jsonData);
      print('JSON file saved successfully!');
    } catch (error) {
      print("JSON save error - ${error.toString()}");
    }
  }

  factory Tour.fromJson(String jsonString) => getTourFromJson(jsonString, '');
}

Future<List<Tour>> getToursFromFiles() async {
  final directory = await getApplicationDocumentsDirectory();
  final tours = <Tour>[];

  final files = await directory
      .list()
      .where((entity) => entity is File && entity.path.endsWith('.json'))
      .toList();

  for (final file in files) {
    try {
      if (file is File) {
        final jsonData = await file.readAsString();
        final tour = Tour.fromJson(jsonData);
        tours.add(tour);
      }
    } catch (error) {
      print('Error reading file ${file.path}: $error');
    }
  }

  return tours;
}
