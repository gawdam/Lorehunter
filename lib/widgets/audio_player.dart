import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lorehunter/functions/generate_audio_tour_wav.dart';
import 'package:lorehunter/models/audio_tour_transcript.dart';
import 'package:path_provider/path_provider.dart';

class AudioTranscriptPlayer extends ConsumerStatefulWidget {
  String fileName;

  AudioTranscriptPlayer(this.fileName);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AudioPlayer();
  }
}

class _AudioPlayer extends ConsumerState<AudioTranscriptPlayer> {
  bool _isPlaying = false;
  final _player = AudioPlayer();
  final _processor = AudioProcessor();
  String placeName = "sample";
  @override
  initState() {
    super.initState();
    _player.setFilePath(widget.fileName);
  }

  @override
  Widget build(BuildContext context) {
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
  }
}
