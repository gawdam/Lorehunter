import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lorehunter/models/audio_tour_transcript.dart';
import 'package:lorehunter/widgets/audio_player.dart'; // Import for rich text display

class TourDetailsPage extends StatelessWidget {
  final PlaceAudioTranscript tourData;

  const TourDetailsPage({Key? key, required this.tourData}) : super(key: key);

  String tourToString() {
    // Convert sections and trivia options to JSON-compatible lists
    final sections = tourData.sections;

    // Create a string builder for efficient concatenation
    final StringBuffer buffer = StringBuffer();

    for (var section in sections) {
      buffer.writeln(section.header);
      buffer.writeln(section.tourAudio);
      buffer.writeln(); // Add a newline for separation
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Audio tour"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display tour name as a heading
            Text(
              tourData.placeName,
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // Loop through sections and display headers and descriptions
            for (final section in tourData.sections)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.header,
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Html(
                    data: section
                        .tourAudio, // Use Html widget for rich text display
                  ),
                ],
              ),
            const SizedBox(height: 16.0),

            // Display trivia question and options
            Text(
              tourData.trivia.question,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              children: [
                for (final option in tourData.trivia.options)
                  ChoiceChip(
                    label: Text(option),
                    selected:
                        false, // Set to false as we're not showing selection
                  ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Display trivia answer and explanation
            Text(
              'Correct Answer: ${tourData.trivia.correctAnswer}',
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Html(
              data: tourData.trivia.feedback,
            ),
            AudioTranscriptPlayer("tourData.sections")
          ],
        ),
      ),
    );
  }
}
