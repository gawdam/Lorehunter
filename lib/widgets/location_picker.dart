import 'package:csc_picker/dropdown_with_search.dart';
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
    final cities = ref.watch(cityListProvider);

    final selectedCountry = ref.watch(selectedCountryProvider);
    final selectedCity = ref.watch(selectedCityProvider);

    // print(countries);

    return Column(
      children: [
        DropdownWithSearch(
          title: "Country",
          placeHolder: "Select country",
          items: countries,
          onChanged: (country) => country == null
              ? null
              : ref.read(selectedCountryProvider.notifier).state = country,
          selected: selectedCountry,
          label: selectedCountry ?? "None",
        ),
        DropdownWithSearch(
          title: "City",
          placeHolder: "Select city",
          items: cities,
          onChanged: (city) => city == null
              ? null
              : ref.read(selectedCityProvider.notifier).state = city,
          selected: selectedCity,
          label: selectedCity ?? "None",
        ),
      ],
    );
  }
}
