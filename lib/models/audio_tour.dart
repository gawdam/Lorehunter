import 'package:lorehunter/models/trivia.dart';

class Section {
  final String header;
  final String tourAudio;

  Section({
    required this.header,
    required this.tourAudio,
  });
}

class AudioTour {
  final String placeName;
  final List<Section> sections;
  final Trivia trivia;

  AudioTour({
    required this.placeName,
    required this.sections,
    required this.trivia,
  });
}
