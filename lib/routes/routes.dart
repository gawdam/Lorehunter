import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lorehunter/routes/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:lorehunter/routes/getRoute.dart';

LatLng convertCoordinates(Map<String, dynamic> coordinate) {
  final lat = coordinate['lat'] as double; // Assuming 'latitude' is the key
  final lng = coordinate['lng'] as double; // Assuming 'longitude' is the key
  return (LatLng(lat, lng));
}

String convertLatLngListToJson(List<LatLng> coordinates) {
  final List<List<double>> latLngList =
      coordinates.map((latLng) => [latLng.longitude, latLng.latitude]).toList();
  return jsonEncode({'coordinates': latLngList});
}

class Routes extends StatefulWidget {
  final List<String> places;

  const Routes({Key? key, required this.places}) : super(key: key);

  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  final Set<Marker> _markers = {};
  LatLng coord = LatLng(0, 0);
  List<LatLng> coordinates = [];
  Map<PolylineId, Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _createRoute();
  }

  Future<void> generatePolylineFromPoints() async {
    List<LatLng> polylineCoordinates = await getPolyLinePoints();

    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        points: polylineCoordinates,
        color: Colors.black,
        width: 8);
    setState(() {
      _polylines[id] = polyline;
    });
  }

  Future<List<LatLng>> getPolyLinePoints() async {
    await dotenv.load(fileName: ".env");

    final apiKey = dotenv.env['maps_api_key']!;
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = [];
    List<PointLatLng> polylineResult;

    List<PolylineWayPoint> waypoints = [];
    for (var i = 1; i < coordinates.length - 1; i++) {
      waypoints.add(PolylineWayPoint(
          location: "${coordinates[i].latitude}, ${coordinates[i].longitude}"));
    }
    polylineResult =
        await getRoutePolyline(convertLatLngListToJson(coordinates));
    if (polylineResult.isNotEmpty) {
      polylineResult.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print("some random error: ${polylineResult}");
    }
    // print("Distance: ${polylineResult.distance}");

    setState(() {});
    return polylineCoordinates;
  }

  Future<void> _createMarkers() async {
    print(widget.places);
    for (final element in widget.places) {
      final coordinate = await getCoordinatesForFree(element);

      LatLng latLng = convertCoordinates(coordinate);
      setState(() {
        coord = latLng;
        coordinates.add(coord);
      });

      _markers.add(
        Marker(
          markerId: MarkerId(coordinate.toString()),
          position: latLng,
          infoWindow: InfoWindow(
            title: element,
          ),
        ),
      );
      await Future.delayed(Duration(seconds: 1));
    }

    // Update UI after coordinates are retrieved
    setState(() {});
  }

  Future<Map<String, dynamic>> _createRoute() async {
    print("Creating markers");
    await _createMarkers();
    print("Generating polylines");
    await generatePolylineFromPoints();
    print("done generating polylines");
    return {'markers': _markers, 'polyline': _polylines};
  }

  @override
  Widget build(BuildContext context) {
    print(_polylines.values);
    return Builder(builder: (context) {
      if (_markers.isEmpty)
        return Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            child: CircularProgressIndicator());
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: coord, // Default to (0, 0) if no coordinates
          zoom: 14.0,
        ),
        markers: _markers,
        polylines: Set<Polyline>.of(_polylines.values),
      );
    });
  }
}
