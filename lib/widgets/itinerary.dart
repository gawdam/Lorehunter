import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lorehunter/functions/places_image.dart';
import 'package:lorehunter/widgets/image_carousel.dart';

class Itinerary extends StatefulWidget {
  final List<String> places;

  const Itinerary({Key? key, required this.places}) : super(key: key);

  @override
  State<Itinerary> createState() => _ItineraryState();
}

class _ItineraryState extends State<Itinerary> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ImageCarousel(
          imageUrlsFuture: _getImageUrls(widget.places),
          places: widget.places,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                widget.places.map((place) => _buildPlaceItem(place)).toList(),
          ),
        ),
      ],
    );
  }

  Future<List<String>> _getImageUrls(List<String> places) async {
    // Assuming you have implemented the PlaceImage class and getImages function
    final imageUrls = await PlaceImage(places: places).getImages();

    return imageUrls;
  }

  Widget _buildPlaceItem(String place) {
    return Text(
      place,
      style: TextStyle(fontSize: 16.0),
    );
  }
}

// Extension method to handle null safety for first element
extension FirstOrNull on List<String> {
  String? get firstOrNull => isEmpty ? null : first;
}
