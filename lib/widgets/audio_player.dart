import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lorehunter/models/place_details.dart';

class AudioPlayer extends ConsumerStatefulWidget {
  String transcript;

  AudioPlayer(this.transcript);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AudioPlayer();
  }
}

class _AudioPlayer extends ConsumerState<AudioPlayer> {
  FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  List<String> _filteredListofVoices = [
    'en-us-x-tpd-network',
    'en-gb-x-gbb-local',
    'en-gb-x-gbd-local',
    'en-gb-x-rjs-local',
    'en-gb-x-gbc-local',
    'en-in-x-ahp-local',
    'en-us-x-tpc-local',
  ];

  List<Map> _voices = [];
  Map? _currentVoice;

  int? _currentWordStart, _currentWordEnd;

  @override
  void initState() {
    super.initState();

    initTTS();
  }

  Widget _speakerSelector() {
    return DropdownButton(
      value: _currentVoice,
      items: _voices
          .map(
            (_voice) => DropdownMenuItem(
              value: _voice,
              child: Text(
                _voice["name"],
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _currentVoice = value!;
        });
        setVoice(value!);
      },
    );
  }

  void initTTS() {
    _flutterTts.setProgressHandler((text, start, end, word) {
      setState(() {
        _currentWordStart = start;
        _currentWordEnd = end;
      });
    });
    _flutterTts.getVoices.then((data) {
      try {
        List<Map> voices = List<Map>.from(data);
        setState(() {
          _voices = voices
              .where((voice) => _filteredListofVoices.contains(voice['name']))
              .toList();
          _currentVoice = _voices.first;
          setVoice(_currentVoice!);
        });
      } catch (e) {
        print(e);
      }
    });
  }

  void setVoice(Map voice) {
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setPitch(1);
    // _flutterTts.synthesizeToFile(text, fileName)
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _speakerSelector(),
        ElevatedButton(
          onPressed: () {
            _isPlaying = !_isPlaying;
            if (_isPlaying) {
              _flutterTts.speak(widget.transcript);
            } else {
              _flutterTts.pause();
            }
          },
          child: Icon(_isPlaying ? Icons.play_arrow : Icons.pause),
        ),
      ],
    );
  }
}
