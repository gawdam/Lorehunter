import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:marquee/marquee.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

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
  String? _imageURL;

  Future<String?> getWikiImageURL(String? wikiURL) async {
    if (wikiURL == null) {
      return null;
    }
    String title = wikiURL.split("/").last;

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
            _imageURL = thumbnail['source'];
          });
          return thumbnail['source'];
        } else {
          print('No image found for $title');
          return null;
        }
      } else {
        print('Failed to get response: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error fetching image: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.black,
      // width: 200, //not working!
      height: 120,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.05,
        // vertical: 2.5,
      ),
      child: Card(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder(
                      future: getWikiImageURL(widget.tour.places.first.wikiURL),
                      builder: (context, snapshot) {
                        return Skeletonizer(
                            enabled: _imageURL == null,
                            child: _imageURL != null
                                ? Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Color.fromARGB(
                                                20, 155, 39, 176)!,
                                            blurRadius: 0)
                                      ],
                                      borderRadius: BorderRadius.circular(
                                          11.0), // Set the desired radius
                                      border: Border.all(
                                        color: Colors.purple[
                                            500]!, // Set the border color
                                        width: 1.0, // Set the border width
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        _imageURL!,
                                        scale: 2,
                                        fit: BoxFit.cover,
                                      ),
                                    ))
                                : Container(
                                    width: 80,
                                    height: 80,
                                  ));
                      }),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 20,
                              width: 160,
                              child: willTextOverflow(
                                      text: widget.tour.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                      maxWidth: 170)
                                  ? Marquee(
                                      text: widget.tour.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                      scrollAxis: Axis.horizontal,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      blankSpace: 20.0,
                                      velocity: 100.0,
                                      pauseAfterRound: Duration(seconds: 1),
                                      startPadding: 10.0,
                                      accelerationDuration:
                                          Duration(seconds: 1),
                                      accelerationCurve: Curves.linear,
                                      decelerationDuration:
                                          Duration(milliseconds: 500),
                                      decelerationCurve: Curves.easeOut,
                                    )
                                  : Text(
                                      widget.tour.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          widget.tour.brief,
                          style: TextStyle(fontSize: 11.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          "${widget.tour.city}",
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
