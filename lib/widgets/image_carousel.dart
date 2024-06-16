import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  final Future<List<String>> imageUrlsFuture;
  final List<String> places;

  const ImageCarousel(
      {Key? key, required this.imageUrlsFuture, required this.places})
      : super(key: key);

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: widget.imageUrlsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final imageUrls = snapshot.data!;
          final placeNames =
              widget.places; // Assuming widget.places contains place names

          // Ensure imageUrls and placeNames have the same length
          if (imageUrls.length != placeNames.length) {
            print('Error: Image URL count and place name count do not match.');
            return Text('Error: Data mismatch');
          }

          return CarouselSlider(
            items: imageUrls.asMap().entries.map((entry) {
              int index = entry.key;
              String imageUrl = entry.value;
              String placeName = placeNames[index];
              return _buildCarouselItem(imageUrl, placeName);
            }).toList(),
            options: CarouselOptions(
              aspectRatio: 16 / 9, // Adjust aspect ratio as needed
              viewportFraction: 0.8, // Adjust visible portion of each slide
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval:
                  Duration(seconds: 3), // Adjust autoplay interval
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return CircularProgressIndicator(); // Display loading indicator
      },
    );
  }

  Widget _buildCarouselItem(String imageUrl, String placeName) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
        Positioned(
          bottom: 16.0, // Adjust position as needed
          left: 16.0, // Adjust position as needed
          child: Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.black54
                .withOpacity(0.7), // Semi-transparent black background
            child: Text(
              placeName,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          ),
        ),
      ],
    );
  }
}
