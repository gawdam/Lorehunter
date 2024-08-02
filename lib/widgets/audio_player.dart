import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lorehunter/functions/generate_audio_tour_wav.dart';
import 'package:lorehunter/models/audio_tour_transcript.dart';
import 'package:path_provider/path_provider.dart';

class AudioTranscriptPlayer extends ConsumerStatefulWidget {
  final String fileName;

  AudioTranscriptPlayer(this.fileName);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AudioTranscriptPlayer();
  }
}

class _AudioTranscriptPlayer extends ConsumerState<AudioTranscriptPlayer> {
  bool _isPlaying = false;
  final _player = AudioPlayer();
  String placeName = "sample";
  Duration? _duration;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.setFilePath(widget.fileName);
    _player.durationStream.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });
    _player.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void _rewind() async {
    final newPosition = _position - Duration(seconds: 15);
    if (newPosition >= Duration.zero) {
      await _player.seek(newPosition);
    } else {
      await _player.seek(Duration.zero);
    }
  }

  void _forward() async {
    final newPosition = _position + Duration(seconds: 15);
    if (_duration != null && newPosition <= _duration!) {
      await _player.seek(newPosition);
    } else {
      await _player.seek(_duration ?? Duration.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Slider(
          value: _position.inSeconds.toDouble(),
          min: 0.0,
          max: _duration?.inSeconds.toDouble() ?? 0.0,
          onChanged: (value) async {
            await _player.seek(Duration(seconds: value.toInt()));
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(_position)),
            Text(_formatDuration(_duration! - _position)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.fast_rewind),
              onPressed: _rewind,
            ),
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
            IconButton(
              icon: Icon(Icons.fast_forward),
              onPressed: _forward,
            ),
          ],
        ),
      ],
    );
  }
}
