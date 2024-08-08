class CityCountry {
  final String cityName;
  final String countryName;
  final String countryCode;
  final String lat;
  final String lng;
  final String lore;

  CityCountry(this.cityName, this.countryName, this.countryCode, this.lat,
      this.lng, this.lore);

  factory CityCountry.fromJson(String countryName, String countryCode,
      String lore, Map<String, dynamic> json) {
    return CityCountry(json['name'] as String, countryName, countryCode,
        json['lat'] as String, json['lng'] as String, lore);
  }
}
