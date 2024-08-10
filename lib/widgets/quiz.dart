import 'package:flutter/material.dart';
import 'package:lorehunter/models/audio_tour_transcript.dart';

class Quiz extends StatefulWidget {
  final Trivia trivia;

  const Quiz({super.key, required this.trivia});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  int selectedOption = -1;
  bool isAnswered = false;
  Map<String, int> optionMap = {'a': 0, 'b': 1, 'c': 2, 'd': 3};
  int? correctAnswer;
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    correctAnswer = optionMap[widget.trivia.correctAnswer];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 228, 213, 231),
      alignment: Alignment.center,
      height: MediaQuery.sizeOf(context).height * 0.6,
      width: MediaQuery.sizeOf(context).width * 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            width: MediaQuery.sizeOf(context).width * 0.7,
            child: Text(
              widget.trivia.question,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            children: widget.trivia.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return Flex(
                direction: Axis.vertical,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.7,
                    child: ElevatedButton(
                      onPressed: isAnswered
                          ? null
                          : () {
                              setState(() {
                                selectedOption = index;
                                isAnswered = true;
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: isAnswered
                            ? (selectedOption == index &&
                                    selectedOption == correctAnswer)
                                ? Colors.green[300]!
                                : (selectedOption == index)
                                    ? Colors.red[300]!
                                    : (index == correctAnswer)
                                        ? Colors.green[300]
                                        : Colors.purple[100]
                            : Colors.purple[100],
                        disabledForegroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        side: BorderSide(
                          width: 2,
                          color: isAnswered
                              ? (selectedOption == index &&
                                      selectedOption == correctAnswer)
                                  ? Colors.green[700]!
                                  : (selectedOption == index)
                                      ? Colors.red[700]!
                                      : (index == correctAnswer)
                                          ? Colors.green[700]!
                                          : Colors.purple!
                              : Colors.purple,
                        ),
                        elevation: 5,
                        backgroundColor: isAnswered
                            ? (selectedOption == index &&
                                    selectedOption == correctAnswer)
                                ? Colors.green[700]!
                                : (selectedOption == index)
                                    ? Colors.red[700]!
                                    : Colors.purple[100]
                            : Colors.purple[100],
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          SizedBox(
            height: 20,
          ),
          if (isAnswered)
            Container(
              width: MediaQuery.sizeOf(context).width * 0.7,
              child: Text(
                selectedOption == correctAnswer
                    ? 'You\'re absolutely right! ${widget.trivia.feedback} '
                    : 'Incorrect answer. ${widget.trivia.feedback} ',
                style: TextStyle(fontSize: 14),
              ),
            ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
