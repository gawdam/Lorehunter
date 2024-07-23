import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceDetails {
  PlaceDetails({
    required this.name,
    required this.brief,
    required this.type,
    required this.wikiURL,
    required this.tourDuration,
    this.coordinates,
  });
  String name;

  String brief;
  String type;

  String? wikiURL;
  int tourDuration;

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
