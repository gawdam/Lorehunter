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
  await flutterTts.getVoices.then((data) {
    try {
      List<Map> voices = List<Map>.from(data);

      headerVoice =
          voices.firstWhere((voice) => voice['name'] == 'en-gb-x-gbb-local');
      contentVoice =
          voices.firstWhere((voice) => voice['name'] == 'en-gb-x-gbd-local');
    } catch (e) {
      print(e);
    }
  });
  print(headerVoice);

  if (type == 'header') {
    flutterTts.setVoice({
      "name": headerVoice["name"],
      "locale": headerVoice["locale"]
    }); // Replace with desired header voice
    flutterTts.setSpeechRate(0.3); // Adjust speech rate as needed
    flutterTts.setPitch(1.0); // Adjust pitch as needed
  } else if (type == 'body') {
    flutterTts.setVoice({
      "name": contentVoice["name"],
      "locale": contentVoice["locale"]
    }); // Replace with desired body voice
    flutterTts.setSpeechRate(0.6); // Adjust speech rate as needed
    flutterTts.setPitch(0.9); // Adjust pitch as needed
  }
  final externalDirectory = Directory("/storage/emulated/0/Music/");
  final internalDirectory = await getApplicationDocumentsDirectory();

  final fileName =
      'lorehunterAudio_${DateTime.now().millisecondsSinceEpoch}.wav';
  final filePath = '${externalDirectory.path}$fileName';
  print(filePath);
  final internalPath = '${internalDirectory.path}/$fileName';

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
    bool doesFileExist = await File(filePath).exists();
    if (doesFileExist) {
      print("exists");
      await (File(filePath)).copy(internalPath);
    } else {
      throw Exception('File not created: ' + filePath);
    }
  } catch (e) {
    print('Error saving audio file: $e');
    rethrow; // Rethrow the error for handling in the calling function
  }

  return internalPath;
}

/// Mixes two byte arrays representing audio data (simple averaging).

Future<String> mixAudio(String audio, String background, String outputFilePath,
    {double backgroundVolume = 0.3, double taper = 1.0}) async {
  // Construct the arguments list
  final arguments = [
    '-y',
    '-i',
    audio,
    '-i',
    background,
    '-filter_complex',
    '[1:a]volume=$backgroundVolume[a1];[0:a][a1]amix=inputs=2:duration=first:dropout_transition=2[out]',
    '-map',
    '[out]',
    outputFilePath
  ];

  print('Executing command with arguments: $arguments');

  // Execute the command with arguments
  await FFmpegKit.executeWithArguments(arguments).then((session) async {
    final returnCode = await session.getReturnCode();
    final output = await session.getOutput();
    final failStackTrace = await session.getFailStackTrace();

    if (ReturnCode.isSuccess(returnCode)) {
      print("Audio mixing successful.");
    } else if (ReturnCode.isCancel(returnCode)) {
      print('Audio mixing was canceled.');
    } else {
      print('Audio mixing failed.');
      print('FFmpeg output: $output');
      print('FFmpeg error: $failStackTrace');
    }
  });

  return outputFilePath;
}

Future<String> concatenateAudio(List<String> audioList, int outputCount,
    {int pause = 1}) async {
  // Generate input files arguments
  final inputFiles = audioList.expand((audio) => ['-i', audio]).toList();
  final outputFile = await getApplicationDocumentsDirectory();
  final outputFilePath = "${outputFile.path}/lorehunterSection$outputCount.wav";

  // Generate the concat filter with pause
  final filters = List.generate(audioList.length, (index) => '[$index:a]');
  final concatFilter =
      filters.join('') + 'concat=n=${audioList.length}:v=0:a=1[out]';

  // Construct the arguments list
  final arguments = [
    '-y',
    ...inputFiles,
    '-filter_complex',
    concatFilter,
    '-map',
    '[out]',
    outputFilePath
  ];

  print('Executing command with arguments: $arguments');

  // Execute the command with arguments
  await FFmpegKit.executeWithArguments(arguments).then((session) async {
    final returnCode = await session.getReturnCode();
    final output = await session.getOutput();
    final failStackTrace = await session.getFailStackTrace();

    if (ReturnCode.isSuccess(returnCode)) {
      print('Audio concatenation successful.');
    } else {
      print('Audio concatenation failed.');
      print('FFmpeg output: $output');
      print('FFmpeg error: $failStackTrace');
    }
  });

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

Future<void> writeToFile(ByteData data, String path) async {
  final buffer = data.buffer;
  await File(path)
      .writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  print("saved assets");
}

Future<String> addSilence(String inputFilePath, String outputFilePath,
    {double silenceDuration = 1}) async {
  // Construct the arguments list for FFmpeg
  final arguments = [
    '-y',
    '-i',
    inputFilePath,
    '-filter_complex',
    '[0:a]asetpts=PTS-STARTPTS[s];'
        'aevalsrc=0:d=$silenceDuration[s1];'
        'aevalsrc=0:d=$silenceDuration[s2];'
        '[s1][s][s2]concat=n=3:v=0:a=1[out]',
    '-map',
    '[out]',
    outputFilePath
  ];

  print('Executing command with arguments: $arguments');

  // Execute the command with arguments
  final session = await FFmpegKit.executeWithArguments(arguments);

  // Handle session result
  final returnCode = await session.getReturnCode();
  final output = await session.getOutput();
  final failStackTrace = await session.getFailStackTrace();

  if (ReturnCode.isSuccess(returnCode)) {
    print('Silence addition successful.');
    return outputFilePath;
  } else {
    print('Silence addition failed.');
    print('FFmpeg output: $output');
    print('FFmpeg error: $failStackTrace');
    return '';
  }
}

Future<String> savePlaceAudio(List<Section> sections, String filename) async {
  final file = await getApplicationDocumentsDirectory();
  final filePath = file.path + "/$filename.wav";
  if (await File(filePath).exists()) {
    print("audio file already exists");
    return filePath;
  }
  String headerFile;
  String bodyFile;
  var headerBackground = await rootBundle.load("assets/music/music_header.wav");
  var bodyBackground = await rootBundle.load("assets/music/music_body.mp3");
  final externalDirectory = "/storage/emulated/0/Music/";

  await writeToFile(headerBackground, file.path + "/headerBG.wav");
  await writeToFile(bodyBackground, file.path + "/bodyBG.wav");

  String? audio;
  int count = 0;
  for (var section in sections) {
    print("Count : $count");
    count += 1;
    headerFile = await saveTTSAudio(section.header, "header");
    headerFile =
        await addSilence(headerFile, file.path + '/silencedHeader.wav');

    headerFile = await mixAudio(
        headerFile, file.path + "/headerBG.wav", file.path + '/header.wav',
        backgroundVolume: 0.7);
    print("HeaderFile:" + headerFile);

    bodyFile = await saveTTSAudio(section.tourAudio, "body");

    if (audio == null) {
      audio = await concatenateAudio([headerFile, bodyFile], count);
    } else {
      audio = await concatenateAudio([audio, headerFile, bodyFile], count);
    }
  }
  var finalAudio = await mixAudio(
      audio!, file.path + "/bodyBG.wav", file.path + '/finalAudio.wav',
      backgroundVolume: 0.1);

  await File(finalAudio).copy("$externalDirectory$filename.wav");
  return "$externalDirectory$filename.wav";
}
