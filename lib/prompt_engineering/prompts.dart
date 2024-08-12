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

Do not write any additional details. Make sure the JSON is valid.


""";
    if (type == "The usual") {
      return usualPrompt;
    }
    return tlouPrompt;
  }
}

class TourPrompts {
  TourPrompts({required this.city});
  final city;

  String getPrompt() {
    final prompt = """
Generate a walking tour for me in the city of $city.
All places must within 5km radius of each other. 
All your responses should be in plain text, no markdowns, no formatting.

Do not write any additional details. Make sure the JSON is valid
    """;
    return prompt;
  }
}
