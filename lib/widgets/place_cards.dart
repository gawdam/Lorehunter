import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lorehunter/models/place_details.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    print(widget.icon);
    return Container(
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
              padding: EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                              Text(
                                widget.placeDetails.name,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
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
                            ? Container()
                            : Text(
                                widget.placeDetails.brief,
                                style: TextStyle(fontSize: 14.0),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          "${widget.placeDetails.tourDuration} mins",
                          style: TextStyle(fontSize: 14.0),
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
                    style: TextStyle(fontSize: 14.0),
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
