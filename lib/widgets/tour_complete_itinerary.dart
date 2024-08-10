import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lorehunter/models/tour_details.dart';

List<List<String>> splitList(List<String> strings) {
  final oddStrings = <String>[];
  final evenStrings = <String>[];

  for (var i = 0; i < strings.length; i++) {
    if (i.isEven) {
      evenStrings.add(strings[i]);
    } else {
      oddStrings.add(strings[i]);
    }
  }

  return [oddStrings, evenStrings];
}

class TourCompleteItinerary extends StatelessWidget {
  Tour tour;
  TourCompleteItinerary({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      color: const Color.fromARGB(255, 225, 210, 228),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            tour.name,
            style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 135, 53, 150),
                fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: screenSize.width * 0.4,
                height: screenSize.height * 0.6,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 10),
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: splitList(tour.updatedPlaces!)[0].length,
                    itemBuilder: (context, index) {
                      final oddPlaces = splitList(tour.updatedPlaces!)[0];
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: screenSize.width * 0.3,
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: screenSize.width * 0.3,
                                      height: screenSize.width * 0.2,

                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.all(5),
                                      child: Container(
                                        height: screenSize.width * 0.15,
                                        width: screenSize.width * 0.25,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors
                                                .black, // Set the border color to black
                                            width: 2.0, // Set the border width
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.camera_alt_outlined,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      oddPlaces[index],
                                      style: TextStyle(fontSize: 10),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    )
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Container(
                                    height: 2,
                                    width: screenSize.width * 0.1,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      );
                    }),
              ),
              Container(
                // alignment: Alignment.b,
                padding:
                    EdgeInsets.only(bottom: tour.updatedPlaces!.length * 20),
                width: 2,
                height: 70.0 * tour.updatedPlaces!.length,
                color: Colors.black,
              ),
              Container(
                width: screenSize.width * 0.4,
                height: screenSize.height * 0.6,
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 10),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: splitList(tour.updatedPlaces!)[1].length,
                    itemBuilder: (context, index) {
                      final evenPlaces = splitList(tour.updatedPlaces!)[1];
                      return Column(
                        children: [
                          SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Container(
                                    height: 2,
                                    width: screenSize.width * 0.1,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                              Container(
                                width: screenSize.width * 0.3,
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: screenSize.width * 0.3,
                                      height: screenSize.width * 0.2,

                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.all(5),
                                      child: Container(
                                        height: screenSize.width * 0.15,
                                        width: screenSize.width * 0.25,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors
                                                .black, // Set the border color to black
                                            width: 2.0, // Set the border width
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.camera_alt_outlined,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      evenPlaces[index],
                                      style: TextStyle(fontSize: 10),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
