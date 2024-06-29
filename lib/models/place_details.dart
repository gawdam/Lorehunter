import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceDetails {
  PlaceDetails({
    required this.name,
    required this.coordinates,
    required this.time,
    required this.brief,
    required this.detailedAudioTour,
    required this.wikiURL,
  });
  String name;

  LatLng coordinates;
  String time;
  String brief;
  String detailedAudioTour;
  String wikiURL;
}
