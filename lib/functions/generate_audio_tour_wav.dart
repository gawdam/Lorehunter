import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lorehunter/models/audio_tour_transcript.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

double value = 1000000065;

//step 1: save the audio
Future<Uint8List> saveTTSAudio(String script, String type) async {
  value += 1;
  final flutterTts = FlutterTts();
  print("checkpoint 1");
  var headerVoice;
  var contentVoice;
  flutterTts.getVoices.then((data) {
    try {
      List<Map> voices = List<Map>.from(data);

      headerVoice =
          voices.firstWhere((voice) => voice['name'] == 'en-gb-x-gbd-local');
      contentVoice =
          voices.firstWhere((voice) => voice['name'] == 'en-gb-x-gbb-local');
    } catch (e) {
      print(e);
    }
  });
  print("checkpoint 2");

  // Set voice, pitch, and speed based on type
  // if (type == 'header') {
  //   await flutterTts.setVoice(headerVoice); // Replace with desired header voice
  //   await flutterTts.setSpeechRate(0.5); // Adjust speech rate as needed
  //   await flutterTts.setPitch(1.0); // Adjust pitch as needed
  // } else if (type == 'body') {
  //   await flutterTts.setVoice(contentVoice); // Replace with desired body voice
  //   await flutterTts.setSpeechRate(0.6); // Adjust speech rate as needed
  //   await flutterTts.setPitch(0.9); // Adjust pitch as needed
  // } else {
  //   throw ArgumentError('Invalid type: $type');
  // }
  print("checkpoint 3");
  final externalDirectory = Directory("/storage/emulated/0");

  try {
    final files = externalDirectory.listSync();
    print(externalDirectory.path);
    for (final file in files) {
      print(file.path);
    }
  } catch (e) {
    print('Error listing files: $e');
  }

  final fileName =
      'lorehunterAudio_${DateTime.now().millisecondsSinceEpoch}.wav';
  final filePath = '${externalDirectory.path}/$fileName';
  print(filePath);
  print("checkpoint 4");
  var bytes = Uint8List(0);
  try {
    await flutterTts.awaitSynthCompletion(true);
    var d = await flutterTts.synthesizeToFile(script, fileName);
    print("d: $d");
    // Introduce a small delay to ensure file creation
    await Future.delayed(const Duration(milliseconds: 500));

    if (await File(filePath).exists()) {
      print("exists");
      bytes = File(filePath).readAsBytesSync();
    } else {
      throw Exception('File not created: ' + filePath);
    }
  } catch (e) {
    print('Error saving audio file: $e');
    rethrow; // Rethrow the error for handling in the calling function
  }

  print("bytes");
  return bytes;
}

/// Mixes two byte arrays representing audio data (simple averaging).
Uint8List mixAudio(Uint8List background, Uint8List audio,
    {double backgroundVolume = 0.3, double taper = 1.0}) {
  final mixed = Uint8List(audio.length);
  final taperLength =
      (taper * audio.length / 100).round(); // Convert taper to samples
  var taperFactor;

  for (var i = 0; i < audio.length; i++) {
    final backgroundValue =
        (background[i] * backgroundVolume).clamp(0, 255).toInt();
    final audioValue = audio[i];

    // Apply taper
    taperFactor = i < taperLength
        ? i / taperLength
        : audio.length > i + taperLength
            ? (audio.length - i) / taperLength
            : 1.0;
    final mixedValue =
        (backgroundValue * taperFactor + audioValue) ~/ (1 + backgroundVolume);

    mixed[i] = mixedValue.clamp(0, 255);
  }

  return mixed;
}

Uint8List concatenateAudio(List<Uint8List> audioList, {int pause = 1}) {
  final sampleRate = 44100; // Adjust sample rate as needed
  final numChannels = 1; // Mono audio
  final bitsPerSample = 16;
  final byteRate = sampleRate * numChannels * (bitsPerSample / 8);
  final blockAlign = numChannels * (bitsPerSample / 8);

  // Calculate total length of the concatenated audio
  int totalLength = 0;
  for (final audio in audioList) {
    totalLength += audio.length;
  }
  totalLength += (audioList.length - 1) * pause * sampleRate; // Add pauses

  final concatenatedAudio = Uint8List(totalLength);
  int offset = 0;

  for (int i = 0; i < audioList.length; i++) {
    final audio = audioList[i];
    concatenatedAudio.setRange(offset, offset + audio.length, audio);
    offset += audio.length;

    // Add pause if it's not the last audio
    if (i < audioList.length - 1) {
      final pauseBytes =
          Uint8List(pause * sampleRate * 2); // Assuming 16-bit PCM
      concatenatedAudio.setRange(
          offset, offset + pauseBytes.length, pauseBytes);
      offset += pauseBytes.length;
    }
  }

  return concatenatedAudio;
}

Uint8List _adjustVolume(Uint8List audioBytes, double volumeRatio) {
  final adjustedAudioBytes = Uint8List.fromList(audioBytes);
  for (int i = 0; i < adjustedAudioBytes.length; i++) {
    adjustedAudioBytes[i] = (audioBytes[i] * volumeRatio).clamp(0, 255).toInt();
  }
  return adjustedAudioBytes;
}

Future<Uint8List> getBytes(String filePath) async {
  ByteData byteData = await rootBundle.load(filePath);

  Uint8List bytes = byteData.buffer.asUint8List();
  return bytes;
}

Future<String> savePlaceAudio(List<Section> sections, String filename) async {
  Uint8List header;
  Uint8List body;
  print("generatingBackgroundHeader");
  Uint8List headerBackground = await getBytes("assets/music/music_header.mp3");
  print("generatingBackgroundBody");
  Uint8List bodyBackground = await getBytes("assets/music/music_body.mp3");

  Uint8List audio = Uint8List(0);
  int count = 0;
  for (var section in sections) {
    print("Count : $count");
    count += 1;
    header = await saveTTSAudio(section.header, "header");
    print("saved header");
    header = mixAudio(header, headerBackground);
    print("mixed header audio");

    body = await saveTTSAudio(section.tourAudio, "body");
    print("saved body");

    body = mixAudio(header, bodyBackground);
    print("mixed body audio");

    audio = concatenateAudio([audio, header, body]);
  }
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$filename.wav');
  await file.writeAsBytes(audio);

  return filename;
}
