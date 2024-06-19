import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaceImage {
  final List<String> places;
  late String apiKey; // Assuming you have an API key stored

  PlaceImage({required this.places});

  Future<List<String>> getImages() async {
    final imageUrls = <String>[];
    for (final place in places) {
      // 1. Find Place ID (Text Search)
      final placeId = await _findPlaceId(place);
      if (placeId == null) {
        continue; // Skip if Place ID not found
      }

      // 2. Get Photo Reference (Place Details)
      final photoReference = await _getPhotoReference(placeId);
      if (photoReference == null) {
        continue; // Skip if photo reference not found
      }

      // 3. Get Photo URL (Place Photo)
      final imageUrl = await _getPhotoUrl(photoReference);
      if (imageUrl != null) {
        imageUrls.add(imageUrl);
      }
    }
    return imageUrls;
  }

  Future<String?> _findPlaceId(String placeName) async {
    await dotenv.load(fileName: ".env");
    apiKey = dotenv.env['maps_api_key']!;
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$placeName&key=$apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      if (results.isNotEmpty) {
        return results[0]['place_id'] as String;
      }
    }
    return null;
  }

  Future<String?> _getPhotoReference(String placeId) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final photos = data['result']['photos'] as List;
      if (photos.isNotEmpty) {
        return photos[0]['photo_reference'] as String;
      }
    }
    return null;
  }

  Future<String?> _getPhotoUrl(String photoReference) async {
    final maxWidth = 400; // Adjust as needed
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photoreference=$photoReference&key=$apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // This retrieves the image data, you might need to handle it based on your usage
      return url.toString(); // Or handle the image response based on your needs
    }
    return null;
  }
}
