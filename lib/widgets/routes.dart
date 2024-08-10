import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lorehunter/algo/nearest_neighbour.dart';
import 'package:lorehunter/functions/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:lorehunter/functions/get_route.dart';
import 'package:lorehunter/interns/audio_guide_intern.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/providers/tour_provider.dart';

LatLng convertCoordinates(Map<String, dynamic> coordinate) {
  final lat = coordinate['lat'] as double; // Assuming 'latitude' is the key
  final lng = coordinate['lng'] as double; // Assuming 'longitude' is the key
  return (LatLng(lat, lng));
}

class Routes extends ConsumerStatefulWidget {
  final Tour tour;
  final LatLng? focus;

  const Routes({Key? key, required this.tour, this.focus}) : super(key: key);

  @override
  ConsumerState<Routes> createState() => _RoutesState();
}

class _RoutesState extends ConsumerState<Routes> {
  final Set<Marker> _markers = {};

  LatLng coord = LatLng(0, 0);
  List<LatLng> _coordinates = [];
  Map<PolylineId, Polyline> _polylines = {};
  List<String> _updatedAndSortedPlaces = [];

  List<String> _previousPlaces = [];

  GoogleMapController? mapController;
  BitmapDescriptor? markerCheckpoint;
  BitmapDescriptor? markerStart;
  BitmapDescriptor? markerEnd;

  @override
  void initState() {
    super.initState();
    _previousPlaces = List<String>.from(widget.tour.places.map((e) => e.name));
    _createRoute();
  }

  @override
  void didUpdateWidget(covariant Routes oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if places list has changed
    if (List<String>.from(widget.tour.places.map((e) => e.name)) !=
        _previousPlaces) {
      _previousPlaces = List<String>.from(
          widget.tour.places.map((e) => e.name)); // Update previous places
      _clearMapData(); // Clear existing markers, polylines, etc.
      _createRoute(); // Re-create route with updated places
    }
  }

