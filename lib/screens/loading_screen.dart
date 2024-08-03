import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lorehunter/functions/generate_audio_tour_wav.dart';
import 'package:lorehunter/interns/audio_guide_intern.dart';
import 'package:lorehunter/models/audio_tour_transcript.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/screens/audio_tour.dart';

class TourAudioLoadingScreen extends StatefulWidget {
  final Tour tour;
  final Map<String, String> settings;

  const TourAudioLoadingScreen(
      {Key? key, required this.tour, required this.settings})
      : super(key: key);

  @override
  _TourAudioLoadingScreenState createState() => _TourAudioLoadingScreenState();
}

class _TourAudioLoadingScreenState extends State<TourAudioLoadingScreen> {
  bool _transcriptGenerated = false;
  late AudioGuide _audioGuide;
  late TourAudioTranscript _tourAudioTranscript;
  AudioProcessor _audioProcessor = AudioProcessor();
  final List<String> _audioFiles = [];

  int _progress = 0;

  @override
  void initState() {
    super.initState();

    _audioGuide = AudioGuide(theme: widget.settings['theme']!);
    generateAudioTour();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<TourAudioTranscript> getScript() async {
    final cachedTranscript = await getAudioTranscriptForTour(widget.tour.id);
    if (cachedTranscript != null) {
      setState(() {
        _tourAudioTranscript = cachedTranscript;
        _transcriptGenerated = true;
        _progress += 1;
      });
      return cachedTranscript;
    }
    final jsonString = await _audioGuide.initSession(
        widget.tour.updatedPlaces!.join(", "),
        widget.tour.city,
        widget.tour.name);
    final audioTourScript = await jsonDecode(jsonString);
    setState(() {
      _tourAudioTranscript =
          TourAudioTranscript.fromJson(audioTourScript, widget.tour.id);
      _transcriptGenerated = true;
      _progress += 1;
    });

    await _tourAudioTranscript.toJsonFile();
    return _tourAudioTranscript;
  }

  Future<List<String>> getAudioFile() async {
    List<PlaceAudioTranscript> placeAudioTranscripts = [];
    for (var placeAudioTranscript
        in _tourAudioTranscript.placeAudioTranscripts) {
      final file = await _audioProcessor.savePlaceAudio(
          placeAudioTranscript.sections,
          placeAudioTranscript.placeName,
          _tourAudioTranscript.tourName);
      placeAudioTranscript.audioFile = file;
      placeAudioTranscripts.add(placeAudioTranscript);

      setState(() {
        _audioFiles.add(file);
        _progress += 1;
      });
    }
    _tourAudioTranscript.placeAudioTranscripts = placeAudioTranscripts;
    await _tourAudioTranscript.toJsonFile();
    return _audioFiles;
  }

  Future<void> generateAudioTour() async {
    await getScript();
    await getAudioFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.7,
        height: MediaQuery.sizeOf(context).height * 0.9,
        alignment: Alignment.center,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              loadingIndicator("Generating Tour Transcript",
                  _transcriptGenerated ? "completed" : "inProgress"),
              SizedBox(
                height: 20,
              ),
              loadingIndicator(
                  "Generating Audio from Transcript",
                  _progress == 0
                      ? "notStarted"
                      : _progress == widget.tour.updatedPlaces!.length + 1
                          ? "completed"
                          : "inProgress"),
              if (_progress > 0)
                Container(
                  height: 200,
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  alignment: Alignment.topLeft,
                  child: generatePlacesLoader(
                      widget.tour.updatedPlaces!, _progress),
                ),
              SizedBox(
                height: 80,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AudioTour(
                      tourAudioTranscript: _tourAudioTranscript,
                      tour: widget.tour,
                    );
                  }));
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  side: BorderSide(color: Colors.purple),
                  elevation: 5,
                  backgroundColor: Colors.purple[100],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Start tour",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                    )
                  ],
                ),
              ),
            ]),
      ),
    ));
  }
}

Widget generatePlacesLoader(List<String> places, int progress) {
  String state;
  String place;
  return ListView.builder(
    itemCount: places.length,
    itemBuilder: ((context, index) {
      place = places[index];
      if (progress > places.indexOf(place))
        state = "completed";
      else if (progress == places.indexOf(place))
        state = "inProgress";
      else
        state = "notStarted";

      return loadingIndicator(place, state);
    }),
  );
}

Widget loadingIndicator(String text, String state) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(text),
      const SizedBox(width: 10),
      Builder(builder: (context) {
        switch (state) {
          case 'notStarted':
            return const SizedBox.shrink();
          case 'inProgress':
            return Container(
                width: 20,
                height: 10,
                child: const CircularProgressIndicator());
          case 'completed':
            return const Icon(Icons.check, color: Colors.green);
          default:
            return const SizedBox.shrink();
        }
      })
    ],
  );
}
