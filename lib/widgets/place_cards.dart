import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class PlaceCard extends ConsumerStatefulWidget {
  final PlaceDetails placeDetails;

  const PlaceCard({Key? key, required this.placeDetails, required String icon})
      : super(key: key);

  @override
  ConsumerState<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends ConsumerState<PlaceCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.black,
      width: 200, //not working!
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
                  widget.placeDetails.imageURL != null
                      ? Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromARGB(20, 155, 39, 176)!,
                                  blurRadius: 0)
                            ],
                            borderRadius: BorderRadius.circular(
                                11.0), // Set the desired radius
                            border: Border.all(
                              color:
                                  Colors.purple[500]!, // Set the border color
                              width: 1.0, // Set the border width
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.placeDetails.imageURL!,
                              scale: 2,
                              fit: BoxFit.cover,
                            ),
                          ))
                      : Container(
                          width: 80,
                          height: 80,
                          child: Icon(
                            Icons.account_balance,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => launchUrl(Uri.parse(widget
                                  .placeDetails.wikiURL ??
                              "https://www.google.com/search?q=${widget.placeDetails.name}")),
                          child: Row(
                            children: [
                              Container(
                                height: 20,
                                width: 170,
                                child: willTextOverflow(
                                        text: widget.placeDetails.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                        maxWidth: 170)
                                    ? Marquee(
                                        text: widget.placeDetails.name,
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
                                        widget.placeDetails.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                // color: Colors.grey,
                                alignment: Alignment.topRight,
                                height: 30,
                                child: IconButton(
                                    onPressed: () {
                                      launchUrl(Uri.parse(widget
                                              .placeDetails.wikiURL ??
                                          "https://www.google.com/search?q=${widget.placeDetails.name}"));
                                    },
                                    icon: Icon(
                                      Icons.link,
                                      size: 20,
                                    )),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          widget.placeDetails.brief,
                          style: TextStyle(fontSize: 11.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
