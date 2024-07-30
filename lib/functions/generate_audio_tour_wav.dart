import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lorehunter/models/audio_tour_transcript.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

//step 1: save the audio
Future<String> saveTTSAudio(String script, String type) async {
  final flutterTts = FlutterTts();
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
  final externalDirectory = Directory("/storage/emulated/0/Music");

  final fileName =
      'lorehunterAudio_${DateTime.now().millisecondsSinceEpoch}.wav';
  final filePath = '${externalDirectory.path}/$fileName';
  print(filePath);
  print("checkpoint 4");
  var bytes = Uint8List(0);
  try {
    await flutterTts.awaitSynthCompletion(true);
    await flutterTts.synthesizeToFile(script, fileName);
    // Introduce a small delay to ensure file creation
    bool doesFileExist = await File(filePath).exists();
    if (doesFileExist) {
      print("exists");
      bytes = File(filePath).readAsBytesSync();
    } else {
      throw Exception('File not created: ' + filePath);
    }
  } catch (e) {
    print('Error saving audio file: $e');
    rethrow; // Rethrow the error for handling in the calling function
  }

  return filePath;
}

/// Mixes two byte arrays representing audio data (simple averaging).
String mixAudio(String background, String audio, String outputFilePath,
    {double backgroundVolume = 0.3, double taper = 1.0}) {
  print("mixiing audio");
  FFmpegKit.execute(
          'ffmpeg -i $audio -i $background -filter_complex "[1:a]volume=$backgroundVolume[a1];[0:a][a1]amix=inputs=2:duration=first:dropout_transition=2[out]" -map "[out]" $outputFilePath')
      .then((session) async {
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print("success");
      // SUCCESS
    } else if (ReturnCode.isCancel(returnCode)) {
      // CANCEL
    } else {
      // ERROR
    }
  });
  return outputFilePath;
}

Future<String> concatenateAudio(List<String> audioList, String outputFilePath,
    {int pause = 1}) async {
  // Generate input files string
  final inputFiles = audioList.map((audio) => '-i $audio').join(' ');

  // Generate filters for each input
  final filters = audioList.asMap().entries.map((entry) {
    final index = entry.key;
    final audio = entry.value;
    return '[$index:a]';
  }).join('');

  // Construct the filter_complex string
  final concatFilter = 'concat=n=${audioList.length}:v=0:a=1[out]';

  print(
      'ffmpeg $inputFiles -filter_complex "$filters$concatFilter" -map "[out]" $outputFilePath');

  // Execute the command
  final session = await FFmpegKit.execute(
      'ffmpeg $inputFiles -filter_complex "$filters$concatFilter" -map "[out]" $outputFilePath');

  // Handle session result (you can expand this part based on your needs)
  final returnCode = await session.getReturnCode();
  if (ReturnCode.isSuccess(returnCode)) {
    print('Audio concatenation successful.');
  } else {
    print('Audio concatenation failed.');
  }

  return outputFilePath;
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

Future<void> writeToFile(ByteData data, String path) {
  final buffer = data.buffer;
  return new File(path)
      .writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

Future<String> savePlaceAudio(List<Section> sections, String filename) async {
  String headerFile;
  String bodyFile;
  var headerBackground = await rootBundle.load("assets/music/music_header.mp3");
  var bodyBackground = await rootBundle.load("assets/music/music_body.mp3");

  final file = await getApplicationDocumentsDirectory();
  final filePath = file.path + "/$filename.wav";
  if (await File(filePath).exists()) {
    return filePath;
  }
  await writeToFile(headerBackground, file.path + "/headerBG.wav");
  await writeToFile(bodyBackground, file.path + "/bodyBG.wav");

  String? audio;
  int count = 0;
  for (var section in sections) {
    print("Count : $count");
    count += 1;
    headerFile = await saveTTSAudio(section.header, "header");

    print("saved header");
    headerFile = mixAudio(
        headerFile, file.path + "/headerBG.wav", file.path + '/header.wav');
    print("mixed header audio");

    bodyFile = await saveTTSAudio(section.tourAudio, "body");
    print("saved body");

    bodyFile =
        mixAudio(bodyFile, file.path + "/bodyBG.wav", file.path + '/body.wav');
    print("mixed body audio");

    if (audio == null) {
      audio = await concatenateAudio([headerFile, bodyFile], filePath);
    } else {
      audio = await concatenateAudio([audio, headerFile, bodyFile], filePath);
    }
  }

  return filename;
}
