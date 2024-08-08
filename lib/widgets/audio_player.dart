import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final fadeOutDuration = Duration(seconds: 3);
  bool _isPlayButtonPressed = false;
  bool _isFFButtonPressed = false;
  bool _isRewindButtonPressed = false;

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

  void _applyFadeOutEffect() {
    final remaining = _duration! - _position;
    final fadeOutFactor =
        remaining.inMilliseconds / fadeOutDuration.inMilliseconds;
    final volume = fadeOutFactor.clamp(0.0, 1.0);
    _player.setVolume(volume);
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
          activeColor: Colors.purple,
          thumbColor: Colors.purple,
          inactiveColor: Colors.black,
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
            Text(_formatDuration(_duration ?? Duration.zero - _position)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              child: Image.asset(
                alignment: Alignment.bottomCenter,
                _isRewindButtonPressed
                    ? 'assets/images/buttons/rewind/rewind_down.png'
                    : 'assets/images/buttons/rewind/rewind_up.png',
                scale: 9,
              ),
              onTap: _rewind,
              onTapDown: (details) => setState(() {
                _isRewindButtonPressed = true;
              }),
              onTapUp: (details) => setState(() {
                _isRewindButtonPressed = false;
              }),
            ),
            GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              onTapDown: (details) async {
                setState(() {
                  _isPlayButtonPressed = true;
                  _isPlaying = !_isPlaying;
                });
                if (_isPlaying) {
                  await _player.play();
                } else {
                  await _player.pause();
                }
              },
              onTapUp: (details) {
                setState(() {
                  _isPlayButtonPressed = false;
                });
              },
              child: Builder(builder: (context) {
                String image = 'assets/images/buttons/play_pause/play_up.png';
                if (_isPlaying) {
                  if (_isPlayButtonPressed)
                    image = 'assets/images/buttons/play_pause/pause_down.png';
                  else
                    image = 'assets/images/buttons/play_pause/pause_up.png';
                } else {
                  if (_isPlayButtonPressed)
                    image = 'assets/images/buttons/play_pause/play_down.png';
                  else
                    image = 'assets/images/buttons/play_pause/play_up.png';
                }

                return Image.asset(
                  image,
                  alignment: Alignment.topCenter,
                  scale: 8,
                  width: 100, // Adjust the width as needed
                  height: 100, // Adjust the height as needed
                );
              }),
            ),
            GestureDetector(
              child: Image.asset(
                alignment: Alignment.bottomCenter,
                _isFFButtonPressed
                    ? 'assets/images/buttons/fast_forward/ff_down.png'
                    : 'assets/images/buttons/fast_forward/ff_up.png',
                scale: 9,
              ),
              onTap: _forward,
              onTapDown: (details) => setState(() {
                _isFFButtonPressed = true;
              }),
              onTapUp: (details) => setState(() {
                _isFFButtonPressed = false;
              }),
            ),
          ],
        ),
      ],
    );
  }
}
