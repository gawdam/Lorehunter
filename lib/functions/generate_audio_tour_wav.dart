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
  final externalDirectory = Directory("/storage/emulated/0/Music/");

  final fileName =
      'lorehunterAudio_${DateTime.now().millisecondsSinceEpoch}.wav';
  final filePath = '${externalDirectory.path}$fileName';
  print(filePath);

  try {
    final files = await externalDirectory.list().toList();
    for (final file in files) {
      if (file is Directory) {
        print("files" + file.path);
      }
    }
  } catch (e) {
    print('Error listing files: $e');
  }
  var bytes = Uint8List(0);
  try {
    await flutterTts.awaitSynthCompletion(true);
    await flutterTts.synthesizeToFile(script, fileName);
    await Future.delayed(Durations.extralong1);
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
Future<String> mixAudio(String background, String audio, String outputFilePath,
    {double backgroundVolume = 0.3, double taper = 1.0}) async {
  print("mixiing audio");
  await FFmpegKit.execute(
          'ffmpeg -y -i $audio -i $background -filter_complex "[1:a]volume=$backgroundVolume[a1];[0:a][a1]amix=inputs=2:duration=first:dropout_transition=2[out]" -map "[out]" $outputFilePath')
      .then((session) async {
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print("success");
      // SUCCESS
    } else if (ReturnCode.isCancel(returnCode)) {
      print('cancel');
    } else {
      print('error mixing audio');
    }
  });
  return outputFilePath;
}

Future<String> concatenateAudio(List<String> audioList, String outputFilePath,
    {int pause = 1}) async {
  // Create the input file list for ffmpeg
  final inputFiles = audioList.join('|');

  // Create the ffmpeg command with pause between audios
  final command =
      'ffmpeg -i "concat:$inputFiles|${List.filled(audioList.length - 1, "pause=$pause:c:a").join('|')}"\' -acodec copy $outputFilePath';

  // Execute the ffmpeg command
  final session = await FFmpegKit.executeAsync(command);

  final returnCode = await session.getReturnCode();
  final output = await session.getOutput();
  final failStackTrace = await session.getFailStackTrace();

  // Handle the result
  if (ReturnCode.isSuccess(returnCode)) {
    print('Audio concatenation successful.');
    return outputFilePath;
  } else {
    // Handle error, e.g., log error message, throw an exception
    print('Audio concatenation failed.');
    print('FFmpeg output: $output');
    print('FFmpeg error: $failStackTrace');
    return '';
  }
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

Future<void> writeToFile(ByteData data, String path) async {
  final buffer = data.buffer;
  await File(path)
      .writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  print("saved assets");
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
    headerFile = await mixAudio(
        headerFile, file.path + "/headerBG.wav", file.path + '/headerBG.wav');
    print("mixed header audio");

    bodyFile = await saveTTSAudio(section.tourAudio, "body");
    print("saved body");

    bodyFile = await mixAudio(
        bodyFile, file.path + "/bodyBG.wav", file.path + '/bodyBG.wav');
    print("mixed body audio");

    if (audio == null) {
      audio = await concatenateAudio([headerFile, bodyFile], filePath);
    } else {
      audio = await concatenateAudio([audio, headerFile, bodyFile], filePath);
    }
  }

  return filename;
}
