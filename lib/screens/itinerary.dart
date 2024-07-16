import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorehunter/providers/place_details_provider.dart';
import 'package:lorehunter/widgets/audio_player.dart';
import 'package:lorehunter/widgets/image_carousel.dart';

class Itinerary extends ConsumerStatefulWidget {
  const Itinerary({Key? key}) : super(key: key);

  @override
  ConsumerState<Itinerary> createState() => _ItineraryState();
}

class _ItineraryState extends ConsumerState<Itinerary> {
  @override
  Widget build(BuildContext context) {
    final placeDetails = ref.watch(placeDetailsProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container(
            //   height: MediaQuery.sizeOf(context).height * 0.8,
            //   child: Column(
            //     children: [
            //       for (int i = 0;
            //           i < placeDetails![0]!.audioTourHeaders.length;
            //           i++)
            //         Column(
            //           children: [
            //             Text(
            //               placeDetails[0]!.audioTourHeaders[i],
            //               style: const TextStyle(
            //                   fontSize: 16.0, fontWeight: FontWeight.bold),
            //             ),
            //             const SizedBox(height: 5.0),
            //             Text(
            //               placeDetails[0]!.audioTourDescriptions[i],
            //               style: const TextStyle(fontSize: 14.0),
            //             ),
            //             const SizedBox(height: 10.0),
            //           ],
            //         ),
            //     ],
            //   ),
            // ),
            Container(
              child: AudioPlayer(placeDetails![0]!),
            )
          ],
        ),
      ), // Show loading indicator if placeDetails not yet available
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