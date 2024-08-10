import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'package:latlong2/latlong.dart' as latlng;

//calculates the route with southmost point and westmost point as starting and whichever is shorter is shortest
List<List<dynamic>> optimizePathNearestNeighbor(
  List<LatLng> points,
  List<String> places,
) {
  print("Lengthofpoints:${points.length}");
  int westStartingIndex = 0;
  for (int i = 1; i < points.length; i++) {
    if (points[i].longitude < points[westStartingIndex].longitude) {
      westStartingIndex = i;
    }
  }

  int southStartingIndex = 0;
  for (int i = 1; i < points.length; i++) {
    if (points[i].latitude < points[southStartingIndex].latitude) {
      southStartingIndex = i;
    }
  }
  List<bool> visited = List<bool>.filled(points.length, false);
  List<LatLng> pathPoints = <LatLng>[];
  List<String> pathPlaces = <String>[];

  List<int> startingIndexCandidates = [westStartingIndex, southStartingIndex];
  double totalMinDistance = double.infinity;
  List<LatLng> finalPathPoints = [];
  List<String> finalPathPlaces = [];

  for (var candidate in startingIndexCandidates) {
    int currentIdx = candidate;
    double totalDistance = 0;

    visited = List<bool>.filled(points.length, false);
    pathPoints = <LatLng>[];
    pathPlaces = <String>[];

    visited[currentIdx] = true;
    pathPoints.add(points[currentIdx]);
    pathPlaces.add(places[currentIdx]);
    for (int i = 0; i < points.length - 1; i++) {
      // print("i=$i");
      double minDistance = double.infinity;
      int nearestIdx = -1;

      for (int j = 0; j < points.length; j++) {
        final candidateDistance = distance(points[currentIdx], points[j]);
        if (!visited[j] && (candidateDistance < minDistance)) {
          // print("j=$j");

          minDistance = candidateDistance;
          nearestIdx = j;
        }
        print("candidate distance = $candidateDistance");
      }
      print("candidate ${places[currentIdx]} -> $minDistance");

      totalDistance = totalDistance + minDistance;
      visited[nearestIdx] = true;
      currentIdx = nearestIdx;

      pathPoints.add(points[currentIdx]);
      pathPlaces.add(places[currentIdx]);
    }
    if (totalDistance < totalMinDistance) {
      totalMinDistance = totalDistance;
      finalPathPlaces = pathPlaces;
      finalPathPoints = pathPoints;
    }
    print("Final path candidate: $finalPathPlaces");
  }

  return [finalPathPoints, finalPathPlaces];
}

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
