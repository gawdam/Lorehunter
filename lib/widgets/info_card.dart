import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  InfoCard({super.key, required this.cardValues});

  List<String?> cardValues;
  Color color = Colors.white;

  Text formatText(String text) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: 16),
    );
  }

  Icon formatIcon(IconData icon) {
    return Icon(
      icon,
      size: 16,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.95,
      child: Card(
        elevation: 10,
        color: Colors.black.withOpacity(0.5),
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.2,
                  child: Column(
                    children: [
                      formatIcon(Icons.account_balance),
                      SizedBox(height: 5),
                      formatText(cardValues[0] ?? "-"),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2.0,
                    width: 2,
                    color: color,
                  ),
                ),
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.2,
                  child: Column(
                    children: [
                      formatIcon(Icons.access_time),
                      SizedBox(height: 5),
                      formatText(cardValues[1] ?? "-"),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2.0,
                    width: 2,
                    color: color,
                  ),
                ),
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.2,
                  child: Column(
                    children: [
                      formatIcon(Icons.directions_walk),
                      SizedBox(height: 5),
                      formatText(cardValues[2] ?? "-"),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2.0,
                    width: 2,
                    color: color,
                  ),
                ),
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.2,
                  child: Column(
                    children: [
                      formatIcon(Icons.sunny),
                      SizedBox(height: 5),
                      formatText(cardValues[3] ?? "-"),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
