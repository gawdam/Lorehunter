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
    _flutterTts.setSpeechRate(0.6);
    _flutterTts.setPitch(1);
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
              _flutterTts.speak(
                  """Welcome, history buffs, sun seekers, and curious explorers! I'm your virtual guide on this audio tour of Marina Beach, Chennai's pride and joy. Stretching for a magnificent six kilometers along the Bay of Bengal, Marina Beach is the second longest urban beach in the world, offering a captivating blend of nature's serenity and urban energy.

As we begin our walk, let's soak in the atmosphere. Feel the warm sand between your toes, listen to the rhythmic roar of the waves, and witness the vibrant tapestry of life unfolding before you. Kite flyers dance on the shore, families picnic under colorful umbrellas, and vendors hawk their wares, their calls blending with the cries of seagulls.

A Walk Through History

Marina Beach boasts a rich past, whispering tales of bygone eras. We start our journey near Fort St. George, a majestic symbol of British colonialism. Built in the 17th century, this fort witnessed the rise and fall of empires and now houses a museum showcasing Chennai's colonial history. Look for the Flagstaff House, the erstwhile residence of the British Governors, and marvel at the neo-classical architecture.""");
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
