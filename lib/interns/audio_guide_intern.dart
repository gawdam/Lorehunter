import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AudioGuide {
  AudioGuide({required this.theme});
  static GenerativeModel? model;
  static ChatSession? chatBot;
  bool initialized = false;
  String theme;

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
      You are an audio tour guide.
      I will type the name of the place and you will write the description of the place. Create an alternate lore about this place, set in the theme of the Last of us.
      All your responses should be in plain text, no markdowns, no formatting. Do not use quotes in your transcript.
      Sample output:
      { 
        "name": <str> [place name]
        "brief": <str> [A one liner about the place less than 20 words]
        "detailedAudioTour": <str> [Audio tour transcript. 500 words]
        "wikiURL": <str> [URL of the wikipedia page for this place]
        "duration":<int> [ideal amount of time to be spent at the location in mins, should be between 15,30,45,60]
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
