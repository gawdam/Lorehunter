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
    await initSession();
  }

  Future<void> initSession() async {
    chatBot = model!.startChat();
    await chatBot!.sendMessage(Content.text("""
I will type the location that I'm in and you will generate a walking tour of that location for me.
Give the tour a very cool name.
There should be a total of 5 places
All places must within 5km radius of each other. 
All your responses should be in plain text, no markdowns, no formatting.
Your response should be of the following format- 
Sample output:
{ 
  "name": <str> [tour name],
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
    initialized = true;
  }

  Future<String> gemini(String prompt) async {
    final content = Content.text(prompt);
    final response = await chatBot!.sendMessage(content);
    print(response.text);
    return response.text!;
  }
}
