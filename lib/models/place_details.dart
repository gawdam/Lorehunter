import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceDetails {
  PlaceDetails({
    required this.name,
    required this.brief,
    required this.detailedAudioTour,
    required this.wikiURL,
    required this.tourDuration,
  });
  String name;

  String brief;
  String detailedAudioTour;
  String? wikiURL;
  String tourDuration;
}
