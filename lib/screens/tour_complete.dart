import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/widgets/tour_complete_itinerary.dart';

class TourComplete extends StatelessWidget {
  final Tour tour;

  const TourComplete({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          color: const Color.fromARGB(255, 240, 240, 240),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Yaay! You've completed the tour!",
                    style: TextStyle(fontSize: 16),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Here's your tour report",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: screenSize.height * 0.65,
                width: screenSize.width * 0.9,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, // Set the border color to black
                    width: 2.0, // Set the border width
                  ),
                ),
                child: TourCompleteItinerary(
                  tour: tour,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
