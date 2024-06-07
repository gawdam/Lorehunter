import 'package:csc_picker/model/select_status_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorehunter/providers/location_provider.dart';

class LocationPicker extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countries = ref.watch(countryListProvider);
    final cities = ref.watch(countryListProvider);

    final selectedCountry = ref.watch(selectedCountryProvider);

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedCountry,
          hint: Text("Select Country"),
          items: countries
              .map((country) => DropdownMenuItem(
                    value: country,
                    child: Text(country),
                  ))
              .toList(),
          onChanged: (country) =>
              ref.read(selectedCountryProvider.notifier).state = country,
        ),
        DropdownButtonFormField<String>(
          value: null, // No initial selection for city
          hint: Text("Select City"),
          items: cities
              .map((city) => DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  ))
              .toList(),
          onChanged: (city) => print(
              "Selected city: $city"), // Replace with your city selection logic
        ),
      ],
    );
  }
}
