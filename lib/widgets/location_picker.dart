import 'package:country_flags/country_flags.dart';
import 'package:csc_picker/dropdown_with_search.dart';
import 'package:csc_picker/model/select_status_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorehunter/providers/location_provider.dart';

String getFlag(String countryCode) {
  String flag = countryCode.replaceAllMapped(RegExp(r'[A-Z]'),
      (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));

  return flag;
}

class LocationPicker extends ConsumerWidget {
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countries = ref.watch(countryListProvider);
    final cities = ref.watch(cityListProvider);

    final selectedCountry = ref.watch(selectedCountryProvider);
    final selectedCity = ref.watch(selectedCityProvider);

    String selectedFlag = getFlag(selectedCountry!);

    List<String> countriesWithFlags = [];
    countries.forEach((element) {
      countriesWithFlags.add("$element ${getFlag(element)}");
    });

    return Container(
      width: MediaQuery.sizeOf(context).width * 0.75,
      height: 55,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 35,
            color: Colors.grey[100],
            child: DropdownSearch<String>(
              dropdownButtonProps: DropdownButtonProps(
                  icon: Icon(
                null,
                size: 14,
              )),
              // dropdownDecoratorProps: DropDownDecoratorProps(
              //     dropdownSearchDecoration:
              //         InputDecoration(fillColor: Colors.grey[100])),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                showSelectedItems: true,
                searchDelay: Duration.zero,
                listViewProps: ListViewProps(),
                // favoriteItemProps: FavoriteItemProps(),
                // scrollbarProps: ScrollbarProps(
                //     thumbVisibility: false, trackVisibility: false),
                searchFieldProps: TextFieldProps(
                    strutStyle: StrutStyle(),
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, height: 1),
                    padding: EdgeInsets.all(5)),
                itemBuilder: (context, item, isSelected) => Column(
                  children: [
                    Text(
                      item,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Divider(),
                  ],
                ),
              ),
              items: countriesWithFlags,
              onChanged: (country) {
                if (country != null) {
                  ref.read(selectedCountryProvider.notifier).state =
                      country.substring(0, 2);
                }
              },
              selectedItem: getFlag(selectedCountry),
            ),

            // DropdownWithSearch(
            //   title: "Country",
            //   placeHolder: "Select country",
            //   items: countriesWithFlags,
            // onChanged: (country) => country == null
            //     ? null
            //     : ref.read(selectedCountryProvider.notifier).state = country,
            //   selected: selectedCountry,
            //   label: "HELLO" ?? "None",
            //   itemStyle: TextStyle(fontSize: 14),
            //   selectedItemStyle: TextStyle(fontSize: 12),
            // ),
          ),
          SizedBox(
            width: 10,
          ),
          SearchAnchor(
              viewBackgroundColor: Colors.grey[100],
              viewOnSubmitted: (city) {
                ref.read(selectedCityProvider.notifier).state = city;
                print(city);
              },
              builder: (BuildContext context, SearchController controller) {
                // controller.text = selectedCity!;

                // print(controller.value.text);
                // controller.text ??= "Amsterdam";
                return SearchBar(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    // If the button is pressed, return green, otherwise blue

                    return Colors.grey[100];
                  }),
                  hintText: "City",
                  controller: controller,
                  onSubmitted: (value) {
                    print(value);
                    ref.read(selectedCityProvider.notifier).state = value;
                  },
                  onTap: () {
                    controller.openView();
                    print("TAPPED");
                  },
                  leading: const Icon(Icons.location_on_outlined),
                  constraints: BoxConstraints(
                      maxWidth:
                          MediaQuery.sizeOf(context).width * 0.75 - 48 - 10,
                      minHeight: 40),
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                List<String> filteredCities = [];
                cities.forEach((element) {
                  if (element
                      .toLowerCase()
                      .contains(controller.text.toLowerCase())) {
                    filteredCities.add(element);
                  }
                });
                return List<ListTile>.generate(filteredCities.length,
                    (int index) {
                  final String item = filteredCities[index];
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      controller.closeView(item);
                    },
                  );
                });
              }),

          // Container(
          //   width: MediaQuery.sizeOf(context).width * 0.7,
          //   child: DropdownWithSearch(
          //     title: "City",
          //     placeHolder: "Select city",
          //     items: cities,

          //     selected: selectedCity,
          //     label: selectedCity ?? "None",
          //   ),
          // ),
        ],
      ),
    );
  }
}
