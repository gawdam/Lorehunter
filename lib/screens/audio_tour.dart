import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorehunter/interns/audio_guide_intern.dart';
import 'package:lorehunter/models/audio_tour_transcript.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/screens/loading_screen.dart';
import 'package:lorehunter/widgets/audio_player.dart';
import 'package:lorehunter/widgets/tour_details_page.dart';

class AudioTour extends ConsumerStatefulWidget {
  TourAudioTranscript tourAudioTranscript;

  AudioTour({required this.tourAudioTranscript});
  @override
  ConsumerState<AudioTour> createState() {
    return _AudioTourState();
  }
}

class _AudioTourState extends ConsumerState<AudioTour> {
  PageController _pageController = PageController(initialPage: 0);

  @override
  initState() {
    super.initState();

    //
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(controller: _pageController, children: [
      for (var i in (widget.tourAudioTranscript.placeAudioTranscripts))
        TourDetailsPage(
          tourData: i,
        ),
    ]));
  }
}
