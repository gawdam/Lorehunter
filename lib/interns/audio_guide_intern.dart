import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AudioGuide {
  AudioGuide({required this.theme});
  static GenerativeModel? model;
  static ChatSession? chatBot;
  bool initialized = false;
  String theme = "the last of us tv series";

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
      I will type the name of the place and you will write the description of the place. The theme of the tour will be $theme.
      Sample output:
      { 
        "name": <str> [place name]
        "description": <str> [A one liner about the place less than 20 words]
        "transcript": <str> [Audio tour transcript. 500 words]
        "wiki_url": <str> [URL of the wikipedia page for this place]
        "duration":<str> 
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
