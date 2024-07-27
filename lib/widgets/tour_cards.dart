import 'dart:convert';
import 'package:lorehunter/widgets/tour_panel_slide_up.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:marquee/marquee.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

Widget buildCarouselItem(String imageUrl, String placeName) {
  return Stack(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
      // ClipRRect(
      //   borderRadius: BorderRadius.only(
      //       topLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
      //   child: Positioned(
      //     // top: 30.0, // Adjust position as needed
      //     // left: 30.0, // Adjust position as needed
      //     child: Container(
      //       padding: EdgeInsets.all(8.0),
      //       color: Colors.black54
      //           .withOpacity(0.5), // Semi-transparent black background

      //       child: Text(
      //         placeName,
      //         style: TextStyle(color: Colors.white, fontSize: 16.0),
      //       ),
      //     ),
      //   ),
      // ),
    ],
  );
}

bool willTextOverflow({
  required String text,
  required TextStyle style,
  required double maxWidth,
}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: maxWidth);

  return textPainter.didExceedMaxLines;
}

class TourCard extends StatefulWidget {
  final Tour tour;

  const TourCard({Key? key, required this.tour}) : super(key: key);

  @override
  State<TourCard> createState() => _TourCardState();
}

class _TourCardState extends State<TourCard> {
  List<String> _imageURLs = [];

  Future<void> getWikiImageURLs(List<PlaceDetails> placeDetails) async {
    for (var placeDetail in placeDetails) {
      if (placeDetail.wikiURL == null) {
        return null;
      }
      String title = placeDetail.wikiURL!.split("/").last;

      final url = Uri.parse(
          "https://en.wikipedia.org/w/api.php?action=query&titles=$title&prop=pageimages&format=json&pithumbsize=500");

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final pages = data['query']['pages'];
          final pageId = pages.keys.first; // Assuming there's only one page

          if (pages[pageId].containsKey('thumbnail')) {
            final thumbnail = pages[pageId]['thumbnail'];
            setState(() {
              _imageURLs.add(thumbnail['source']);
            });
          } else {}
        } else {}
      } catch (error) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getWikiImageURLs(widget.tour.places),
        builder: (context, snapshot) {
          return Container(
              // color: Colors.black,
              // width: 200, //not working!
              height: 420,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * 0.05,
                // vertical: 2.5,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.tour.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),

                      // Carousel of images
                      CarouselSlider(
                        items: _imageURLs
                            .map((_imageURL) =>
                                buildCarouselItem(_imageURL, "London bridge"))
                            .toList(),
                        options: CarouselOptions(
                          height: 200.0,
                          enlargeCenterPage: true,
                          autoPlay: true,
                          autoPlayInterval: const Duration(milliseconds: 1600),
                          viewportFraction: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // Tour brief description
                      Text(
                        widget.tour.brief,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),

                      // Placeholder for button row (replace with your implementation)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Button(
                            "# Places",
                            "${widget.tour.updatedPlaces?.length ?? widget.tour.places.length} places",
                            Icons.account_balance,
                            Colors.blue,
                          ),
                          Button(
                            "Distance covered",
                            "${((widget.tour.distance ?? 0) / 1000).round()} km",
                            Icons.directions_walk,
                            Colors.red,
                          ),
                          Button(
                            "Tour duration",
                            "${(5).round()} hrs",
                            Icons.timer_outlined,
                            Colors.green,
                          ),
                          Button(
                            "Best time to visit",
                            widget.tour.bestExperiencedAt,
                            Icons.watch_outlined,
                            Colors.yellow[700]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        });
  }
}
