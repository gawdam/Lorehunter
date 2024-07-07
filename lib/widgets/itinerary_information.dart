import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorehunter/interns/audio_guide_intern.dart';
import 'package:lorehunter/models/place_details.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/providers/location_provider.dart';
import 'package:lorehunter/providers/place_details_provider.dart';
import 'package:lorehunter/providers/tour_provider.dart';
import 'package:lorehunter/widgets/place_cards.dart';
import 'package:marquee/marquee.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ItineraryInformationScreen extends ConsumerStatefulWidget {
  ItineraryInformationScreen({required this.tour, required this.city});

  Tour tour;
  String city;
  @override
  ConsumerState<ItineraryInformationScreen> createState() =>
      _ItineraryInformationScreenState();
}

class _ItineraryInformationScreenState
    extends ConsumerState<ItineraryInformationScreen> {
  final double _initFabHeight = 120.0;
  List<String> _places = [];
  List<PlaceDetails> _placeDetails = [];
  int _timeSpentAtPlaces = 0;
  Tour? _previousTour; // Store the previous tour

  @override
  void initState() {
    // TODO: implement initState
    _places = widget.tour.places;
    print("list of places${_places}");
    getPlaceDetails(_places, widget.city);
    // _city = ref.watch(selectedCityProvider);
  }

  @override
  void didUpdateWidget(covariant ItineraryInformationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if tour has changed
    if (widget.tour != _previousTour) {
      _previousTour = widget.tour; // Update previous tour
      _updatePlacesAndDetails(widget.tour); // Update places and details
    }
  }

  void _updatePlacesAndDetails(Tour tour) {
    _places = tour.places;
    getPlaceDetails(_places, widget.city).then((listOfPlaceDetails) {
      setState(() {
        _placeDetails = listOfPlaceDetails;
        _timeSpentAtPlaces = _placeDetails.fold(
            0, (sum, placeDetails) => sum + placeDetails.tourDuration);
      });
    });
  }

  Future<List<PlaceDetails>> getPlaceDetails(
      List<String> places, String city) async {
    AudioGuide audioGuide = AudioGuide(theme: "The last of us tv series");
    await audioGuide.initAI();
    List<PlaceDetails> listOfPlaceDetails = [];
    for (String place in places) {
      var response = await audioGuide.gemini("$place, $city");
      PlaceDetails placeDetails = await getPlaceDetailsFromJson(response);
      listOfPlaceDetails.add(placeDetails);
      ref.read(placeDetailsProvider.notifier).state = listOfPlaceDetails;
      setState(() {
        _placeDetails = listOfPlaceDetails;
        _timeSpentAtPlaces += placeDetails.tourDuration;
      });
    }

    return listOfPlaceDetails;
  }

  double _fabHeight = 0;

  final double _panelHeightOpen = 800;

  final double _panelHeightClosed = 200.0;

  @override
  Widget build(BuildContext context) {
    int duration = ((widget.tour.distance ?? 0) / 1000 / 6 * 60).round() +
        _timeSpentAtPlaces;
    final _tour = ref.watch(tourProvider);

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
                  Container(
                    width: 30,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  ),
                ],
              ),
              SizedBox(
                height: 18.0,
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
                    "${widget.tour.places.length} places",
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
                    widget.tour.time_of_day,
                    Icons.sunny,
                    Colors.yellow[700]!,
                  ),
                ],
              ),
              SizedBox(
                height: 36.0,
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
              SingleChildScrollView(
                child: Container(
                  height: 600,
                  width: 200,
                  child: Skeletonizer(
                    enabled: _placeDetails.length != _tour!.places.length,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        if (_tour!.updatedPlaces!.length <= index) {
                          return Container();
                        }
                        if (_placeDetails.length >=
                            _tour!.places
                                .indexOf(_tour.updatedPlaces![index])) {
                          if (_tour.places[index] !=
                              _tour.updatedPlaces![index]) {
                            return PlaceCard(
                                placeDetails: _placeDetails[_tour.places
                                    .indexOf(_tour.updatedPlaces![index])],
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
              ),
              SizedBox(
                height: 24,
              ),
              Divider(),
              SizedBox(
                height: 24,
              ),
            ],
          ));
    }

    return SlidingUpPanel(
      maxHeight: _panelHeightOpen,
      minHeight: _panelHeightClosed,
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
