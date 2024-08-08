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

class TourPanelStateless extends ConsumerWidget {
  TourPanelStateless({super.key});

  final double _panelHeightOpen = 850;
  final double _panelHeightClosed = 215.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tour = ref.watch(tourProvider);
    final placeDetails = tour?.places ?? [];
    final places = List.from(placeDetails.map((e) => e.name));
    final distance = tour?.distance;
    final duration = ((tour?.distance ?? 0) / 1000 / 6 * 60).round();
    bool isTourSaved = false;
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
                      text: tour?.name ?? "<Tour Name>",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                      maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                    )
                        ? Marquee(
                            text: tour?.name ?? "<Tour Name>",
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
                            tour?.name ?? "<Tour Name>",
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
                    "${tour!.updatedPlaces?.length ?? tour!.places.length} places",
                    Icons.account_balance,
                    Colors.blue,
                  ),
                  Button(
                    "Distance covered",
                    "${((distance ?? 0) / 1000).round()} km",
                    Icons.directions_walk,
                    Colors.red,
                  ),
                  Button(
                    "Tour duration",
                    formatTime(duration),
                    Icons.timer_outlined,
                    Colors.green,
                  ),
                  Button(
                    "Best time to visit",
                    tour!.bestExperiencedAt,
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
                  enabled: false,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      if (tour?.routeCoordinates == null) {
                        return PlaceCard(
                          placeDetails: placeDetails[index],
                          icon: "",
                        );
                      }

                      if (tour!.updatedPlaces!.length <= index) {
                        return Container();
                      }
                      if (placeDetails.length >=
                          places.indexOf(tour!.updatedPlaces![index])) {
                        if (tour!.places[index].name !=
                            tour!.updatedPlaces![index]) {
                          return PlaceCard(
                              placeDetails: placeDetails[
                                  places.indexOf(tour!.updatedPlaces![index])],
                              icon: "");
                        }
                      }
                      return PlaceCard(
                        placeDetails: placeDetails[index],
                        icon: "",
                      );
                    },
                    itemCount: placeDetails.length,
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
                            tour: tour!,
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
                    await tour?.toJsonFile();

                    isTourSaved = true;
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
                      isTourSaved
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
      onPanelSlide: (double pos) => {},
    );

    // the fab
  }
}

Widget Button(String labelName, String label, IconData icon, Color color) {
  return Column(
    children: <Widget>[
      Tooltip(
        message: labelName,
        triggerMode: TooltipTriggerMode.tap,
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

String formatTime(int minutes) {
  int roundMinutesToNearestFive(int minutes) {
    return ((minutes / 5).round() * 5).toInt();
  }

  final hours = (minutes / 60).floor();
  final roundedMinutes = roundMinutesToNearestFive(minutes % 60);
  return '${hours}h ${roundedMinutes}m';
}
