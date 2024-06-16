import 'package:flutter/material.dart';

class ItineraryCard extends StatelessWidget {
  final String imageUrl;
  final List<Map<String, String>> gridItems;

  const ItineraryCard(
      {Key? key, required this.imageUrl, required this.gridItems})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 200, // Adjust image height as needed
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: gridItems.map((item) => _buildGridCell(item)).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGridCell(Map<String, String> item) {
    return Column(
      children: [
        Icon(
          IconData(int.parse(item['iconCode']!), fontFamily: 'MaterialIcons'),
          size: 24.0,
        ),
        Text(item['text']!),
      ],
    );
  }
}
