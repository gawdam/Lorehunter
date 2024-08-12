import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/screens/homepage.dart';
import 'package:lorehunter/widgets/tour_complete_itinerary.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class TourComplete extends StatelessWidget {
  final Tour tour;

  const TourComplete({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    ScreenshotController screenshotController = ScreenshotController();

    return Scaffold(
      body: Center(
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          color: const Color.fromARGB(255, 225, 210, 228),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Yaay! You've completed the tour!",
                    style: TextStyle(fontSize: 16),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Here's your tour report",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 10,
              ),
              Stack(
                children: [
                  Screenshot(
                    controller: screenshotController,
                    child: Container(
                      height: screenSize.height * 0.65,
                      width: screenSize.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black, // Set the border color to black
                          width: 2.0, // Set the border width
                        ),
                      ),
                      child: TourCompleteItinerary(
                        tour: tour,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      child: FloatingActionButton(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            side: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        backgroundColor: Color.fromARGB(31, 0, 0, 0),
                        foregroundColor: Color.fromARGB(255, 88, 38, 97),
                        onPressed: () async {
                          print("share");
                          Uint8List? image;
                          await screenshotController
                              .captureFromLongWidget(
                                context: context,
                                pixelRatio: 5,
                                delay: Durations.extralong4,
                                Container(
                                  height: screenSize.height * 0.65,
                                  width: screenSize.width * 0.9,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors
                                          .black, // Set the border color to black
                                      width: 2.0, // Set the border width
                                    ),
                                  ),
                                  child: TourCompleteItinerary(
                                    tour: tour,
                                    staticScreenSize: screenSize,
                                  ),
                                ),
                              )
                              .then((value) => image = value);
                          print(image);
                          if (image != null) {
                            await Share.shareXFiles(
                                [XFile.fromData(image!, mimeType: 'image/png')],
                                text:
                                    "Look at this recent walking tour I went on!");
                          }
                        },
                        child: Icon(Icons.share),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: screenSize.width * 0.8,
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.sizeOf(context).width * 0.05),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (builder) => MyHomePage()));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    side: BorderSide(color: Colors.purple),
                    elevation: 5,
                    backgroundColor: Color.fromARGB(255, 237, 234, 238),
                  ),
                  child: const Text(
                    "Go back to homepage",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
