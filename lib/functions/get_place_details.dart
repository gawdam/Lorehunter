import 'package:lorehunter/interns/audio_guide_intern.dart';
import 'package:lorehunter/models/place_details.dart';
import 'package:lorehunter/providers/place_details_provider.dart';

Future<List<PlaceDetails>> getPlaceDetails(List<String> places) async {
  AudioGuide audioGuide = AudioGuide(theme: "The last of us tv series");
  await audioGuide.initAI();
  List<PlaceDetails> listOfPlaceDetails = [];
  for (String place in places) {
    var response = await audioGuide.gemini(place);
    PlaceDetails placeDetails = await getPlaceDetailsFromJson(response);
    listOfPlaceDetails.add(placeDetails);
  }

  return listOfPlaceDetails;
}
