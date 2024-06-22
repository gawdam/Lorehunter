import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:lorehunter/providers/location_provider.dart';
import 'package:lorehunter/routes/geocoding.dart';
import 'package:lorehunter/routes/routes.dart';
import 'package:lorehunter/widgets/itinerary.dart';
import 'package:lorehunter/widgets/location_picker.dart';

ChatSession? chatBot;
Future<String> gemini(String prompt) async {
  final content = Content.text(prompt);
  final response = await chatBot!.sendMessage(content);

  return (response.text!);
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  String chatHistory = "";
  String apiKey = '';
  late GenerativeModel model;
  List<String>? places;

  String? cityValue = "";

  Future<void> initAI() async {
    await dotenv.load(fileName: ".env");

    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: dotenv.env['gemini_api_key']!,
    );
    await initSession();
  }

  Future<void> initSession() async {
    chatBot = model.startChat();
    final response =
        await chatBot!.sendMessage(Content.text("""You are a tour guide. 
        I will type the location that I'm in and you will generate a walking tour of that location for me.
        There should be a total of 3 places.
        All places must within a 5km radius. 
        The order of locations should be chained in such a way that the total distance is minimum.
        All your responses should be in plain text, no markdowns, no formatting.
        Your response should be of the following format- 
        Sample output:
        { 
          "places": list<str> [list of places]
          "distance": list<str> [distance between places]
          "total_time" : str [an estimate of total tour time in number of hours]
          "wiki_link": list<str> [https link of wikipedia page for each place]
          "best_experienced_at": str [best @ time of day, choose between morning, afternoon and evening]
        }
        Do not write any additional details. Make sure the JSON is valid
        """));
    // print(response.text);

    _textController.clear();
  }

  Future<void> sendMessage(String text) async {
    await initSession();
    _textController.clear();
    chatHistory = '';
    setState(() {
      chatHistory += "User: $text\n";
    });
    final response = jsonDecode(await gemini(text));
    setState(() {
      chatHistory = "${response['places']}\n";
      places = List<String>.from(response['places'] as List);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAI();
    // cityValue = ref.watch(selectedCityProvider);
  }

  @override
  Widget build(BuildContext context) {
    cityValue = ref.watch(selectedCityProvider);

    return ProviderScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat with AI"),
        ),
        body: Column(
          children: [
            LocationPicker(),
            places == null
                ? Container()
                : Container(
                    width: 300, height: 200, child: Routes(places: places!)),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                // child: SelectableText(
                //   chatHistory,
                //   style: TextStyle(fontSize: 16),
                // ),
              ),
            ),
            Builder(
              builder: (context) {
                if (places != null) {
                  return Itinerary(places: places!);
                }
                return Container();
              },
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration:
                          InputDecoration(hintText: "Type your message"),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.star),
                    onPressed: () => sendMessage(cityValue!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
