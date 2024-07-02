import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorehunter/functions/get_place_details.dart';
import 'package:lorehunter/interns/audio_guide_intern.dart';
import 'package:lorehunter/models/place_details.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/providers/place_details_provider.dart';
import 'package:lorehunter/widgets/place_cards.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ItineraryInformationScreen extends ConsumerStatefulWidget {
  ItineraryInformationScreen({required this.tour});

  Tour tour;
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

  @override
  void initState() {
    // TODO: implement initState
    _places = widget.tour.places;
    print("list of places${_places}");
    getPlaceDetails(_places!);
  }

  Future<List<PlaceDetails>> getPlaceDetails(List<String> places) async {
    AudioGuide audioGuide = AudioGuide(theme: "The last of us tv series");
    await audioGuide.initAI();
    List<PlaceDetails> listOfPlaceDetails = [];
    for (String place in places) {
      var response = await audioGuide.gemini(place);
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
    final _placeDetailsProvider = ref.watch(placeDetailsProvider);
    Widget _button(String label, IconData icon, Color color) {
      return Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              icon,
              color: Colors.white,
            ),
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.15),
                blurRadius: 8.0,
              )
            ]),
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
                    child: Text(
                      widget.tour.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
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
                  _button("${widget.tour.places.length} places",
                      Icons.account_balance, Colors.blue),
                  _button("${((widget.tour.distance ?? 0) / 1000).round()} km",
                      Icons.directions_walk, Colors.red),
                  _button("${(duration / 60).round()} hrs",
                      Icons.timer_outlined, Colors.green),
                  _button(widget.tour.time_of_day, Icons.sunny,
                      Colors.yellow[700]!),
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
              _placeDetails.isEmpty
                  ? Container(
                      width: 50, height: 50, child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Container(
                        height: 600,
                        width: 200,
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return PlaceCard(
                              placeDetails: _placeDetails[index],
                              icon: widget.tour.icons[index],
                            );
                          },
                          itemCount: _placeDetails.length,
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
