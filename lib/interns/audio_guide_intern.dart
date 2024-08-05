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

  Future<String> initSession(
      String commaSeparatedPlaces, String city, String tour) async {
    await dotenv.load(fileName: ".env");
    final generationConfig = GenerationConfig(
        temperature: 0.9, maxOutputTokens: 50000, topK: 40, stopSequences: []);

    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: dotenv.env['gemini_api_key']!,
      generationConfig: generationConfig,
    );
    chatBot = model!.startChat();
    final response = await chatBot!.sendMessage(Content.text("""
I am going for a walking tour named "$tour" in $city. You will act as my tour guide. 
I am visiting the following places - $commaSeparatedPlaces. Do not change the order of the places.
Talk about the history of the place, current affairs, architecture and things to do/see around here. 
All your responses should be in plain text, no markdowns, no formatting. 
Do not use special characters in your transcript. Do not use double quotes or single quotes.
Only allowable characters are alphabets, commas, periods, apostrophe and hyphens.
Sample output:
{
"tourName": <str> [name of the tour]
"greeting": <str> [the greeting to be played as an audio, describing the tour and hint at whats to come],
"placeAudioTranscripts":
  [
  "placeName": <str> [place name, without the city name],
  
  "sections": [
        {
          "header": <str> [Topics covered in the audio tour (keep it simple). There should be atleast 5 topics eg.history, architecture],
          "tourAudio": <str> [Audio tour transcript. Should be atleast 300 words in each topic except intro and outro. After the outbreak section needs to be atleast 500 words],
        },
        ... [generate same format for all sections. intro and outro are mandatory sections]
  
  ],

  "trivia": {
      "question": <str> [the question posed about the place. make it about an interesting fact or folklore],
      "options" : list<str> [4 options containing the possible answers to the question],
      "correctAnswer": <str> [one among a,b,c or d for the 4 options],
      "feedback": <str> [an explanation for selecting the correct answer. elaborate on the answer],
  }
  ]
...[generate same format for all places]
"outro": <str> [an outro for the tour. At the end of the outro, ask them to rate the app in google play and consider donating to support], 
}
Do not write any additional details. Make sure the JSON is valid.
      """));
    initialized = true;
    // print(response.text!);

    return response.text!;
  }
}
