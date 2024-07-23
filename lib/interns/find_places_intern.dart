import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlacesFinder {
  static GenerativeModel? model;
  static ChatSession? chatBot;
  bool initialized = false;

  Future<void> initAI() async {
    await dotenv.load(fileName: ".env");
    final generationConfig = GenerationConfig(
        temperature: 0.6, maxOutputTokens: 1500, topK: 40, stopSequences: []);

    model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: dotenv.env['gemini_api_key']!,
        generationConfig: generationConfig);
    initialized = true;
  }

  Future<String> askGemini(String city) async {
    chatBot = model!.startChat();
    final response = await chatBot!.sendMessage(Content.text("""
Generate a walking tour for me in the city of $city.
All places must within 5km radius of each other. 
All your responses should be in plain text, no markdowns, no formatting.
Your response should be of the following format- 
Sample output:
{ 
  "name": <str> [a name for the tour],
  "brief": <str> [A one liner about the tour less than 20 words],
  "best_experienced_at": <str> [best @ time of day, choose between Morning, Afternoon and Evening],
  "greetings": <str> [the greeting to be played as an audio, describing the tour <100 words],
  "outro": <str> [an outro for the tour < 100 words],

  "places": [
        {
          "place_name": <str> [name of the place],
          "place_type": <str> [the type of the place - park/monument/museum etc.],
          "place_brief": <str> [A one liner about the place - about 20 words],
          "place_wikiURL": <str> [URL of the wikipedia page for this place],
          "place_duration":<int> [ideal amount of time to be spent at the location in mins, should be between 15,30,45,60]
        },
        ... [generate same format for all places]
  
  ]
}
Do not write any additional details. Make sure the JSON is valid
      """));

    return response.text!;
  }
}
