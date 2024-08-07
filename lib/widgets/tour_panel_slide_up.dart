import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/providers/tour_provider.dart';
import 'package:lorehunter/screens/audio_tour.dart';
import 'package:lorehunter/screens/loading_screen.dart';
import 'package:lorehunter/widgets/place_cards.dart';
import 'package:marquee/marquee.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class TourPanelSlideUp extends ConsumerStatefulWidget {
  TourPanelSlideUp({super.key});

  @override
  ConsumerState<TourPanelSlideUp> createState() => _TourPanelSlideUpState();
}

class _TourPanelSlideUpState extends ConsumerState<TourPanelSlideUp> {
  Tour? _tour;
  List<PlaceDetails> _placeDetails = [];
  List<String> _places = [];

  int _timeSpentAtPlaces = 0;
  Tour? _previousTour; // Store the previous tour
  bool _isTourSaved = false;

  double? distance;
  int? duration;

  final double _panelHeightOpen = 850;
  final double _panelHeightClosed = 215.0;

  @override
  void didUpdateWidget(covariant TourPanelSlideUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
    // Check if tour has changed
    if (_tour != _previousTour) {
      _previousTour = _tour; // Update previous tour
      _updatePlacesAndDetails(_tour!); // Update places and details
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

  @override
  Widget build(BuildContext context) {
    _tour = ref.read(tourProvider);
    _placeDetails = _tour!.places;
    _places = List.from(_placeDetails.map((e) => e.name));
    distance = _tour?.distance;
    duration = ((_tour?.distance ?? 0) / 1000 / 6 * 60).round();
    Widget _panel(ScrollController sc) {
      return Consumer(
        builder: (context, ref, child) {
          _tour = ref.watch(tourProvider);
          _placeDetails = _tour!.places;
          _places = List.from(_placeDetails.map((e) => e.name));
          distance = _tour?.distance;
          duration = ((_tour?.distance ?? 0) / 1000 / 6 * 60).round();
          return child!;
        },
        child: MediaQuery.removePadding(
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
                        text: _tour?.name ?? "<Tour Name>",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                        maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                      )
                          ? Marquee(
                              text: _tour?.name ?? "<Tour Name>",
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
                              _tour?.name ?? "<Tour Name>",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                              ),
                            ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 25.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Button(
                      "# Places",
                      "${_tour!.updatedPlaces?.length ?? _tour!.places.length} places",
                      Icons.account_balance,
                      Colors.blue,
                    ),
                    Button(
                      "Distance covered",
                      "${((_tour!.distance ?? 0) / 1000).round()} km",
                      Icons.directions_walk,
                      Colors.red,
                    ),
                    Button(
                      "Tour duration",
                      "${(duration ?? 0 / 60).round()} hrs",
                      Icons.timer_outlined,
                      Colors.green,
                    ),
                    Button(
                      "Best time to visit",
                      _tour!.bestExperiencedAt,
                      Icons.watch_outlined,
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
                  height: MediaQuery.sizeOf(context).height * 0.55,
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  child: Skeletonizer(
                    enabled: _tour?.routeCoordinates == null,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        if (_tour?.routeCoordinates == null) {
                          return PlaceCard(
                            placeDetails: _placeDetails[index],
                            icon: "",
                          );
                        }

                        if (_tour!.updatedPlaces!.length <= index) {
                          return Container();
                        }
                        if (_placeDetails.length >=
                            _places.indexOf(_tour!.updatedPlaces![index])) {
                          if (_tour!.places[index].name !=
                              _tour!.updatedPlaces![index]) {
                            return PlaceCard(
                                placeDetails: _placeDetails[_places
                                    .indexOf(_tour!.updatedPlaces![index])],
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
                            builder: (BuildContext context) =>
                                TourAudioLoadingScreen(
                              tour: _tour!,
                              settings: {
                                "theme": "none",
                                "duration": "5",
                                "voice": "male"
                              },
                            ),
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
                Container(
                  width: 200,
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width * 0.05),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      await _tour?.toJsonFile();
                      setState(() {
                        _isTourSaved = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      side: BorderSide(color: Colors.purple),
                      elevation: 5,
                      backgroundColor: Color.fromARGB(255, 237, 234, 238),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Save tour",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        _isTourSaved
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.download,
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
            )),
      );
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
      onPanelSlide: (double pos) => setState(() {}),
    );

    // the fab
  }
}

Widget Button(String labelName, String label, IconData icon, Color color) {
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
