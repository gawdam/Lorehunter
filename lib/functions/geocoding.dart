import 'dart:ffi';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:lorehunter/providers/location_provider.dart';

Future<Map<String, dynamic>?> getCoordinatesForFree(
    String placeName, String city) async {
  var coords = null;
  try {
    coords = locationFromAddress("$placeName, $city").then((locations) {
      if (locations.isNotEmpty) {
        print("locations empty");
        return {'lat': locations[0].latitude, 'lng': locations[0].longitude};
      }
      return null;
    }).catchError((error, stackTrace) => null);
  } on Exception catch (e) {
    print("EXCEPTION: $e");
  }
  return coords;
}
