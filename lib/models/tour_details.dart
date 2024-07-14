import 'package:lorehunter/models/place_details.dart';

class Tour {
  Tour({
    required this.name,
    required this.places,
    required this.brief,
    required this.bestExperiencedAt,
    required this.greeting,
    required this.outro,
    this.distance,
    this.updatedPlaces,
  });

  String name;
  String brief;
  String bestExperiencedAt;

  List<PlaceDetails> places;

  String greeting;
  String outro;

  double? distance;
  List<String>? updatedPlaces;
}
