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
import 'package:lorehunter/widgets/itinerary_information.dart';
import 'package:lorehunter/widgets/itinerary.dart';
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                  ? Container()
                  : Container(
                      width: MediaQuery.sizeOf(context).width * 1,
                      height: MediaQuery.sizeOf(context).height * 1 - 190,
                      child: Routes(places: tour!.places)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.035,
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
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.15,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[100]),
                            onPressed: placesFinder.initialized
                                ? () {
                                    getPlaces("$cityValue, $countryValue");
                                  }
                                : null,
                            child: Icon(Icons.star)),
                      ),
                    ],
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
                      child: ItineraryInformationScreen(tour: tour!)),
            ],
          ),
        ),
      ),
    );
  }
}
