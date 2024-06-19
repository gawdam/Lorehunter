import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lorehunter/routes/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

LatLng convertCoordinates(Map<String, dynamic> coordinate) {
  final lat = coordinate['lat'] as double; // Assuming 'latitude' is the key
  final lng = coordinate['lng'] as double; // Assuming 'longitude' is the key
  return (LatLng(lat, lng));
}

class Routes extends StatefulWidget {
  final List<String> places;

  const Routes({Key? key, required this.places}) : super(key: key);

  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  final Set<Marker> _markers = {};
  late LatLng coord;
  List<LatLng> coordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  Future<void> generatePolylineFromPoints() async {
    print("Called first");
    List<LatLng> polylineCoordinates = await getPolyLinePoints();
    print(
        "--------------------------------------------${polylineCoordinates[0]}-----------------------------------------------------");

    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        points: polylineCoordinates,
        color: Colors.black,
        width: 8);
    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<List<LatLng>> getPolyLinePoints() async {
    print("Called interior");
    await dotenv.load(fileName: ".env");

    final apiKey = dotenv.env['maps_api_key']!;
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    List<PolylineResult> results = [];
    PolylineResult polylineResult;
    for (var i = 0; i < coordinates.length - 1; i++) {
      polylineResult = await polylinePoints.getRouteBetweenCoordinates(
          apiKey,
          PointLatLng(coordinates[i].latitude, coordinates[i].longitude),
          PointLatLng(
              coordinates[i + 1].latitude, coordinates[i + 1].longitude),
          travelMode: TravelMode.walking);
      if (polylineResult.points.isNotEmpty) {
        polylineResult.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
        results.add(polylineResult);
      } else {
        print("some random error: ${polylineResult.errorMessage}");
      }
    }
    setState(() {});
    return polylineCoordinates;
  }

  Future<void> _createMarkers() async {
    print("Error here");
    for (final element in widget.places) {
      final coordinate = await getCoordinates(element);

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
            title: 'Marker',
          ),
        ),
      );
    }
    setState(() {});
    await generatePolylineFromPoints();
    setState(() {});

    // Update UI after coordinates are retrieved
  }

  @override
  Widget build(BuildContext context) {
    generatePolylineFromPoints();
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: coord == null
            ? LatLng(0, 0)
            : coord, // Default to (0, 0) if no coordinates
        zoom: 14.0,
      ),
      markers: _markers,
      polylines: Set<Polyline>.of(polylines.values),
    );
  }
}
