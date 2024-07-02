import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'package:latlong2/latlong.dart' as latlng;

List<List<dynamic>> optimizePathNearestNeighbor(
  List<LatLng> points,
  List<String> places,
) {
  final visited = List<bool>.filled(points.length, false);
  final pathPoints = <LatLng>[];
  final pathPlaces = <String>[];

  // Choose any starting point
  int currentIdx = 0;
  visited[currentIdx] = true;
  pathPoints.add(points[currentIdx]);
  pathPlaces.add(places[currentIdx]);
  // print("place_chosen:${places[currentIdx]}");

  // Repeat until all points are visited
  for (int i = 0; i < points.length - 1; i++) {
    // print("i=$i");
    double minDistance = double.infinity;
    int nearestIdx = -1;
    for (int j = 0; j < points.length; j++) {
      if (!visited[j] &&
          distance(points[currentIdx], points[j]) < minDistance) {
        // print("j=$j");

        minDistance = distance(points[currentIdx], points[j]);
        nearestIdx = j;
      }
    }
    visited[nearestIdx] = true;
    currentIdx = nearestIdx;

    pathPoints.add(points[currentIdx]);
    pathPlaces.add(places[currentIdx]);
  }

  return [pathPoints, pathPlaces];
}

// Replace this with your actual distance calculation function (Haversine formula)
double distance(LatLng p1, LatLng p2) {
  final R = 6371e3; // meters (Earth's radius)
  final lat1 = latlng.degToRadian(p1.latitude);
  final lat2 = latlng.degToRadian(p2.latitude);
  final dLat = latlng.degToRadian(p2.latitude - p1.latitude);
  final dLon = latlng.degToRadian(p2.longitude - p1.longitude);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c;
}
