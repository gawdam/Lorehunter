import 'dart:ui';

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

String getNameFromFlag(String countryCode) {
  String flag = countryCode.replaceAllMapped(RegExp(r'[A-Z]'),
      (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
  return flag;
}

class LocationPicker extends ConsumerStatefulWidget {
  LocationPicker({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // TODO: implement createState
    return LoacationPickerState();
  }
}

class LoacationPickerState extends ConsumerState<LocationPicker> {
  TextEditingController textController = TextEditingController();

  SearchController countryController = SearchController();

  @override
  Widget build(BuildContext context) {
    final countries = ref.watch(countryListProvider);
    final cities = ref.watch(cityListProvider);

    final selectedCountry = ref.watch(selectedCountryProvider);

    List<String> countriesWithFlags = [];
    countries.forEach((element) {
      final entry = "${element.countryName} ${getFlag(element.countryCode)}";
      if (!countriesWithFlags.contains(entry)) {
        countriesWithFlags.add(entry);
      }
    });

    return Container(
      width: MediaQuery.sizeOf(context).width * 0.9,
      height: 43,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              // color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(36, 155, 39, 176)!,
                  blurRadius: 10,
                ),
              ],
            ),
            child: DropdownSearch<String>(
              dropdownButtonProps: const DropdownButtonProps(
                  icon: Icon(
                Icons.arrow_drop_down_sharp,
                size: 25,
              )),
              dropdownDecoratorProps: DropDownDecoratorProps(
                textAlign: TextAlign.right,
                dropdownSearchDecoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide: BorderSide(
                        color: Colors.grey[500]!,
                        width: 1,
                      )),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide: BorderSide(
                        color: Colors.grey[500]!,
                        width: 2,
                      )),
                  filled: true,
                  fillColor: Colors.grey[300]!,
                  contentPadding: EdgeInsets.only(
                      bottom: 10.0, left: 10.0, right: 10.0, top: 5),
                ),
              ),
              // dropdownDecoratorProps: DropDownDecoratorProps(
              //     dropdownSearchDecoration:
              //         InputDecoration(fillColor: Colors.grey[100])),
              // dropdownBuilder: (context, selectedItem) => Text("hello"),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                showSelectedItems: true,
                searchDelay: Duration.zero,
                fit: FlexFit.tight,

                listViewProps: ListViewProps(),
                menuProps: MenuProps(
                  elevation: 10,
                  backgroundColor: Colors.grey[200],
                ),

                // favoriteItemProps: FavoriteItemProps(),
                // scrollbarProps: ScrollbarProps(
                //     thumbVisibility: false, trackVisibility: false),
                searchFieldProps: TextFieldProps(
                    selectionHeightStyle: BoxHeightStyle.tight,
                    cursorHeight: 16,
                    strutStyle: StrutStyle(height: 1),
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 16, height: 0.5, fontFamily: null),
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 20)),
                itemBuilder: (context, item, isSelected) => Column(
                  children: [
                    Text(
                      item,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Divider(),
                  ],
                ),
              ),
              items: countriesWithFlags,
              onChanged: (country) async {
                if (country != null) {
                  ref.read(selectedCountryProvider.notifier).state =
                      country.substring(0, country.length - 5);
                  // await Future.delayed(Duration(milliseconds: 200));
                }
              },
              onSaved: (country) async {
                if (country != null) {
                  ref.read(selectedCountryProvider.notifier).state =
                      country.substring(0, country.length - 5);
                  // await Future.delayed(Duration(milliseconds: 200));
                }
              },

              selectedItem: getFlag(countries
                      .where((element) =>
                          element.countryName == (selectedCountry ?? "France"))
                      .isEmpty
                  ? "FR"
                  : countries
                      .where((element) =>
                          element.countryName == (selectedCountry ?? "France"))
                      .first
                      .countryCode),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          SearchAnchor(viewOnChanged: (city) {
            print("troubleshootviewOnChanged-" + city);
            ref.read(selectedCityProvider.notifier).state = city;
          }, viewOnSubmitted: (city) {
            print("troubleshootviewOnSubmitted-" + city);
            ref.read(selectedCityProvider.notifier).state = city;
          }, builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              textStyle: MaterialStateProperty.resolveWith(
                  (states) => TextStyle(fontFamily: null)),
              overlayColor:
                  MaterialStateColor.resolveWith((states) => Colors.purple),
              elevation: MaterialStateProperty.resolveWith((states) => 10),
              shadowColor: MaterialStateColor.resolveWith(
                  (states) => Color.fromARGB(36, 155, 39, 176)!),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      side: BorderSide(color: Colors.grey[500]!, width: 1))),
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                return Colors.grey[100];
              }),
              hintText: "City",
              controller: controller,
              onChanged: (value) {
                print("troubleshootonChanged-" + value);
                ref.read(selectedCityProvider.notifier).state = value;
              },
              onSubmitted: (value) {
                print("troubleshootonSubmitted-" + value);
                ref.read(selectedCityProvider.notifier).state = value;
              },
              onTap: () {
                controller.openView();
              },
              leading: const Icon(Icons.location_on_outlined),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.85 - 5 - 80,
                  minHeight: 40),
            );
          }, suggestionsBuilder:
              (BuildContext context, SearchController controller) {
            List<String> filteredCities = [];
            cities.forEach((element) {
              if (element.cityName
                  .toLowerCase()
                  .contains(controller.text.toLowerCase())) {
                filteredCities.add(element.cityName);
              }
            });
            return List<ListTile>.generate(filteredCities.length, (int index) {
              final String item = filteredCities[index];
              return ListTile(
                title: Text(
                  item,
                  style: TextStyle(fontFamily: null),
                ),
                onTap: () {
                  ref.read(selectedCityProvider.notifier).state = item;
                  print("troubleshoot Item sent - " + item);
                  controller.closeView(item);
                },
              );
            });
          }),
        ],
      ),
    );
  }
}
