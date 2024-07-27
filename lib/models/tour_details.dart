import 'dart:convert';
import 'dart:io';
import 'package:lorehunter/providers/tour_provider.dart';
import 'package:path/path.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';

class Tour {
  Tour({
    required this.id,
    required this.name,
    required this.city,
    required this.places,
    required this.brief,
    required this.bestExperiencedAt,
    this.distance,
    this.updatedPlaces,
    this.routeCoordinates,
    this.updateTime,
  });

  String id;
  String name;
  String city;
  String brief;
  String bestExperiencedAt;

  List<PlaceDetails> places;

  double? distance;
  List<String>? updatedPlaces;
  List<LatLng>? routeCoordinates;

  DateTime? updateTime;

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'city': city,
        'brief': brief,
        'bestExperiencedAt': bestExperiencedAt,
        'places': places.map((place) => place.toJson()).toList(),
        'distance': distance,
        'updatedPlaces': updatedPlaces,
        'routeCoordinates':
            routeCoordinates?.map((point) => point.toJson()).toList(),
        'updateTime': DateTime.now().toString(),
      };

  Future<void> toJsonFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final toursDirectory = Directory('${directory.path}/tours');
      if (!await toursDirectory.exists()) {
        await toursDirectory.create(recursive: true);
      }
      final file = File('${toursDirectory.path}/$id.json');
      final jsonData = jsonEncode(toJson());
      await file.writeAsString(jsonData);
      print('JSON file saved successfully!');
    } catch (error) {
      print("JSON save error - ${error.toString()}");
    }
  }

  factory Tour.fromJson(String jsonString) => getTourFromJson(jsonString, '');
}

Future<List<Tour>> getToursFromFiles() async {
  final baseDirectory = await getApplicationDocumentsDirectory();
  final directory = Directory("${baseDirectory.path}/tours");
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

class PlaceDetails {
  PlaceDetails({
    required this.name,
    required this.brief,
    required this.type,
    required this.tourDuration,
    required this.wikiURL,
    this.imageURL,
    this.coordinates,
  });
  String name;

  String brief;
  String type;
  int tourDuration;

  String? wikiURL;
  String? imageURL;

  LatLng? coordinates;

  Map<String, dynamic> toJson() => {
        'place_name': name,
        'place_brief': brief,
        'place_type': type,
        'place_wikiURL': wikiURL,
        'place_duration': tourDuration,
        'coordinates': coordinates?.toJson(),
      };
}
