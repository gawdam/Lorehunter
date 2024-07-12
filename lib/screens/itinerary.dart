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
      children: [Text("Hello!")],
    );
  }
}

// AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               height: _isExpanded ? null : 0.0,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start, // Left-align content
//                     children: [
//                       // Loop through elements in pairs
//                       for (int i = 0;
//                           i < widget.placeDetails.audioTourHeaders.length;
//                           i++)
//                         if (i <
//                             widget.placeDetails.audioTourDescriptions.length)
//                           Row(
//                             // Wrap header and description in a Row
//                             children: [
//                               // Display header
//                               Text(
//                                 widget.placeDetails.audioTourHeaders[i],
//                                 style: const TextStyle(
//                                   fontSize: 13.0,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(
//                                   width:
//                                       8.0), // Spacing between header and description
//                               // Display description (if description list is long enough)
//                               if (i <
//                                   widget.placeDetails.audioTourDescriptions
//                                       .length)
//                                 Expanded(
//                                   child: Text(
//                                     widget
//                                         .placeDetails.audioTourDescriptions[i],
//                                     style: const TextStyle(fontSize: 11.0),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                       const SizedBox(
//                           height:
//                               8.0), // Spacing between header-description pairs
//                     ],
//                   ),
//                 ),
//               ),
//             ),