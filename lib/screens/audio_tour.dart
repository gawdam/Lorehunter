import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorehunter/models/audio_tour_transcript.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/widgets/audio_player.dart';
import 'package:lorehunter/widgets/audio_tour_subtitles.dart';
import 'package:lorehunter/widgets/quiz.dart';
import 'package:lorehunter/widgets/routes.dart';
import 'package:lorehunter/widgets/tour_progress.dart';

class AudioTour extends ConsumerStatefulWidget {
  TourAudioTranscript tourAudioTranscript;
  Tour tour;

  AudioTour({required this.tourAudioTranscript, required this.tour});
  @override
  ConsumerState<AudioTour> createState() {
    return _AudioTourState();
  }
}

class _AudioTourState extends ConsumerState<AudioTour> {
  PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 1;

  @override
  initState() {
    super.initState();

    //
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          // Section 1: Progress Indicator
          Container(
            color: Colors.white,
            height: screenHeight * 0.15,
            width: screenWidth * 0.95,
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: 20),
            child: TourProgress(
              currentPosition: _currentPage,
              totalPlaces:
                  widget.tourAudioTranscript.placeAudioTranscripts.length,
              places: widget.tour.updatedPlaces!,
              onPressed: (int index) {
                _pageController.animateToPage(index,
                    duration: Durations.long2, curve: Curves.easeIn);
                // =  (index.toDouble());
              },
            ),
          ),
          Container(
            height: 2,
            color: Colors.purple,
          ),
          Expanded(
            child: PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: (value) {
                setState(() {
                  _currentPage = value + 1;
                });
              },
              itemCount:
                  widget.tourAudioTranscript.placeAudioTranscripts.length,
              itemBuilder: (context, index) {
                final placeData =
                    widget.tourAudioTranscript.placeAudioTranscripts[index];
                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Routes(
                            tour: widget.tour,
                            focus: widget.tour.places
                                .where((element) =>
                                    element.name ==
                                    widget.tour.updatedPlaces![index])
                                .first
                                .coordinates,
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: FloatingActionButton(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            alignment: Alignment.topRight,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Text(
                                                  "Tour Transcript",
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                // SizedBox(width: 20,),
                                                IconButton(
                                                  icon: Icon(Icons.close),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: screenHeight * 0.7,
                                            // width: screenWidth * 0.8,
                                            // padding: EdgeInsets.all(16),
                                            child: AudioTourSubtitles(
                                              tourData: placeData,
                                            ), // Replace with your widget
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Icon(Icons.text_snippet_outlined),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 80,
                            child: FloatingActionButton(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            alignment: Alignment.topRight,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Text(
                                                  "Tour Trivia",
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                // SizedBox(width: 20,),
                                                IconButton(
                                                  icon: Icon(Icons.close),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                              color: Colors.white,
                                              // padding: EdgeInsets.all(16),
                                              child: Quiz(
                                                trivia: placeData.trivia,
                                              )),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Image.asset(
                                "assets/images/quiz_icon.png",
                                scale: 3.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 2,
                      color: Colors.purple,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          color: Colors.white,
                          // height: screenHeight * 0.15,
                          width: screenWidth * 0.1,
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(top: 10),
                          child: IconButton(
                            icon: Icon(
                              Icons.keyboard_arrow_left,
                              size: 30,
                            ),
                            onPressed: () {
                              // Handle back button press
                              _pageController.previousPage(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeIn);
                            },
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color:
                                  Colors.white, // Set the border color to black
                              width: 2.0, // Set the border width
                            ),
                          ),
                          height: screenHeight * 0.05,
                          child: Text(
                            placeData.placeName,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          // height: screenHeight * 0.15,
                          width: screenWidth * 0.1,
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(top: 10),
                          child: IconButton(
                            icon: Icon(Icons.keyboard_arrow_right, size: 30),
                            onPressed: () {
                              // Handle forward button press
                              _pageController.nextPage(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeIn);
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 200,
                      color: Color.fromARGB(255, 255, 255, 255),
                      width: screenWidth,
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: AudioTranscriptPlayer(placeData.audioFile!),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
