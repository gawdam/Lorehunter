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
import 'package:lorehunter/widgets/routes.dart';
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
    String jsonString = await placesFinder.gemini(city);
    tour = getTourFromJson(jsonString);
    ref.read(tourProvider.notifier).state = tour;
  }

  @override
  Widget build(BuildContext context) {
    cityValue = ref.watch(selectedCityProvider);
    countryValue = ref.watch(selectedCountryProvider);
    tour = ref.watch(tourProvider);

    return ProviderScope(
      child: Scaffold(
        // backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        resizeToAvoidBottomInset: false,
        // appBar: AppBar(
        //   title: Text(
        //     "Lore Hunter",
        //     style: TextStyle(fontSize: 26),
        //     textAlign: TextAlign.center,
        //   ),
        //   centerTitle: true,
        //   backgroundColor: Colors.purple[200],
        // ),
        body: Center(
          child: Stack(
            children: [
              tour == null
                  ? Center(
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
                          : Text(
                              "Pick a country \nPick a city \nGenerate a walking tour!",
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                    )
                  : Container(
                      width: MediaQuery.sizeOf(context).width * 1,
                      height: MediaQuery.sizeOf(context).height * 1 - 190,
                      child: Routes(
                        places: [for (var place in tour!.places) place.name],
                        city: cityValue!,
                      )),
              Column(
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
                            backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.purple[100]!),
                            elevation: MaterialStateProperty.resolveWith(
                                (states) => 10),
                            shadowColor: MaterialStateColor.resolveWith(
                                (states) => Color.fromARGB(20, 155, 39, 176)!),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              side: BorderSide(
                                  color: Colors.purple[500]!, width: 1),
                            ))),
                        onPressed: _isGeneratingTour
                            ? null
                            : () async {
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
                                  color: const Color.fromARGB(255, 0, 0, 0),
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
                              // height: 50,
                            ),
                          ],
                        )),
                  ),
                  const SizedBox(
                      // height: MediaQuery.sizeOf(context).height * 0.03,
                      ),

                  // Expanded(
                  //   child: Container(
                  //     padding: EdgeInsets.all(16),
                  //     // child: SelectableText(
                  //     //   chatHistory,
                  //     //   style: TextStyle(fontSize: 16),
                  //     // ),
                  //   ),
                  // ),
                  // Builder(
                  //   builder: (context) {
                  //     if (places != null) {
                  //       return Itinerary(places: places!);
                  //     }
                  //     return Container();
                  //   },
                  // ),
                ],
              ),
              tour == null
                  ? Container()
                  : Positioned(
                      bottom: 0,
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height,
                      child: TourPanelSlideUp(
                        tour: tour!,
                        city: cityValue!,
                      )),
            ],
          ),
        ),
      ),
    );
  }
}
