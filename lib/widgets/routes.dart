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

  const Routes({Key? key, required this.tour}) : super(key: key);

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
    List<Map> sortedByCoord = List.generate(coordinates.length,
        (index) => {'coord': coordinates[index], 'place': places[index]});
    sortedByCoord
        .sort((a, b) => a['coord'].latitude.compareTo(b['coord'].latitude));
    print("UNOPTIMZED WAYPOINTS - ${places}");
    print(
        "ORDERED WAYPOINTS: ${List.generate(coordinates.length, (index) => sortedByCoord[index]['place'])}");
    List result = optimizePathNearestNeighbor(
      List.generate(
          coordinates.length, (index) => sortedByCoord[index]['coord']),
      List.generate(
          coordinates.length, (index) => sortedByCoord[index]['place']),
    );
    print("OPTIMZED WAYPOINTS - ${result[1]}");
    List<LatLng> optimizedCoordinates = result[0];
    List<String> optimizedPlaces = result[1];

    // Create a map to maintain order

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
        color: Color.fromARGB(255, 17, 65, 224)!,
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
    Map result = optimizeWaypoints(_coordinates, _updatedAndSortedPlaces);
    setState(() {
      _updatedAndSortedPlaces = result['places'];
    });
    List<LatLng> optimizedCoordinates = result['coordinates'];
    for (var i = 1; i < optimizedCoordinates.length - 1; i++) {
      waypoints.add(PolylineWayPoint(
          location:
              "${optimizedCoordinates[i].latitude}, ${optimizedCoordinates[i].longitude}"));
    }
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
    for (int i = 0; i < _coordinates.length; i++) {
      tour.places[i].coordinates = _coordinates[i];
    }
    tour.updatedPlaces = _updatedAndSortedPlaces;
    tour.routeCoordinates = polylineCoordinates;
    await tour.toJsonFile();
    ref.read(tourProvider.notifier).state = tour;

    setState(() {});
    return polylineCoordinates;
  }

  Future<void> _createMarkers() async {
    for (final place in widget.tour.places) {
      LatLng latLng;
      if (place.coordinates == null) {
        final coordinate =
            await getCoordinatesForFree(place.name, widget.tour.city);
        if (coordinate != null) {
          LatLng latLng = convertCoordinates(coordinate);

          setState(() {
            _coordinates.add(latLng);
            coord = calculateAverageLatLng(_coordinates);
            mapController?.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: coord, zoom: 13)));
          });

          _updatedAndSortedPlaces.add(place.name);

          _markers.add(
            Marker(
              markerId: MarkerId(coordinate.toString()),
              position: latLng,
              infoWindow: InfoWindow(
                title: place.name,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            ),
          );
          await Future.delayed(Duration(seconds: 1));
        }
      } else {
        latLng = place.coordinates!;
        setState(() {
          _coordinates.add(latLng);
          coord = calculateAverageLatLng(_coordinates);
        });

        _markers.add(
          Marker(
            markerId: MarkerId(latLng.toString()),
            position: latLng,
            infoWindow: InfoWindow(
              title: place.name,
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    }
    // await mapController!.animateCamera(CameraUpdate.newCameraPosition(
    //     CameraPosition(target: coord, zoom: 13)));
    setState(() {});
  }

  Future<Map<String, dynamic>> _createRoute() async {
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
      target: coord,
      zoom: 13.0, // Adjust zoom level if needed
    );

    // await mapController!
    //     .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
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
          target: coord, // Default to (0, 0) if no coordinates
          zoom: 13.0,
        ),
        // cameraTargetBounds:
        //     CameraTargetBounds(LatLngBounds.fromList(_coordinates)),
        markers: _markers,
        polylines: Set<Polyline>.of(_polylines.values),
      );
    });
  }
}
