import 'dart:ffi';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:lorehunter/providers/location_provider.dart';

// Assuming you have a function to get the user-entered place name

Future<Map<String, dynamic>> getCoordinates(String placeName) async {
  await dotenv.load(fileName: ".env");

  final apiKey =
      dotenv.env['maps_api_key']!; // Replace with your actual API key
  final baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json?';
  final address = Uri.encodeQueryComponent(placeName);
  final url = '$baseUrl&address=$address&key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = convert.jsonDecode(response.body) as Map<String, dynamic>;
    final status = data['status'];
    if (status == 'OK') {
      final results = data['results'] as List;
      final geometry = results[0]['geometry'] as Map<String, dynamic>;
      final location = geometry['location'] as Map<String, dynamic>;
      return location;
    } else {
      // Handle errors based on status code (e.g., INVALID_REQUEST)
      throw Exception('Geocoding API error: $status');
    }
  } else {
    // Handle other HTTP errors
    throw Exception('Failed to get coordinates: ${response.statusCode}');
  }
}

Future<Map<String, dynamic>?> getCoordinatesForFree(String placeName) async {
  print(placeName);
  var coords = null;
  try {
    coords = locationFromAddress(placeName).then((locations) {
      if (locations.isNotEmpty) {
        return {'lat': locations[0].latitude, 'lng': locations[0].longitude};
      }
      return null;
    });
  } on Exception catch (e) {
    print(e);
  }
  return coords;
}
