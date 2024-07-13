import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lorehunter/models/place_details.dart';

class AudioPlayer extends ConsumerStatefulWidget {
  PlaceDetails placeDetails;

  AudioPlayer(this.placeDetails);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AudioPlayer();
  }
}

class _AudioPlayer extends ConsumerState<AudioPlayer> {
  bool _isPlaying = false;
  bool _hasStarted = false;
  FlutterTts _flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _isPlaying = !_isPlaying;
        if (_isPlaying && _hasStarted) {
          _flutterTts.speak(widget.placeDetails.audioTourGreeting);
        } else if (_isPlaying) {
          _flutterTts.speak(widget.placeDetails.audioTourGreeting);
        } else {
          _flutterTts.pause();
        }
      },
      child: Icon(_isPlaying ? Icons.play_arrow : Icons.pause),
    );
  }
}
