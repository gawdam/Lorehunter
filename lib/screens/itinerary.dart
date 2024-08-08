import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorehunter/models/tour_details.dart';
import 'package:lorehunter/widgets/routes.dart';
import 'package:lorehunter/widgets/tour_panel_slide_up.dart';
import 'package:lorehunter/widgets/tour_panel_slide_up.dart';

class ItineraryPage extends ConsumerStatefulWidget {
  const ItineraryPage({super.key, required this.tour});
  final Tour tour;

  @override
  ConsumerState<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends ConsumerState<ItineraryPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        // appBar: AppBar(),
        body: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          child: Stack(
            children: [
              Container(
                  width: MediaQuery.sizeOf(context).width * 1,
                  height: MediaQuery.sizeOf(context).height * 1 - 190,
                  child: Routes(
                    tour: widget.tour,
                  )),
              Positioned(
                top: 50.0, // Adjust position as needed
                left: 20.0, // Adjust position as needed
                child: FloatingActionButton.small(
                  backgroundColor: Colors.white,
                  onPressed: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back),
                ),
              ),
              Positioned(
                  bottom: 0,
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  child: TourPanelStateless()),
            ],
          ),
        ),
      ),
    );
  }
}
