import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lorehunter/prompt_engineering/prompts.dart';

class AudioGuide {
  AudioGuide({required this.theme});
  static GenerativeModel? model;

  String theme;

  Future<String> initSession(
      String commaSeparatedPlaces, String city, String tour,
      {String? responseSchema}) async {
    AudioPrompts audioPrompts = AudioPrompts(
        type: theme,
        tourName: tour,
        city: city,
        commaSeparatedPlaces: commaSeparatedPlaces);
    final prompt = audioPrompts.getPrompt();
    final content = [Content.text(prompt)];
    await dotenv.load(fileName: ".env");

    final generationConfig = GenerationConfig(
      temperature: 1.7,
      maxOutputTokens: 50000,
      topK: 40,
      stopSequences: [],
      responseMimeType: 'application/json',
      responseSchema: Schema.object(
        properties: {
          "tourName": Schema.string(description: "Name of the tour"),
          "greeting": Schema.string(description: "Greeting for the tour"),
          "outro": Schema.string(description: "Outro for the tour"),
          "placeAudioTranscripts": Schema.array(
            items: Schema.object(properties: {
              "placeName": Schema.string(description: "name of the place"),
              "sections": Schema.array(
                items: Schema.object(properties: {
                  "header": Schema.string(description: "Header of the section"),
                  "tourAudio": Schema.string(
                      description:
                          "The audio transcript for the walking tour of this section"),
                }, requiredProperties: [
                  "header",
                  "tourAudio"
                ]),
              ),
              "trivia": Schema.object(
                properties: {
                  "question": Schema.string(description: "A trivia question"),
                  "correctAnswer": Schema.string(
                      description: "The correct answer for the question"),
                  "feedback": Schema.string(
                      description: "feedback for the correct answer"),
                  "options":
                      Schema.array(items: Schema.string(description: "Options"))
                },
                requiredProperties: [
                  "question",
                  "options",
                  "correctAnswer",
                  "feedback"
                ],
              ),
            }, requiredProperties: [
              "placeName",
              "sections",
              "trivia"
            ]),
          ),
        },
      ),
    );

    model ??= GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: dotenv.env['gemini_api_key']!,
      generationConfig: generationConfig,
    );

    final response = await model!.generateContent(content);
    return (response.text!);
  }
}
