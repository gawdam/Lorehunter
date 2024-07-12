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
I will type the name of the place and you will write a script to act as an audio tour of the place. Make it interesting, like a story.

All your responses should be in plain text, no markdowns, no formatting. Do not use quotes or special characters in your transcript. Only allowable characters are alphabets, commas, periods, apostrophe and hyphens.
Sample output:
{ 
  "name": <str> [place name, without the city name]
  "brief": <str> [A one liner about the place less than 20 words]
  "wikiURL": <str> [URL of the wikipedia page for this place]
  "duration":<int> [ideal amount of time to be spent at the location in mins, should be between 15,30,45,60]

  "audioTourHeaders": list<str> [Topics covered in the audio tour. There should be atleast 5 topics]
  "audioTourDescriptions": list<str> [Audio tour transcript. Should be atleast 300 words in each topic]
  "audioTourGreeting": <str> [greeting and intro for the tour]
  "audioTourOutro" : <str> [outro for the tour]
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
