import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lorehunter/interns/audio_guide_intern.dart';
import 'package:lorehunter/models/audio_tour_transcript.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/screens/loading_screen.dart';
import 'package:lorehunter/widgets/audio_player.dart';
import 'package:lorehunter/widgets/audio_tour_subtitles.dart';
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
          Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Colors.grey[200],
                height: screenHeight * 0.1,
                width: screenWidth * 0.1,
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: 8),
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    // Handle back button press
                    _pageController.previousPage(
                        duration: Duration(milliseconds: 100),
                        curve: Curves.easeIn);
                  },
                ),
              ),
              Container(
                color: Colors.grey[200],
                height: screenHeight * 0.1,
                width: screenWidth * 0.8,
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: 20),
                child: TourProgress(
                  currentPosition: _currentPage,
                  totalPlaces:
                      widget.tourAudioTranscript.placeAudioTranscripts.length,
                ),
              ),
              Container(
                color: Colors.grey[200],
                height: screenHeight * 0.1,
                width: screenWidth * 0.1,
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: 8),
                child: IconButton(
                  icon: Icon(Icons.arrow_forward),
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
                    Container(
                      color: Colors.purple[300],
                      height: screenHeight * 0.05,
                      child: Center(
                        child: Text(
                          placeData.placeName,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Routes(tour: widget.tour),
                    ),
                    Container(
                      height: 200,
                      width: screenWidth * 0.9,
                      child: AudioTranscriptPlayer(placeData.audioFile!),
                    ),
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
