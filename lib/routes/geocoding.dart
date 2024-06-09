import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

// Assuming you have a function to get the user-entered place name

Future<Map<String, double>> getCoordinates(String placeName) async {
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
      final location = geometry['location'] as Map<String, double>;
      print(location['lat']);
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
