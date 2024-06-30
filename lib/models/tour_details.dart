class Tour {
  Tour({
    required this.name,
    required this.places,
    required this.types,
    required this.icons,
    required this.time_of_day,
    this.distance,
  });

  String name;
  List<String> icons;
  List<String> types;
  List<String> places;
  String time_of_day;
  double? distance;
}
