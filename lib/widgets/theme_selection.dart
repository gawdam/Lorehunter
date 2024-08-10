import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorehunter/providers/tour_provider.dart';

class ThemeSelectionDialog extends ConsumerStatefulWidget {
  final String? initialTheme;
  final String? initialVoice;

  const ThemeSelectionDialog({
    Key? key,
    this.initialTheme,
    this.initialVoice,
  }) : super(key: key);

  @override
  _ThemeSelectionDialogState createState() => _ThemeSelectionDialogState();
}

class _ThemeSelectionDialogState extends ConsumerState<ThemeSelectionDialog> {
  String? selectedTheme;
  String? selectedVoice;

  @override
  void initState() {
    super.initState();
    selectedTheme = widget.initialTheme;
    selectedVoice = widget.initialVoice;
  }

  @override
  Widget build(BuildContext context) {
    final tour = ref.watch(tourProvider);
    return AlertDialog(
      title: const Text(
        'Settings',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Theme',
                style: TextStyle(fontSize: 16),
              ),
              DropdownButton<String>(
                value: selectedTheme,
                items: const [
                  DropdownMenuItem(
                    value: 'The last of us',
                    child: Text(
                      'The last of us',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'The usual',
                    child: Text(
                      'The usual',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedTheme = value;
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Voice',
                style: TextStyle(fontSize: 16),
              ),
              DropdownButton<String>(
                value: selectedVoice,
                items: const [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text(
                      'Bob (male)',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text(
                      'Eve (female)',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedVoice = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            ref.invalidate(tourProvider);
            tour!.theme = selectedTheme;
            tour!.voice = selectedVoice;
            ref.read(tourProvider.notifier).state = tour;
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
