import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TourProgress extends StatelessWidget {
  final int currentPosition;
  final int totalPlaces;
  final Function onPressed;
  final List<String> places;

  const TourProgress({
    super.key,
    required this.currentPosition,
    required this.totalPlaces,
    required this.onPressed,
    required this.places,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        alignment: Alignment.center,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(totalPlaces, (index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                index != 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.topCenter,
                            height: 5,
                            width: MediaQuery.sizeOf(context).width *
                                0.7 /
                                (totalPlaces + 1),
                            color: index < currentPosition
                                ? Colors.purple
                                : Color.fromARGB(255, 166, 122, 174),
                            padding: EdgeInsets.symmetric(vertical: 40),
                          ),
                          Container(
                            height: 22,
                          )
                        ],
                      )
                    : Container(),
                GestureDetector(
                  onTap: () {
                    onPressed(index);
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        foregroundColor: index < currentPosition
                            ? Colors.purple
                            : Colors.transparent,
                        radius: 14,
                        backgroundColor: Colors.purple,
                        child: index < currentPosition
                            ? Icon(
                                Icons.flag,
                                color: Colors.white,
                                size: 14,
                              )
                            : CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.grey[200],
                              ),
                      ),
                      Container(
                        height: 20,
                        child: Text("${(index + 1).toString()}"),
                      )
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
