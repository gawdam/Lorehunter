import 'package:google_generative_ai/google_generative_ai.dart';

class AudioPrompts {
  AudioPrompts({
    required this.type,
    required this.tourName,
    required this.city,
    required this.commaSeparatedPlaces,
  });
  String type;
  String tourName;
  String city;
  String commaSeparatedPlaces;
  String? prompt;
  String getPrompt() {
    String usualPrompt =
        """I am going for a walking tour named "$tourName" in $city. You will act as my tour guide. 
I am visiting the following places - $commaSeparatedPlaces. Do not change the order of the places.
Talk about the history of the place, current affairs, architecture and things to do/see around here. 
All your responses should be in plain text, no markdowns, no formatting. 
Do not use special characters in your transcript. Do not use double quotes inside the json key value pairs. Use single quotes instead of double quotes wherever applies.
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
        """;
    String tlouPrompt = """
I am going for a last of us based walking tour named "$tourName" in $city. You will act as my tour guide.
You are a fan of the TV show the last of us. I am visiting the following places -  $commaSeparatedPlaces .
Generate a fan lore for me on what happened to these places after the outbreak in the last of us. 
There should be a plot to the lore. Includes characters and plot lines. Split it into sections.

Do not change the order of the places.
All your responses should be in plain text, no markdowns, no formatting. 
Do not use special characters in your transcript. Do not use double quotes inside the json key value pairs. Use single quotes instead of double quotes wherever applies.
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
      "question": <str> [the question posed about the place. make it about folklore],
      "options" : list<str> [4 options containing the possible answers to the question],
      "correctAnswer": <str> [one among a,b,c or d for the 4 options],
      "feedback": <str> [an explanation for selecting the correct answer. elaborate on the answer],
  }
  ]
...[generate same format for all places]
"outro": <str> [an outro for the tour. At the end of the outro, ask them to rate the app in google play and consider donating to support], 
}
Do not write any additional details. Make sure the JSON is valid.


""";
    if (type == "The usual") {
      return usualPrompt;
    }
    return tlouPrompt;
  }
}
