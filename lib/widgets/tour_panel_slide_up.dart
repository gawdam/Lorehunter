import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lorehunter/interns/audio_guide_intern.dart';
import 'package:lorehunter/models/place_details.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/providers/location_provider.dart';
import 'package:lorehunter/providers/place_details_provider.dart';
import 'package:lorehunter/providers/tour_provider.dart';
import 'package:lorehunter/screens/audio_tour.dart';
import 'package:lorehunter/screens/itinerary.dart';
import 'package:lorehunter/widgets/place_cards.dart';
import 'package:marquee/marquee.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class TourPanelSlideUp extends ConsumerStatefulWidget {
  TourPanelSlideUp({required this.tour, required this.city});

  Tour tour;
  String city;
  @override
  ConsumerState<TourPanelSlideUp> createState() => _TourPanelSlideUpState();
}

class _TourPanelSlideUpState extends ConsumerState<TourPanelSlideUp> {
  final double _initFabHeight = 200.0;
  List<String> _places = [];
  List<PlaceDetails> _placeDetails = [];
  int _timeSpentAtPlaces = 0;
  Tour? _previousTour; // Store the previous tour

  @override
  void initState() {
    // TODO: implement initState
    _placeDetails = widget.tour.places;
    for (var place in _placeDetails) {
      _places.add(place.name);
    }
    // getPlaceDetails(_places, widget.city);
    // _city = ref.watch(selectedCityProvider);
  }

  @override
  void didUpdateWidget(covariant TourPanelSlideUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if tour has changed
    if (widget.tour != _previousTour) {
      _previousTour = widget.tour; // Update previous tour
      _updatePlacesAndDetails(widget.tour); // Update places and details
    }
  }

  void _updatePlacesAndDetails(Tour tour) {
    setState(() {
      _placeDetails = tour.places;
      _places = [];
      for (var place in _placeDetails) {
        _places.add(place.name);
      }
      _timeSpentAtPlaces = _placeDetails.fold(
          0, (sum, placeDetails) => sum + placeDetails.tourDuration);
    });
  }

  double _fabHeight = 0;

  final double _panelHeightOpen = 850;

  final double _panelHeightClosed = 200.0;

  @override
  Widget build(BuildContext context) {
    int duration = ((widget.tour.distance ?? 0) / 1000 / 6 * 60).round() +
        _timeSpentAtPlaces;

    Widget _button(String labelName, String label, IconData icon, Color color) {
      return Column(
        children: <Widget>[
          Tooltip(
            message: labelName,
            child: Container(
              padding: const EdgeInsets.all(14.0),
              child: Icon(
                icon,
                color: Colors.white,
              ),
              decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.15),
                      blurRadius: 8.0,
                    )
                  ]),
            ),
          ),
          SizedBox(
            height: 12.0,
          ),
          Text(label),
        ],
      );
    }

    Widget _panel(ScrollController sc) {
      return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView(
            controller: sc,
            children: <Widget>[
              SizedBox(
                height: 12.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AnimatedContainer(
                      duration: Duration(seconds: 1),
                      child: Container(
                        width: 30,
                        height: 5,
                        // padding: EdgeInsets.all(18),
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0))),
                      )),
                ],
              ),
              SizedBox(
                height: 25.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.8,
                    alignment: Alignment.center,
                    height: 35,
                    child: willTextOverflow(
                      text: widget.tour.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                      maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                    )
                        ? Marquee(
                            text: widget.tour.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                            ),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            blankSpace: 50.0,
                            velocity: 100.0,
                            pauseAfterRound: Duration(seconds: 1),
                            startPadding: 10.0,
                            accelerationDuration: Duration(seconds: 1),
                            accelerationCurve: Curves.easeIn,
                            decelerationDuration: Duration(milliseconds: 500),
                            decelerationCurve: Curves.easeOut,
                          )
                        : Text(
                            widget.tour.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                            ),
                          ),
                  ),
                ],
              ),
              SizedBox(
                height: 25.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _button(
                    "# Places",
                    "${widget.tour.updatedPlaces?.length ?? widget.tour.places.length} places",
                    Icons.account_balance,
                    Colors.blue,
                  ),
                  _button(
                    "Distance covered",
                    "${((widget.tour.distance ?? 0) / 1000).round()} km",
                    Icons.directions_walk,
                    Colors.red,
                  ),
                  _button(
                    "Tour duration",
                    "${(duration / 60).round()} hrs",
                    Icons.timer_outlined,
                    Colors.green,
                  ),
                  _button(
                    "Best time to visit",
                    widget.tour.bestExperiencedAt,
                    Icons.sunny,
                    Colors.yellow[700]!,
                  ),
                ],
              ),
              SizedBox(
                height: 25.0,
              ),
//               ListView.builder(
//   // Let the ListView know how many items it needs to build.
//   itemCount: _placeDetails.length,
//   // Provide a builder function. This is where the magic happens.
//   // Convert each item into a widget based on the type of item it is.
//   itemBuilder: (context, index) {
//     final item = _placeDetails[index];

//     return PlaceCard(placeDetails: item);
//   },
// ),
              Container(
                height: MediaQuery.sizeOf(context).height * 0.6,
                width: MediaQuery.sizeOf(context).width * 0.9,
                child: Skeletonizer(
                  enabled: _placeDetails.length != widget.tour.places.length,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      if (widget.tour.updatedPlaces!.length <= index) {
                        return Container();
                      }
                      if (_placeDetails.length >=
                          _places.indexOf(widget.tour.updatedPlaces![index])) {
                        if (widget.tour.places[index].name !=
                            widget.tour.updatedPlaces![index]) {
                          return PlaceCard(
                              placeDetails: _placeDetails[_places
                                  .indexOf(widget.tour.updatedPlaces![index])],
                              icon: "");
                        }
                      }
                      return PlaceCard(
                        placeDetails: _placeDetails[index],
                        icon: "",
                      );
                    },
                    itemCount: _placeDetails.length,
                  ),
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Container(
                width: 200,
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.sizeOf(context).width * 0.05),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => AudioTour(
                              places: widget.tour.updatedPlaces!,
                              city: widget.city),
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    side: BorderSide(color: Colors.purple),
                    elevation: 5,
                    backgroundColor: Colors.purple[100],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Generate audio tour",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.headphones,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ));
    }

    return SlidingUpPanel(
      maxHeight: _panelHeightOpen,
      minHeight: _panelHeightClosed,
      isDraggable: true,
      parallaxEnabled: true,
      parallaxOffset: .5,
      panelBuilder: (sc) => _panel(sc),
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
      onPanelSlide: (double pos) => setState(() {
        _fabHeight =
            pos * (_panelHeightOpen - _panelHeightClosed) + _initFabHeight;
      }),
    );

    // the fab
  }
}
