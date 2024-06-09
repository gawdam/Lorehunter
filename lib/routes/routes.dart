import 'package:lorehunter/routes/geocoding.dart';

class Routes {
  Routes(this.places);
  List<String> places;
  final List<Map<String, double>> coordinates = [];

  void getRoute() {
    places.forEach((element) async {
      final coordinate = await getCoordinates(element);
      coordinates.add(coordinate);
    });
  }
}
