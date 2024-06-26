import 'dart:convert';
import 'dart:math';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;

Map<String, dynamic> parseRouteData(String responseBody) {
  final jsonResponse = jsonDecode(responseBody);
  if (jsonResponse != null && jsonResponse['routes'] != null) {
    final firstRoute = jsonResponse['routes'][0];
    final geometry = firstRoute['geometry'];
    final distance = firstRoute['summary']['distance'];
    return {'geometry': geometry, 'distance': distance};
  } else {
    print('Error: Invalid JSON response or missing routes data');
    return {};
  }
}

Future<List<PointLatLng>> getRoutePolyline(String coordinates) async {
  PolylinePoints polylinePoints = PolylinePoints();
  final headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept':
        'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
    'Authorization': '5b3ce3597851110001cf6248e8423d486ac548b584796d17f2ca0e51',
  };

  final url =
      Uri.parse('https://api.openrouteservice.org/v2/directions/foot-walking');

  final data = '{"coordinates":[[4.29424,52.086175],[4.31492,52.079792]]}';

  final res = await http.post(url, headers: headers, body: coordinates);
  final status = res.statusCode;
  if (status != 200) throw Exception('http.post error: statusCode= $status');
  Map<String, dynamic> value = parseRouteData(res.body);
  List<PointLatLng> result = polylinePoints.decodePolyline(value['geometry']);
  return result;
}
