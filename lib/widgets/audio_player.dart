import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lorehunter/models/audio_tour_transcript.dart';

class AudioPlayer extends ConsumerStatefulWidget {
  List<Section> sections;

  AudioPlayer(this.sections);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AudioPlayer();
  }
}

class _AudioPlayer extends ConsumerState<AudioPlayer> {
  FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  Map? _headerVoice, _contentVoice;
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
        setVoice(value!, "content");
      },
    );
  }

  Future<void> playSection(int index) async {
    if (index >= widget.sections.length) return;
    await _flutterTts.awaitSpeakCompletion(true);

    // Play section header
    setVoice(_headerVoice!, "header");

    await _flutterTts.speak(widget.sections[index].header);

    await _flutterTts.setSilence(1);

    // Play tour audio
    setVoice(_currentVoice!, "content");
    await _flutterTts.speak(widget.sections[index].tourAudio);

    // Pause for 2 seconds
    await _flutterTts.setSilence(1);

    // Play the next section
    if (index + 1 < widget.sections.length) {
      await playSection(index + 1);
    }
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
          setVoice(_currentVoice!, "content");
          _headerVoice = _voices
              .firstWhere((voice) => voice['name'] == 'en-gb-x-gbd-local');
          _contentVoice = _voices
              .firstWhere((voice) => voice['name'] == 'en-gb-x-gbd-local');
        });
      } catch (e) {
        print(e);
      }
    });
  }

  void setVoice(Map voice, String type) {
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
    if (type == "header") {
      _flutterTts.setSpeechRate(0.4);
      _flutterTts.setPitch(1);
    } else {
      _flutterTts.setSpeechRate(0.5);
      _flutterTts.setPitch(1.2);
    }
    // _flutterTts.synthesizeToFile(text, fileName)
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _speakerSelector(),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isPlaying = !_isPlaying;
            });
            if (_isPlaying) {
              playSection(0);
            } else {
              _flutterTts.pause();
            }
          },
          child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
        ),
      ],
    );
  }
}
