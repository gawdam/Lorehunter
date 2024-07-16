import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; // Import for rich text display

class TourDetailsPage extends StatelessWidget {
  final Map<String, dynamic> tourData;

  const TourDetailsPage({Key? key, required this.tourData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tourData['name']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display tour name as a heading
            Text(
              tourData['name'],
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // Loop through sections and display headers and descriptions
            for (final section in tourData['sections'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['header'],
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Html(
                    data: section[
                        'tourAudio'], // Use Html widget for rich text display
                  ),
                ],
              ),
            const SizedBox(height: 16.0),

            // Display trivia question and options
            Text(
              tourData['trivia']['question'],
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              children: [
                for (final option in tourData['trivia']['options'])
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
              'Correct Answer: ${tourData['trivia']['correct_answer']}',
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Html(
              data: tourData['trivia']['correct_answer_response'],
            ),
          ],
        ),
      ),
    );
  }
}
