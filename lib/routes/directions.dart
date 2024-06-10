import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyMap extends StatefulWidget {
  final List<LatLng> coordinates;

  const MyMap({Key? key, required this.coordinates}) : super(key: key);

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
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
