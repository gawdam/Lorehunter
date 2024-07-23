import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:lorehunter/interns/find_places_intern.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/providers/location_provider.dart';
import 'package:lorehunter/functions/geocoding.dart';
import 'package:lorehunter/providers/tour_provider.dart';
import 'package:lorehunter/screens/itinerary.dart';
import 'package:lorehunter/widgets/routes.dart';
import 'package:lorehunter/widgets/tour_cards.dart';
import 'package:lorehunter/widgets/tour_panel_slide_up.dart';
import 'package:lorehunter/widgets/location_picker.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  String chatHistory = "";
  String apiKey = '';
  late GenerativeModel model;
  Tour? tour;
  bool _isGeneratingTour = false;

  PlacesFinder placesFinder = PlacesFinder();

  String? cityValue = "";
  String? countryValue = "";

  @override
  void initState() {
    super.initState();
    placesFinder.initAI();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  Future<void> getPlaces(String city) async {
    String jsonString = await placesFinder.askGemini(city);
    tour = getTourFromJson(jsonString, city);
    await tour?.toJsonFile(city);
    ref.read(tourProvider.notifier).state = tour;
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => ItineraryPage(tour: tour!),
        ));
  }

  @override
  Widget build(BuildContext context) {
    cityValue = ref.watch(selectedCityProvider);
    countryValue = ref.watch(selectedCountryProvider);
    tour = ref.watch(tourProvider);

    return ProviderScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            children: [
              !_isGeneratingTour
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.045,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.05,
                            ),
                            LocationPicker(),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02,
                            ),
                          ],
                        ),
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.85,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateColor.resolveWith(
                                          (states) => Colors.purple[100]!),
                                  elevation: MaterialStateProperty.resolveWith(
                                      (states) => 10),
                                  shadowColor: MaterialStateColor.resolveWith(
                                      (states) =>
                                          Color.fromARGB(20, 155, 39, 176)!),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    side: BorderSide(
                                        color: Colors.purple[500]!, width: 1),
                                  ))),
                              onPressed: () async {
                                setState(() {
                                  _isGeneratingTour = true;
                                });
                                await getPlaces("$cityValue, $countryValue");
                                setState(() {
                                  _isGeneratingTour = false;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Generate walking tour",
                                    style: TextStyle(
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        fontSize: 14
                                        // fontFamily: "Open Sans",
                                        ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Image.asset(
                                    'assets/images/gemini.png',
                                    width: 25,
                                  ),
                                ],
                              )),
                        ),
                      ],
                    )
                  : Container(),
              // SizedBox(
              //   height: 30,
              // ),
              Center(
                child: _isGeneratingTour
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/fastWalkman.gif',
                            scale: 4,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Generating tour...",
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          )
                        ],
                      )
                    : FutureBuilder(
                        future: getToursFromFiles(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data != null &&
                                snapshot.data!.isNotEmpty) {
                              return Container(
                                width: MediaQuery.sizeOf(context).width,
                                height: MediaQuery.sizeOf(context).height * 0.8,
                                alignment: Alignment.topCenter,
                                child: ListView.builder(
                                  itemBuilder: (context, index) {
                                    return TourCard(
                                        tour: snapshot.data![index]);
                                  },
                                  itemCount: snapshot.data!.length,
                                ),
                              );
                            } else {
                              print("no json tours data found.");
                            }
                          }
                          return Text(
                            "Pick a country \nPick a city \nGenerate a walking tour!",
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          );
                        }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
