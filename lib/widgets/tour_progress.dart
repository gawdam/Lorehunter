import 'package:flutter/material.dart';

class TourProgress extends StatelessWidget {
  final int currentPosition;
  final int totalPlaces;

  const TourProgress(
      {super.key, required this.currentPosition, required this.totalPlaces});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        alignment: Alignment.center,
        height: 24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(totalPlaces, (index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                index != 0
                    ? Container(
                        height: 5,
                        width: MediaQuery.sizeOf(context).width *
                            0.7 /
                            (totalPlaces + 1),
                        color: index < currentPosition
                            ? Colors.purple
                            : Color.fromARGB(255, 166, 122, 174),
                      )
                    : Container(),
                CircleAvatar(
                  foregroundColor: index < currentPosition
                      ? Colors.purple
                      : Colors.transparent,
                  radius: 12,
                  backgroundColor: Colors.purple,
                  child: index < currentPosition
                      ? Icon(
                          Icons.flag,
                          color: Colors.white,
                          size: 12,
                        )
                      : CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.grey[200],
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
