import 'package:flutter/material.dart';
import 'package:lorehunter/models/place_details.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceCard extends StatefulWidget {
  final PlaceDetails placeDetails;

  const PlaceCard({Key? key, required this.placeDetails}) : super(key: key);

  @override
  State<PlaceCard> createState() => _TourCardState();
}

class _TourCardState extends State<PlaceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => launch(widget.placeDetails.wikiURL!),
                        child: Text(
                          widget.placeDetails.name,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
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
                        widget.placeDetails.tourDuration,
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
            height: _isExpanded ? 350.0 : 0.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.placeDetails.detailedAudioTour,
                style: TextStyle(fontSize: 14.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
