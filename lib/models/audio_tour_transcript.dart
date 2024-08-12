import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TourAudioTranscript {
  final String tourID;
  final String tourName;

  List<PlaceAudioTranscript> placeAudioTranscripts;
  final String greeting;
  final String outro;

  final String? greetingFile;
  final String? outroFile;

  TourAudioTranscript({
    required this.tourID,
    required this.tourName,
    required this.greeting,
    required this.outro,
    required this.placeAudioTranscripts,
    this.greetingFile,
    this.outroFile,
  });

  factory TourAudioTranscript.fromJson(
      Map<String, dynamic> json, String tourID) {
    return TourAudioTranscript(
      tourID: tourID,
      tourName: json['tourName'],
      greeting: json['greeting'],
      outro: json['outro'],
      placeAudioTranscripts: (json['placeAudioTranscripts'] as List)
          .map(
              (placeAudioJson) => PlaceAudioTranscript.fromJson(placeAudioJson))
          .toList(),
    );
  }

  Future<void> toJsonFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final toursDirectory = Directory('${directory.path}/audioTranscripts');
      if (!await toursDirectory.exists()) {
        await toursDirectory.create(recursive: true);
      }
      final file = File('${toursDirectory.path}/$tourID.json');

      final jsonData = jsonEncode(toJson());
      await file.writeAsString(jsonData);
      print('JSON file saved successfully! - $tourID');
    } catch (error) {
      print(error.toString());
    }
  }

  Map<String, dynamic> toJson() => {
        'tourName': tourName,
        'tourID': tourID,
        'greeting': greeting,
        'outro': outro,
        'placeAudioTranscripts': placeAudioTranscripts
            .map((placeAudioTranscript) => placeAudioTranscript.toJson())
            .toList(),
      };
}

class PlaceAudioTranscript {
  final String placeName;
  final List<Section> sections;
  Trivia trivia;

  String? audioFile;

  PlaceAudioTranscript({
    required this.placeName,
    required this.sections,
    required this.trivia,
    this.audioFile,
  });

  factory PlaceAudioTranscript.fromJson(Map<String, dynamic> json) {
    return PlaceAudioTranscript(
      placeName: json['placeName'],
      sections: (json['sections'] as List)
          .map((sectionJson) => Section.fromJson(sectionJson))
          .toList(),
      trivia: Trivia.fromJson(json['trivia']),
    );
  }

  Map<String, dynamic> toJson() => {
        'placeName': placeName,
        'sections': sections.map((section) => section.toJson()).toList(),
        'trivia': trivia.toJson(),
      };
}

class Section {
  final String header;
  final String tourAudio;

  Section({
    required this.header,
    required this.tourAudio,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      header: json['header'] as String,
      tourAudio: json['tourAudio'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'header': header,
        'tourAudio': tourAudio,
      };
}

class Trivia {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String feedback;
  int? selectedAnswer;

  Trivia({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.feedback,
  });

  factory Trivia.fromJson(Map<String, dynamic> json) {
    return Trivia(
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'] as String,
      feedback: json['feedback'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        'feedback': feedback,
        'selectedAnswer': selectedAnswer,
      };
}

Future<TourAudioTranscript?> getAudioTranscriptForTour(String tourID) async {
  final baseDirectory = await getApplicationDocumentsDirectory();
  final directory = Directory("${baseDirectory.path}/audioTranscripts");

  try {
    final file = File('${directory.path}/$tourID.json');
    // print(file.readAsString());
    if (await file.exists()) {
      final jsonData = await file.readAsString();
      return TourAudioTranscript.fromJson(jsonDecode(jsonData), tourID);
    } else {
      print('Audio transcript file not found for tour ID: $tourID');
      return null;
    }
  } catch (error) {
    print('Error reading file: $error');
    return null;
  }
}
