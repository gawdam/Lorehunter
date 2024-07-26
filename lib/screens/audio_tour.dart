import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorehunter/interns/audio_guide_intern.dart';
import 'package:lorehunter/models/audio_tour_transcript.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/widgets/audio_player.dart';
import 'package:lorehunter/widgets/tour_details_page.dart';

class AudioTour extends ConsumerStatefulWidget {
  Tour tour;

  AudioTour({required this.tour});
  @override
  ConsumerState<AudioTour> createState() {
    return _AudioTourState();
  }
}

class _AudioTourState extends ConsumerState<AudioTour> {
  AudioGuide _audioGuide = AudioGuide(theme: "the last of us");
  PageController _pageController = PageController(initialPage: 1);
  late TourAudioTranscript audioTourTranscript;

  @override
  initState() {
    super.initState();

    //
  }

  Future<TourAudioTranscript> getScript() async {
    final cachedTranscript = await getAudioTranscriptForTour(widget.tour.id);
    if (cachedTranscript != null) {
      return cachedTranscript;
    }
    final jsonString = await _audioGuide.initSession(
        widget.tour.updatedPlaces!.join(", "),
        widget.tour.city,
        widget.tour.name);
    final audioTourScript = await jsonDecode(jsonString);
    audioTourTranscript =
        TourAudioTranscript.fromJson(audioTourScript, widget.tour.id);

    await audioTourTranscript.toJsonFile();
    return audioTourTranscript;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: getScript(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(color: Colors.red);
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Text('Error fetching audio tour script.');
            } else {
              return PageView(controller: _pageController, children: [
                for (var i in (snapshot.data!.placeAudioTranscripts))
                  TourDetailsPage(
                    tourData: i,
                  ),
              ]);
            }
          },
        ),
      ),
    );
  }
}
