import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lorehunter/models/place_details.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class PlaceCard extends StatefulWidget {
  final PlaceDetails placeDetails;
  final String icon;

  const PlaceCard({Key? key, required this.placeDetails, required this.icon})
      : super(key: key);

  @override
  State<PlaceCard> createState() => _TourCardState();
}

class _TourCardState extends State<PlaceCard> {
  bool _isExpanded = false;
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
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      // color: Colors.black,
      width: 200, //not working!
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.05,
        vertical: 5,
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
                  _isExpanded
                      ? Container()
                      : FutureBuilder(
                          future: getWikiImageURL(widget.placeDetails.wikiURL),
                          builder: (context, snapshot) {
                            return Hero(
                              tag: "image-${widget.placeDetails.name}",
                              child: Skeletonizer(
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
                                              width:
                                                  1.0, // Set the border width
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              _imageURL!,
                                              scale: 2,
                                              fit: BoxFit.cover,
                                            ),
                                          ))
                                      : Container(
                                          width: 80,
                                          height: 80,
                                        )),
                            );
                          }),
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
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  widget.placeDetails.name,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                widget.icon,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        _isExpanded
                            ? Container(
                                alignment: Alignment.topLeft,
                                child: Hero(
                                  tag: "image-${widget.placeDetails.name}",
                                  child: Skeletonizer(
                                      enabled: _imageURL == null,
                                      child: _imageURL != null
                                          ? Container(
                                              width: 500,
                                              height: 200,
                                              child: Image.network(
                                                _imageURL!,
                                                scale: 2,
                                                fit: BoxFit.fitWidth,
                                              ))
                                          : Container(
                                              width: 100,
                                              height: 100,
                                            )),
                                ),
                              )
                            : Text(
                                widget.placeDetails.brief,
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
                          "${widget.placeDetails.tourDuration} mins",
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.grey,
                        ),
                        onPressed: () =>
                            setState(() => _isExpanded = !_isExpanded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _isExpanded ? null : 0.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Text(
                    widget.placeDetails.detailedAudioTour,
                    style: TextStyle(fontSize: 11.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
