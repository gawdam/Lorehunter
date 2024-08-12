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

  return [evenStrings, oddStrings];
}

class TourCompleteItinerary extends StatelessWidget {
  Tour tour;
  Size? staticScreenSize;
  TourCompleteItinerary({super.key, required this.tour, this.staticScreenSize});

  @override
  Widget build(BuildContext context) {
    final screenSize = staticScreenSize ?? MediaQuery.of(context).size;
    return Container(
      color: const Color.fromARGB(255, 240, 240, 240),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            width: screenSize.width * 0.8,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2)),
            child: Text(
              tour.name,
              style: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 115, 28, 131),
                  fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: screenSize.width * 0.4,
                height: screenSize.height * 0.48,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 10),
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: splitList(tour.updatedPlaces!)[0].length,
                    itemBuilder: (context, index) {
                      final oddPlaceList = splitList(tour.updatedPlaces!)[0];
                      final List<PlaceDetails> oddPlaces =
                          List.from(oddPlaceList.map(
                        (e) => tour.places
                            .firstWhere((element) => element.name == e),
                      ));
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
                                        child: oddPlaces[index].imageURL != null
                                            ? Image.network(
                                                oddPlaces[index].imageURL!,
                                                scale: 2,
                                                fit: BoxFit.cover,
                                              )
                                            : Icon(
                                                Icons.camera_alt_outlined,
                                                size: 50,
                                              ),
                                      ),
                                    ),
                                    Text(
                                      oddPlaces[index].name,
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
                            height: 30,
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
                height: screenSize.height * 0.48,
                color: Colors.black,
              ),
              Container(
                width: screenSize.width * 0.4,
                height: screenSize.height * 0.48,
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 10),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: splitList(tour.updatedPlaces!)[1].length,
                    itemBuilder: (context, index) {
                      final evenPlaceList = splitList(tour.updatedPlaces!)[1];
                      final List<PlaceDetails> evenPlaces =
                          List.from(evenPlaceList.map(
                        (e) => tour.places
                            .firstWhere((element) => element.name == e),
                      ));
                      return Column(
                        children: [
                          SizedBox(
                            height: 30,
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
                                        child:
                                            evenPlaces[index].imageURL != null
                                                ? Image.network(
                                                    evenPlaces[index].imageURL!,
                                                    scale: 2,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 50,
                                                  ),
                                      ),
                                    ),
                                    Text(
                                      evenPlaces[index].name,
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
          Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2)),
            child: Container(
              height: screenSize.height * 0.1 - 16,
              width: screenSize.width * 0.8,

              // color: const Color.fromARGB(255, 255, 255, 255),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_walk_rounded),
                        Text(
                          "Distance",
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          "${((tour.distance ?? 0) / 100).round() / 10} km",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fastfood),
                        Text(
                          "Calories burnt",
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "${((((tour.distance ?? 0) / 100).round() / 10) * 100).round()} kcal",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/quiz_icon.png",
                          scale: 3.5,
                        ),
                        Text(
                          "Trivia score",
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "60%",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 7,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Made using",
                  style: TextStyle(fontSize: 9),
                ),
                SizedBox(
                  width: 5,
                ),
                Image.asset(
                  "assets/images/lorehunter.png",
                  scale: 10,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
