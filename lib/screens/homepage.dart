import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lorehunter/interns/find_places_intern.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/providers/location_provider.dart';
import 'package:lorehunter/providers/tour_provider.dart';
import 'package:lorehunter/screens/itinerary.dart';
import 'package:lorehunter/widgets/tour_cards.dart';
import 'package:lorehunter/widgets/location_picker.dart';
import 'package:http/http.dart' as http;

Future<String?> getWikiImageURL(String? wikiURL) async {
  if (wikiURL == null) {
    return null;
  }
  String title = wikiURL.split("/").last;

  final url = Uri.parse(
      "https://en.wikipedia.org/w/api.php?action=query&titles=$title&prop=pageimages&format=json&pithumbsize=500");

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final pages = data['query']['pages'];
      final pageId = pages.keys.first; // Assuming there's only one page

      if (pages[pageId].containsKey('thumbnail')) {
        final thumbnail = pages[pageId]['thumbnail'];

        return thumbnail['source'];
      } else {
        return null;
      }
    } else {
      print('Failed to get response: ${response.statusCode}');
      return null;
    }
  } catch (error) {
    print('Error fetching image: $error');
    return null;
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

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
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  Future<void> getPlaces(String city) async {
    String jsonString = await placesFinder.getPlaces(city);
    tour = getTourFromJson(jsonString, city);
    final List<PlaceDetails> places = [];
    // await tour?.toJsonFile();
    if (tour != null) {
      for (var place in tour!.places) {
        place.imageURL = await getWikiImageURL(place.wikiURL);
        places.add(place);
      }
      tour!.places = places;
    }
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
        backgroundColor: const Color.fromARGB(255, 225, 210, 228),
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            children: [
              !_isGeneratingTour
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.08,
                        ),
                        Container(
                            alignment: Alignment.center,
                            child: Image.asset(
                              "assets/images/lorehunter.png",
                              scale: 3,
                            )),
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.03,
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
                        SizedBox(
                          height: 5,
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
                                        fontSize: 16
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
                    ? Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
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
                        ),
                      )
                    : Center(
                        child: FutureBuilder(
                            future: getToursFromFiles(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                return CircularProgressIndicator();
                              if (snapshot.hasData) {
                                if (snapshot.data != null &&
                                    snapshot.data!.isNotEmpty) {
                                  return Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    height:
                                        MediaQuery.sizeOf(context).height * 0.7,
                                    alignment: Alignment.topCenter,
                                    child: ListView.builder(
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () async {
                                            ref
                                                .read(tourProvider.notifier)
                                                .state = snapshot.data![index];
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ItineraryPage(
                                                          tour: snapshot
                                                              .data![index])),
                                            );
                                          },
                                          child: TourCard(
                                            tour: snapshot.data![index],
                                          ),
                                        );
                                      },
                                      itemCount: snapshot.data!.length,
                                    ),
                                  );
                                } else {
                                  print("no json tours data found.");
                                }
                              }
                              return Center(
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width,
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.7,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Your saved tours will show up here\n\n\nPick a country \nPick a city \nGenerate a walking tour!\n\n",
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
