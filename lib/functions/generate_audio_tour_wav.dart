import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lorehunter/models/audio_tour_transcript.dart';
import 'package:path_provider/path_provider.dart';

Future<void> writeToFile(ByteData data, String path) {
  final buffer = data.buffer;
  return new File(path)
      .writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

void setVoice(FlutterTts flutterTts, Map voice, String type) {
  flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  if (type == "header") {
    flutterTts.setSpeechRate(0.4);
    flutterTts.setPitch(1);
  } else {
    flutterTts.setSpeechRate(0.5);
    flutterTts.setPitch(1.2);
  }
  // _flutterTts.synthesizeToFile(text, fileName)
}

Future<void> tourCreator(TourAudioTranscript tourAudioTranscript) async {
  final _flutterTts = FlutterTts();
  final tempDir = await Directory.systemTemp;
  Directory directory = await getApplicationDocumentsDirectory();
  var outputFile;

  // Load background sound assets (replace paths if needed)
  final placeByteData = await rootBundle.load('assets/place.wav');
  final placeWavBytes = placeByteData.buffer.asUint8List();
  final sectionByteData = await rootBundle.load('assets/section.wav');
  final sectionWavBytes = sectionByteData.buffer.asUint8List();

  for (final placeAudioTranscript
      in tourAudioTranscript.placeAudioTranscripts) {
    outputFile =
        File("${directory.path}/output_${placeAudioTranscript.placeName}.wav");
    // Speak place name with background sound

    await _flutterTts.setVoice({"name": "en-gb-x-gbd-local"});
    await _mixAndSpeak(
      text: placeAudioTranscript.placeName,
      backgroundBytes: placeWavBytes,
      outputFile: outputFile,
    );
    await Future.delayed(const Duration(seconds: 1)); // 1 second pause

    for (final section in placeAudioTranscript.sections) {
      // Speak section header with background sound
      await _flutterTts.setVoice({"name": "en-gb-x-gbd-local"});
      await _mixAndSpeak(
        text: section.header,
        backgroundBytes: sectionWavBytes,
        outputFile: outputFile,
      );
      await Future.delayed(
          const Duration(milliseconds: 300)); // 0.5 second pause

      // Speak tour audio with current voice and background sound
      await _flutterTts.setVoice({"name": "en-gb-x-gbd-local"});
      await _mixAndSpeak(
        text: section.tourAudio,
        backgroundBytes: sectionWavBytes,
        outputFile: outputFile,
      );
      await Future.delayed(
          const Duration(milliseconds: 500)); // 0.5 second pause
    }
  }

  await _flutterTts.stop();
  print('Tour audio created: ${outputFile.path}');
}

/// Mixes audio with background sound and appends it to the output file.
Future<void> _mixAndSpeak({
  required String text,
  required Uint8List backgroundBytes,
  required File outputFile,
}) async {
  final spokenAudio = await _speakToByteArray(text);
  final mixedAudio = _mixAudio(backgroundBytes, spokenAudio);

  // Write WAV header and mixed audio data to the output file
  await outputFile
      .writeAsBytes(_createWavHeader(mixedAudio.length) + mixedAudio);
}

/// Converts text to a byte array using text-to-speech.
Future<Uint8List> _speakToByteArray(String text) async {
  final audioSink = p();
  await _flutterTts.speakToSink(text, audioSink);
  return audioSink.sink as Uint8List;
}

/// Mixes two byte arrays representing audio data (simple averaging).
Uint8List _mixAudio(Uint8List background, Uint8List audio) {
  final mixed = Uint8List(background.length);
  for (var i = 0; i < background.length; i++) {
    mixed[i] = (background[i] + audio[i]) ~/ 2;
  }
  return mixed;
}

/// Creates a WAV header based on the provided audio length.
Uint8List _createWavHeader(int audioLength) {
  final numSamples = audioLength ~/ 2; // Assuming 16-bit PCM audio
  final sampleRate = 44100; // Adjust sample rate as needed
  final numChannels = 1; // Mono audio
  final bitsPerSample = 16;

  final byteRate = sampleRate * numChannels * (bitsPerSample / 8);
  final blockAlign = numChannels * (bitsPerSample / 8);

  final dataSize = audioLength;

  final buffer = ByteData(44);
  buffer.setUint32(0, 0x46464952, Endian.little); // RIFF
  buffer.setUint32(4, 36 + dataSize, Endian.little); // Chunk size
  buffer.setUint32(8, 0x57415645, Endian.little); // WAVE
  buffer.setUint32(12, 0x20746D66, Endian.little); // fmt sub-chunk
  buffer.setUint32(16, 16, Endian.little); // Sub-chunk size
  buffer.setUint16(20, 1, Endian.little); // Audio format (1 for PCM)
  buffer.setUint16(22, numChannels, Endian.little);
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, byteRate, Endian.little);
  buffer.setUint16(32, blockAlign, Endian.little);
  buffer.setUint16(34, bitsPerSample, Endian.little);
  buffer.setUint32(36, 0x64617461, Endian.little); // Data sub-chunk
  buffer.setUint32(40, dataSize, Endian.little);

  return buffer.buffer.asUint8List();
}
