import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceDetails {
  PlaceDetails({
    required this.name,
    required this.brief,
    required this.type,
    required this.wikiURL,
    required this.tourDuration,
  });
  String name;

  String brief;
  String type;

  String? wikiURL;
  int tourDuration;

  LatLng? coordinates;

  Map<String, dynamic> toJson() => {
        'name': name,
        'brief': brief,
        'type': type,
        'wikiURL': wikiURL,
        'tourDuration': tourDuration,
        'coordinates': coordinates?.toJson(),
      };
}
