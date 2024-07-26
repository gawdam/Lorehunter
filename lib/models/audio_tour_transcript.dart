import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Section {
  final String header;
  final String tourAudio;

  Section({
    required this.header,
    required this.tourAudio,
  });
  Map<String, dynamic> toJson() => {
        'header': header,
        'tourAudio': tourAudio,
      };
}

class Trivia {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String correctAnswerResponse;

  Trivia({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.correctAnswerResponse,
  });
  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        'correctAnswerResponse': correctAnswerResponse,
      };
}

class AudioTourTranscript {
  final String tourID;
  final String placeName;
  final List<Section> sections;
  final Trivia trivia;

  AudioTourTranscript({
    required this.tourID,
    required this.placeName,
    required this.sections,
    required this.trivia,
  });

  Future<void> toJsonFile(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename.json');

      final jsonData = jsonEncode(this.toJson());
      await file.writeAsString(jsonData);
      print('JSON file saved successfully!');
    } catch (error) {
      print(error.toString());
    }
  }

  Map<String, dynamic> toJson() => {
        'tourID': tourID,
        'name': placeName,
        'sections': sections.map((section) => section.toJson()).toList(),
        'trivia': trivia.toJson(),
      };
}
