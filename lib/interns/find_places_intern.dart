import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    );

    model ??= GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: dotenv.env['gemini_api_key']!,
      generationConfig: generationConfig,
    );

    final prompt = """
Generate a walking tour for me in the city of $city.
All places must within 5km radius of each other. 
All your responses should be in plain text, no markdowns, no formatting.
Your response should be of the following format- 
Sample output:
{ 
  "name": <str> [a name for the tour],
  "brief": <str> [A one liner about the tour less than 20 words],
  "bestExperiencedAt": <str> [best @ time of day, choose between Morning, Afternoon and Evening],


  "places": [
    {
      "place_name": <str> [name of the place],
      "place_type": <str> [the type of the place - park/monument/museum etc.],
      "place_brief": <str> [A one liner about the place - about 20 words],
      "place_wikiURL": <str> https://en.wikipedia.org/wiki/Wikipedia:Requested_articles,
      "place_duration":<int> [ideal amount of time to be spent at the location in mins, should be between 15,30,45,60]
    },
    ... [generate same format for all places]
  
  ]
}
Do not write any additional details. Make sure the JSON is valid
    """;
    final content = [Content.text(prompt)];
    final response = await model!.generateContent(content);
    return response.text!;
  }
}
