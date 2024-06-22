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

    Widget _style(BuildContext context, String? selectedItem) {
      return Text(
        selectedItem!,
        style: TextStyle(fontFamily: 'MeQuran2'),
      );
    }

    Widget _style1(BuildContext context, String? item, bool isSelected) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            item!,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'MeQuran2',
                color: isSelected ? Colors.cyanAccent : null),
          ),
        ),
      );
    }

    return Container(
      width: MediaQuery.sizeOf(context).width * 0.9,
      height: 85,
      child: Row(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width * 0.17,
            height: 35,
            child: DropdownSearch<String>(
              dropdownButtonProps: DropdownButtonProps(
                  icon: Icon(
                Icons.location_on_outlined,
                size: 14,
              )),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                showSelectedItems: true,
                searchDelay: Duration.zero,
                listViewProps: ListViewProps(),
                // favoriteItemProps: FavoriteItemProps(),
                searchFieldProps: TextFieldProps(
                    strutStyle: StrutStyle(),
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10),
                    padding: EdgeInsets.all(5)),
                itemBuilder: (context, item, isSelected) => Column(
                  children: [
                    Text(
                      item,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Divider(),
                  ],
                ),
              ),
              items: countriesWithFlags,

              // dropdownDecoratorProps: DropDownDecoratorProps(
              //   dropdownSearchDecoration:
              //       InputDecoration(labelStyle: TextStyle(fontSize: 12)
              //           // labelText: "Menu mode",
              //           // hintText: "country in menu mode",
              //           ),
              // ),
              onChanged: (country) => country == null
                  ? null
                  : ref.read(selectedCountryProvider.notifier).state = country,
              selectedItem: selectedFlag.substring(0, 4),
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
          SearchBar(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.7 - 10,
                minHeight: 40),
          ),
          // Container(
          //   width: MediaQuery.sizeOf(context).width * 0.7,
          //   child: DropdownWithSearch(
          //     title: "City",
          //     placeHolder: "Select city",
          //     items: cities,
          //     onChanged: (city) => city == null
          //         ? null
          //         : ref.read(selectedCityProvider.notifier).state = city,
          //     selected: selectedCity,
          //     label: selectedCity ?? "None",
          //   ),
          // ),
        ],
      ),
    );
  }
}
