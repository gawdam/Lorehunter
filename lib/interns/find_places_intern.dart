import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lorehunter/prompt_engineering/prompts.dart';

class PlacesFinder {
  static GenerativeModel? model;

  Future<String> getPlaces(String city) async {
    await dotenv.load(fileName: ".env");
    final generationConfig = GenerationConfig(
      temperature: 1.6,
      maxOutputTokens: 2000,
      topK: 40,
      stopSequences: [],
      responseMimeType: 'application/json',
      responseSchema: Schema.object(properties: {
        "name": Schema.string(
          description: "a name for the tour",
        ),
        "brief": Schema.string(
          description: "A one liner about the tour less than 20 words",
        ),
        "bestExperiencedAt": Schema.string(
          description:
              "best @ time of day, choose between Morning, Afternoon and Evening",
        ),
        "places": Schema.array(
          items: Schema.object(properties: {
            "place_name": Schema.string(
              description: "name of the place",
            ),
            "place_type": Schema.string(
              description: "the type of the place - park/monument/museum etc.",
            ),
            "place_brief": Schema.string(
              description: "A one liner about the place - about 20 words",
            ),
            "place_wikiURL": Schema.string(
              description: "wiki link of the place",
            ),
            "place_tip": Schema.string(
              description:
                  "A tip on things to look out for, do or eat at this place",
            ),
          }, requiredProperties: [
            "place_name",
            "place_type",
            "place_brief",
            "place_wikiURL",
            "place_tip",
          ]),
        )
      }, requiredProperties: [
        "name",
        "brief",
        "bestExperiencedAt",
        "places"
      ]),
    );

    model ??= GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: dotenv.env['gemini_api_key']!,
      generationConfig: generationConfig,
    );

    final tourPrompt = TourPrompts(city: city);

    final prompt = tourPrompt.getPrompt();
    final content = [Content.text(prompt)];
    final response = await model!.generateContent(content);
    return response.text!;
  }
}
