import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lorehunter/routes/geocoding.dart';

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

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  Future<void> _createMarkers() async {
    for (final element in widget.places) {
      final coordinate = await getCoordinates(element);

      LatLng latLng = convertCoordinates(coordinate);
      setState(() {
        coord = latLng;
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
    setState(() {}); // Update UI after coordinates are retrieved
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: coord == null
            ? LatLng(0, 0)
            : coord, // Default to (0, 0) if no coordinates
        zoom: 14.0,
      ),
      markers: _markers,
    );
  }
}
