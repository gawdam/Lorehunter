import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceDetails {
  PlaceDetails({
    required this.name,
    required this.brief,
    required this.wikiURL,
    required this.tourDuration,
    required this.audioTourHeaders,
    required this.audioTourDescriptions,
    required this.audioTourGreeting,
    required this.audioTourOutro,
  });
  String name;

  String brief;

  String? wikiURL;
  int tourDuration;

  List<String> audioTourHeaders;
  List<String> audioTourDescriptions;
  String audioTourGreeting;
  String audioTourOutro;
}
