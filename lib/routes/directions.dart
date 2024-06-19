import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyMap extends StatefulWidget {
  final List<LatLng> coordinates;

  const MyMap({Key? key, required this.coordinates}) : super(key: key);

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final Set<Marker> _markers = {};
  late String _apiKey;

  @override
  void initState() {
    super.initState();
    _createMarkers();
    initMaps();
  }

  void initMaps() async {
    await dotenv.load(fileName: ".env");

    final apiKey = dotenv.env['maps_api_key']!;
  }

  Future<List<LatLng>> getPolyLinePoints() async {
    await dotenv.load(fileName: ".env");

    final apiKey = dotenv.env['maps_api_key']!;
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    List<PolylineResult> results = [];
    PolylineResult polylineResult;
    for (var i = 0; i < widget.coordinates.length - 1; i++) {
      polylineResult = await polylinePoints.getRouteBetweenCoordinates(
          apiKey,
          PointLatLng(
              widget.coordinates[i].latitude, widget.coordinates[i].latitude),
          PointLatLng(widget.coordinates[i + 1].latitude,
              widget.coordinates[i + 1].latitude),
          travelMode: TravelMode.walking);
      if (polylineResult.points.isNotEmpty) {
        polylineResult.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
        results.add(polylineResult);
      } else {
        print(polylineResult.errorMessage);
      }
    }
    return polylineCoordinates;
  }

  void _createMarkers() {
    for (final coord in widget.coordinates) {
      _markers.add(
        Marker(
          markerId: MarkerId(coord.toString()),
          position: coord,
          infoWindow: InfoWindow(
            title: 'Marker ${widget.coordinates.indexOf(coord) + 1}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.coordinates[0], // Set initial position to first marker
        zoom: 14.0,
      ),
      markers: _markers,
    );
  }
}

// Assuming FlutterMap is a wrapper widget for google_maps_flutter.GoogleMap
