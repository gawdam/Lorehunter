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
      responseSchema: Schema.object(properties: {
        "tourName": Schema.string(description: "Name of the tour"),
        "greeting": Schema.string(
            description:
                "the greeting to be played as an audio, describing the tour and hint at whats to come"),
        "outro": Schema.string(
            description:
                "an outro for the tour. At the end of the outro, ask them to rate the app in google play and consider donating to support"),
        "placeAudioTranscripts": Schema.array(
          description: "A list of all the places visited in the tour",
          items: Schema.object(properties: {
            "placeName": Schema.string(description: "name of the place"),
            "sections": Schema.array(
              description:
                  "tour of the place, split into multiple sections. Introduction and outro are mandatory sections.",
              items: Schema.object(properties: {
                "header": Schema.string(
                    description:
                        "Topics covered in the audio tour (keep it simple). There should be atleast 5 topics eg.history, architecture"),
                "tourAudio": Schema.string(
                    description:
                        "Audio tour transcript. Should be atleast 300 words in each topic except Introduction and outro."),
              }, requiredProperties: [
                "header",
                "tourAudio"
              ]),
            ),
            "trivia": Schema.object(
              description: "trivia of the place",
              properties: {
                "question": Schema.string(
                    description:
                        "the question posed about the place. make it about an interesting fact or folklore"),
                "correctAnswer": Schema.string(
                    description: "one among a,b,c or d for the 4 options"),
                "feedback": Schema.string(
                    description:
                        "an explanation for selecting the correct answer. elaborate on the answer"),
                "options": Schema.array(
                    description:
                        "4 options containing the possible answers to the question",
                    items: Schema.string(description: "Options"))
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
      }, requiredProperties: [
        'tourName',
        'greeting',
        'outro',
        'placeAudioTranscripts'
      ]),
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