  Future<void> loadAssets() async {
    await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(48, 48)),
            'assets/images/markers/checkpoint.png')
        .then((onValue) {
      markerCheckpoint = onValue;
    });
    await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(48, 48)),
            'assets/images/markers/end.png')
        .then((onValue) {
      markerEnd = onValue;
    });
    await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(48, 48)),
            'assets/images/markers/start.png')
        .then((onValue) {
      markerStart = onValue;
    });
  }

  void _clearMapData() {
    setState(() {
      _markers.clear();
      _coordinates.clear();
      _polylines.clear();
      _updatedAndSortedPlaces.clear();
    });
  }

  Map<String, dynamic> optimizeWaypoints(
      List<LatLng> coordinates, List<String> places) {
    List result = optimizePathNearestNeighbor(
      coordinates,
      places,
    );
    List<LatLng> optimizedCoordinates = result[0];
    List<String> optimizedPlaces = result[1];

    // Create a map to maintain order
    print("OPTIMIZED WAYPOINTS - $optimizedPlaces");

    // Convert sorted map to a sorted list of places
    return {'coordinates': optimizedCoordinates, 'places': optimizedPlaces};
  }

  String convertLatLngListToJson(
      List<LatLng> coordinates, List<String> places) {
    final List<List<double>> latLngList = coordinates
        .map((latLng) => [latLng.longitude, latLng.latitude])
        .toList();

    return jsonEncode({'coordinates': latLngList});
  }

  Future<void> generatePolylineFromPoints() async {
    List<LatLng> polylineCoordinates =
        widget.tour.routeCoordinates ?? await getPolyLinePoints();

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

  LatLng calculateAverageLatLng(List<LatLng> latLngs) {
    if (latLngs.isEmpty) {
      throw ArgumentError('List of LatLngs cannot be empty');
    }

    double totalLatitude = 0.0;
    double totalLongitude = 0.0;

    for (final latLng in latLngs) {
      totalLatitude += latLng.latitude;
      totalLongitude += latLng.longitude;
    }

    double averageLatitude = totalLatitude / latLngs.length;
    double averageLongitude = totalLongitude / latLngs.length;

    return LatLng(averageLatitude, averageLongitude);
  }

  Future<List<LatLng>> getPolyLinePoints() async {
    List<LatLng> polylineCoordinates = [];
    List<PointLatLng> polylineResult;

    List<PolylineWayPoint> waypoints = [];
    print("Before optimization $_updatedAndSortedPlaces");
    Map result = optimizeWaypoints(_coordinates, _updatedAndSortedPlaces);
    setState(() {
      _updatedAndSortedPlaces = result['places'];
    });
    print("After optimization $_updatedAndSortedPlaces");
    List<LatLng> optimizedCoordinates = result['coordinates'];
    var res = await getRoutePolyline(
        convertLatLngListToJson(optimizedCoordinates, _updatedAndSortedPlaces));
    polylineResult = res['result'];
    var dist = res['distance'];

    if (polylineResult.isNotEmpty) {
      polylineResult.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print("some random error: ${polylineResult}");
    }
    Tour? tour = ref.read(tourProvider.notifier).state;

    tour!.distance = dist;
    for (int i = 0; i < tour.places.length; i++) {
      tour.places[i].coordinates = _coordinates[i];
    }
    tour.updatedPlaces = _updatedAndSortedPlaces;
    tour.routeCoordinates = polylineCoordinates;
    // await tour.toJsonFile();

    setState(() {
      ref.invalidate(tourProvider);

      ref.read(tourProvider.notifier).state = tour;
    });
    Marker startMarker = _markers.firstWhere(
        (element) => element.infoWindow.title == _updatedAndSortedPlaces.first);
    Marker endMarker = _markers.firstWhere(
        (element) => element.infoWindow.title == _updatedAndSortedPlaces.last);
    _markers.removeWhere(
        (element) => element.infoWindow.title == _updatedAndSortedPlaces.first);
    _markers.removeWhere(
        (element) => element.infoWindow.title == _updatedAndSortedPlaces.last);
    setState(() {
      _markers.add(
        Marker(
          markerId: startMarker.markerId,
          position: startMarker.position,
          infoWindow: startMarker.infoWindow,
          icon: markerStart!,
        ),
      );
      _markers.add(
        Marker(
          markerId: endMarker.markerId,
          position: endMarker.position,
          infoWindow: endMarker.infoWindow,
          icon: markerEnd!,
        ),
      );
    });

    return polylineCoordinates;
  }

  Future<void> _createMarkers() async {
    List<LatLng> newCoordinates = [];
    List<Marker> newMarkers = [];

    for (final place in widget.tour.places) {
      LatLng? latLng = place.coordinates ?? (await _getLatLngForPlace(place));
      if (latLng != null) {
        newCoordinates.add(latLng);
        Marker marker = _createMarkerForPlace(place, latLng);
        _markers.add(marker);
      }
    }

    setState(() {
      _coordinates.addAll(newCoordinates);
      coord = calculateAverageLatLng(_coordinates);
      _markers.addAll(newMarkers);
    });

    if (mapController != null) {
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: coord, zoom: 13)),
      );
    }
  }

  Future<LatLng?> _getLatLngForPlace(PlaceDetails place) async {
    if (place.coordinates != null) return place.coordinates!;
    final coordinate =
        await getCoordinatesForFree(place.name, widget.tour.city);
    if (coordinate != null) {
      LatLng latLng = convertCoordinates(coordinate);
      _updatedAndSortedPlaces.add(place.name);
      return latLng;
    }
    return null;
  }

  Marker _createMarkerForPlace(PlaceDetails place, LatLng latLng) {
    BitmapDescriptor icon;
    if (place.name == widget.tour.updatedPlaces?.first) {
      icon = markerStart ?? BitmapDescriptor.defaultMarker;
    } else if (place.name == widget.tour.updatedPlaces?.last) {
      icon = markerEnd ?? BitmapDescriptor.defaultMarker;
    } else {
      icon = markerCheckpoint ?? BitmapDescriptor.defaultMarker;
    }

    return Marker(
      markerId: MarkerId(latLng.toString()),
      position: latLng,
      infoWindow: InfoWindow(title: place.name),
      icon: icon,
    );
  }

  Future<Map<String, dynamic>> _createRoute() async {
    await loadAssets();
    await _createMarkers();
    await generatePolylineFromPoints();
    return {'markers': _markers, 'polyline': _polylines};
  }

  void _onMapCreated(GoogleMapController controller) async {
    setState(() {
      mapController = controller;
    });
    coord = calculateAverageLatLng(_coordinates);
    // Update camera position with averageLatLng
    final cameraPosition = CameraPosition(
      target: widget.focus ?? coord, // Default to (0, 0) if no coordinates
      zoom: widget.focus == null ? 13.0 : 16.0,
    );

    await mapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (_markers.isEmpty)
        return Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            child: CircularProgressIndicator());

      return GoogleMap(
        onMapCreated: _onMapCreated,

        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
          target: widget.focus ?? coord, // Default to (0, 0) if no coordinates
          zoom: widget.focus == null ? 13.0 : 16.0,
        ),
        // cameraTargetBounds:
        //     CameraTargetBounds(LatLngBounds.fromList(_coordinates)),
        markers: _markers,
        polylines: Set<Polyline>.of(_polylines.values),
      );
    });
  }
}
