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

  Future<String> initSession(String commaSeparatedPlaces, String city) async {
    await dotenv.load(fileName: ".env");
    final generationConfig = GenerationConfig(
        temperature: 0.8, maxOutputTokens: 25000, topK: 40, stopSequences: []);

    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: dotenv.env['gemini_api_key']!,
      generationConfig: generationConfig,
    );
    chatBot = model!.startChat();
    final response = await chatBot!.sendMessage(Content.text("""
I am going for a walking tour in $city. You will act as my tour guide. 
I am visiting the following places - $commaSeparatedPlaces
The theme of this tour is the last of us. At the end of the audio tour for each place, include a section "After the outbreak", where you detail on what happened to the place after the fungal outbreak.
Along the lines of - Did the infected take over? was it bombed? was it used as a camp by rebels? or by fireflies? 
Make the tour interesting, like a story.

All your responses should be in plain text, no markdowns, no formatting. 
Do not use quotes or special characters in your transcript. No quotes as well.
Only allowable characters are alphabets, commas, periods, apostrophe and hyphens.
Sample output:
{ 
tour:
  [
  "name": <str> [place name, without the city name],
  "sections": [
        {
          "header": <str> [Topics covered in the audio tour (keep it simple). There should be atleast 5 topics eg.history, architecture],
          "tourAudio": <str> [Audio tour transcript. Should be atleast 300 words in each topic except intro and outro. After the outbreak section needs to be atleast 500 words],
        },
        ... [generate same format for all sections. intro, after the outbreak and outro are mandatory sections]
  
  ],

  "trivia": {
      "question": <str> [the question posed about the place. make it about an interesting fact or folklore],
      "options" : list<str> [4 options containing the possible answers to the question],
      "correct_answer": <str> [one among a,b,c or d for the 4 options],
      "correct_answer_response": <str> [an explanation for selecting the correct answer. elaborate on the answer],
  }
  ]
  ...[generate same format for all places]
}
Do not write any additional details. Make sure the JSON is valid
      """));
    initialized = true;
    // print(response.text!);

    return response.text!;
  }
}
