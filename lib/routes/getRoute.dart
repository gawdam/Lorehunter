import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> getRoutePolyline(
    String apiKey,
    double originLat,
    double originLon,
    double destinationLat,
    double destinationLon,
    String profile,
    List<Waypoint> waypoints) async {
  final url = Uri.parse('https://api.openrouteservice.org/v2/directions');

  final waypointList = waypoints
      .map((waypoint) =>
          '[${waypoint.lon.toString()},${waypoint.lat.toString()}]')
      .toList(growable: false);
  final waypointString = waypointList.join(',');

  final coordinates =
      '[${originLon.toString()},$originLat.toString()],$waypointString,[${destinationLon.toString()},$destinationLat.toString()]';

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: jsonEncode(<String, dynamic>{
      'coordinates': coordinates,
      'profile': profile,
      'format': 'json',
      'apikey': apiKey,
    }),
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['features'] != null &&
        jsonResponse['features'].isNotEmpty) {
      final geometry = jsonResponse['features'][0]['geometry'];
      return geometry['coordinates']; // Assuming polyline is in coordinates
    } else {
      print('Error: No route found in response');
      return null;
    }
  } else {
    print('Error: API request failed with status code ${response.statusCode}');
    return null;
  }
}

class Waypoint {
  final double lat;
  final double lon;

  const Waypoint(this.lat, this.lon);
}
