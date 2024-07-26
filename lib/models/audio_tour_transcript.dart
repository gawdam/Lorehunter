import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TourAudioTranscript {
  final String tourID;
  final String tourName;

  final List<PlaceAudioTranscript> placeAudioTranscripts;
  final String greeting;
  final String outro;

  TourAudioTranscript({
    required this.tourID,
    required this.tourName,
    required this.greeting,
    required this.outro,
    required this.placeAudioTranscripts,
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
  final Trivia trivia;

  PlaceAudioTranscript({
    required this.placeName,
    required this.sections,
    required this.trivia,
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
        'name': placeName,
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
        'correctAnswerResponse': feedback,
      };
}

Future<TourAudioTranscript?> getAudioTranscriptForTour(String tourID) async {
  final baseDirectory = await getApplicationDocumentsDirectory();
  final directory = Directory("${baseDirectory.path}/audioTranscripts");

  try {
    final file = File('${directory.path}/$tourID.json');
    // print(file.readAsString());
    if (await file.exists()) {
      print("json file exists, read issue");
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
