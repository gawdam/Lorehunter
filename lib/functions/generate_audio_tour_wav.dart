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

class AudioProcessor {
  AudioProcessor({required this.voice, required this.theme});
  final voice;
  final theme;

  final FlutterTts flutterTts = FlutterTts();

  final List<String> tempFiles = [];

  Future<String> saveTTSAudio(String script, String type) async {
    var headerVoice;
    var contentVoice;
    await flutterTts.getVoices.then((data) {
      try {
        List<Map> voices = List<Map>.from(data);

        if (voice == "male") {
          headerVoice = voices
              .firstWhere((voice) => voice['name'] == 'en-gb-x-gbd-local');
          contentVoice = voices
              .firstWhere((voice) => voice['name'] == 'en-gb-x-gbd-local');
        } else {
          headerVoice = voices
              .firstWhere((voice) => voice['name'] == 'en-us-x-tpc-local');
          contentVoice = voices
              .firstWhere((voice) => voice['name'] == 'en-us-x-tpc-local');
        }
      } catch (e) {
        print(e);
      }
    });

    if (type == 'header') {
      flutterTts.setVoice(
          {"name": headerVoice["name"], "locale": headerVoice["locale"]});
      flutterTts.setSpeechRate(0.5);
      flutterTts.setVolume(1);
      flutterTts.setPitch(1.0);
    } else if (type == 'body') {
      flutterTts.setVoice(
          {"name": contentVoice["name"], "locale": contentVoice["locale"]});
      flutterTts.setSpeechRate(0.5);
      flutterTts.setVolume(1);
      flutterTts.setPitch(1.0);
    }

    final externalDirectory = Directory("/storage/emulated/0/Music/");
    final internalDirectory = await getApplicationDocumentsDirectory();
    final fileName =
        'lorehunterAudio_${DateTime.now().millisecondsSinceEpoch}.wav';
    final filePath = '${externalDirectory.path}$fileName';
    final internalPath = '${internalDirectory.path}/$fileName';
    tempFiles.add(filePath);
    tempFiles.add(internalPath);

    try {
      await flutterTts.awaitSynthCompletion(true);
      await flutterTts.synthesizeToFile(script, fileName);
      bool doesFileExist = await File(filePath).exists();
      if (doesFileExist) {
        await (File(filePath)).copy(internalPath);
      } else {
        throw Exception('File not created: ' + filePath);
      }
    } catch (e) {
      print('Error saving audio file: $e');
      rethrow;
    }

    return internalPath;
  }

  Future<String> mixAudio(
      String audio, String background, String outputFilePath,
      {double backgroundVolume = 0.3,
      double taper = 1.0,
      String bitrate = '320k'}) async {
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
      '-b:a',
      bitrate,
      outputFilePath
    ];

    print('Executing command with arguments: $arguments');

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

    tempFiles.add(outputFilePath);

    return outputFilePath;
  }

  Future<String> concatenateAudio(List<String> audioList, int outputCount,
      {int pause = 1, String bitrate = '320k'}) async {
    final inputFiles = audioList.expand((audio) => ['-i', audio]).toList();
    final outputFile = await getApplicationDocumentsDirectory();
    final outputFilePath =
        "${outputFile.path}/lorehunterSection$outputCount.wav";
    final filters = List.generate(audioList.length, (index) => '[$index:a]');
    final concatFilter =
        filters.join('') + 'concat=n=${audioList.length}:v=0:a=1[out]';

    final arguments = [
      '-y',
      ...inputFiles,
      '-filter_complex',
      concatFilter,
      '-map',
      '[out]',
      '-b:a',
      bitrate,
      outputFilePath
    ];

    print('Executing command with arguments: $arguments');

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

    tempFiles.add(outputFilePath);

    return outputFilePath;
  }

  Future<Uint8List> getBytes(String filePath) async {
    ByteData byteData = await rootBundle.load(filePath);
    Uint8List bytes = byteData.buffer.asUint8List();
    return bytes;
  }

  Future<void> createDirectoryIfNotExists(String finalFilePath) async {
    final directoryPath =
        finalFilePath.substring(0, finalFilePath.lastIndexOf('/'));
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  Future<void> writeToFile(ByteData data, String path) async {
    tempFiles.add(path);
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    print("saved assets");
  }

  Future<String> addSilence(String inputFilePath, String outputFilePath,
      {double silenceDuration = 1, String bitrate = '320k'}) async {
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
      '-b:a',
      bitrate,
      outputFilePath
    ];
    tempFiles.add(outputFilePath);

    print('Executing command with arguments: $arguments');

    final session = await FFmpegKit.executeWithArguments(arguments);

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

  Future<void> deleteTempFiles({required String finalAudioFilePath}) async {
    for (String filePath in tempFiles) {
      if (filePath != finalAudioFilePath) {
        final file = File(filePath);
        if (await file.exists()) {
          try {
            await file.delete();
            print('Deleted temporary file: $filePath');
          } catch (e) {
            print('Failed to delete temporary file: $filePath, Error: $e');
          }
        }
      }
    }
    // Clear the _tempFiles list after deletion
    tempFiles.clear();
  }

  Future<String> savePlaceAudio(
      List<Section> sections, String filename, String tourName,
      {String? greeting, String? outro, String? voice}) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final finalFilePath = "${documentsDirectory.path}/$tourName/$filename.wav";
    if (await File(finalFilePath).exists()) {
      print("audio file already exists");
      return finalFilePath;
    }

    var headerBackground =
        await rootBundle.load("assets/music/music_header.wav");
    var bodyBackground = await rootBundle.load("assets/music/music_body.mp3");
    var bodyThemedBackground =
        await rootBundle.load("assets/music/music_theme.mp3");

    await writeToFile(
        headerBackground, documentsDirectory.path + "/headerBG.wav");
    if (theme == "The usual") {
      await writeToFile(
          bodyBackground, documentsDirectory.path + "/bodyBG.wav");
    } else {
      await writeToFile(
          bodyThemedBackground, documentsDirectory.path + "/bodyBG.wav");
    }

    String? audio;
    int count = 0;

    if (greeting != null) {
      audio = await saveTTSAudio(greeting, "body");
    }
    for (var section in sections) {
      print("Count : $count");
      count += 1;

      String headerFile = await saveTTSAudio(section.header, "header");
      headerFile = await addSilence(
          headerFile, documentsDirectory.path + '/silencedHeader.wav');
      headerFile = await mixAudio(
          headerFile,
          documentsDirectory.path + "/headerBG.wav",
          documentsDirectory.path + '/header.wav',
          backgroundVolume: 0.7);
      print("HeaderFile:" + headerFile);

      String bodyFile = await saveTTSAudio(section.tourAudio, "body");

      if (audio == null) {
        audio = await concatenateAudio([headerFile, bodyFile], count);
      } else {
        audio = await concatenateAudio([audio, headerFile, bodyFile], count);
      }
    }
    if (outro != null) {
      final outroAudio = await saveTTSAudio(outro, "body");
      audio = await concatenateAudio([audio!, outroAudio], count);
    }
    var finalAudio = await mixAudio(
        audio!,
        documentsDirectory.path + "/bodyBG.wav",
        documentsDirectory.path + '/finalAudio.wav',
        backgroundVolume: 0.1);

    await createDirectoryIfNotExists(finalFilePath);
    await File(finalAudio)
        .copy("${documentsDirectory.path}/$tourName/$filename.wav");

    await deleteTempFiles(finalAudioFilePath: finalFilePath);

    return finalFilePath;
  }
}
