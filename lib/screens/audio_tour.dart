import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lorehunter/interns/audio_guide_intern.dart';
import 'package:lorehunter/widgets/audio_player.dart';
import 'package:lorehunter/widgets/tour_details_page.dart';

class AudioTour extends StatefulWidget {
  String city;
  List<String> places;

  AudioTour({required this.places, required this.city});
  @override
  State<AudioTour> createState() {
    return _AudioTourState();
  }
}

class _AudioTourState extends State<AudioTour> {
  AudioGuide _audioGuide = AudioGuide(theme: "the last of us");
  PageController _pageController = PageController(initialPage: 1);

  @override
  initState() {
    super.initState();

    //
  }

  Future<Map> getScript() async {
    final jsonString =
        await _audioGuide.initSession(widget.places.join(", "), widget.city);
    final audioTourScript = await jsonDecode(jsonString);
    print(audioTourScript['tour'][0]);
    return audioTourScript;
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
                for (var i in (snapshot.data!['tour']))
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
