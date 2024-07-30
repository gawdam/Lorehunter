import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lorehunter/models/audio_tour_transcript.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

//step 1: save the audio
Future<Uint8List> saveTTSAudio(String script, String type) async {
  final flutterTts = FlutterTts();

  // Set voice, pitch, and speed based on type
  if (type == 'header') {
    await flutterTts.setVoice({
      "name": "en-gb-x-gbd-local",
      "locale": "en-US"
    }); // Replace with desired header voice
    await flutterTts.setSpeechRate(0.5); // Adjust speech rate as needed
    await flutterTts.setPitch(1.0); // Adjust pitch as needed
  } else if (type == 'body') {
    await flutterTts.setVoice({
      "name": "en-in-x-ahp-local",
      "locale": "en-GB"
    }); // Replace with desired body voice
    await flutterTts.setSpeechRate(0.6); // Adjust speech rate as needed
    await flutterTts.setPitch(0.9); // Adjust pitch as needed
  } else {
    throw ArgumentError('Invalid type: $type');
  }

  final tempDir = await getTemporaryDirectory();
  final filePath =
      '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';

  await flutterTts.synthesizeToFile(script, filePath);

  Uint8List uint8list = Uint8List.fromList(File(filePath).readAsBytesSync());

  return uint8list;
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

Future<String> savePlaceAudio(List<Section> sections, String filename) async {
  print(sections);
  Uint8List header;
  Uint8List body;
  Uint8List headerBackground = Uint8List.fromList(
      File("assets/music/music_header.mp3").readAsBytesSync());
  Uint8List bodyBackground =
      Uint8List.fromList(File("assets/music/music_body.mp3").readAsBytesSync());

  Uint8List audio = Uint8List(0);
  int count = 0;
  for (var section in sections) {
    print("Count : $count");
    count += 1;
    header = await saveTTSAudio(section.header, "header");

    header = mixAudio(header, headerBackground);

    body = await saveTTSAudio(section.tourAudio, "body");
    body = mixAudio(header, bodyBackground);

    audio = concatenateAudio([audio, header, body]);
  }
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$filename.wav');
  await file.writeAsBytes(audio);

  return filename;
}
