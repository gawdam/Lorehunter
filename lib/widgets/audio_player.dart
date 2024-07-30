import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lorehunter/functions/generate_audio_tour_wav.dart';
import 'package:lorehunter/models/audio_tour_transcript.dart';
import 'package:path_provider/path_provider.dart';

class AudioTranscriptPlayer extends ConsumerStatefulWidget {
  List<Section> sections;

  AudioTranscriptPlayer(this.sections);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AudioPlayer();
  }
}

class _AudioPlayer extends ConsumerState<AudioTranscriptPlayer> {
  bool _isPlaying = false;
  final _player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: savePlaceAudio(widget.sections, "sample"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(
              color: Colors.amber,
            );
          }
          if (snapshot.data == null) {
            return CircularProgressIndicator(
              color: Colors.black,
            );
          }
          _player.setFilePath(snapshot.data!);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                  if (_isPlaying) {
                    await _player.play();
                  } else {
                    await _player.pause();
                  }
                },
                child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              ),
            ],
          );
        });
  }
}
