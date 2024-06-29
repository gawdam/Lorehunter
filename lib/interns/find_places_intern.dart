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

    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: dotenv.env['gemini_api_key']!,
    );
    await initSession();
  }

  Future<void> initSession() async {
    chatBot = model!.startChat();
    await chatBot!.sendMessage(Content.text("""
      I will type the location that I'm in and you will generate a walking tour of that location for me.
      Give the tour a very cool name.
      All places must within a 5km radius. 
      The order of locations should be chained in such a way that the total distance is minimum. 
      All your responses should be in plain text, no markdowns, no formatting.
      Your response should be of the following format- 
      Sample output:
      { 
        "name": <str> [tour name]
        "places": list<str> [list of places]
        "best_experienced_at": str [best @ time of day, choose between morning, afternoon and evening]
        "types": list<str> [the type of the place - park/monument/museum]
        "icons": list<str> [an android icon for this place]
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
