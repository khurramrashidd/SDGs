import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Where the user is, as far as the app needs to know.
///
/// Only a name and a coordinate pair. Nothing here identifies a person, and
/// nothing is sent to our own server: the coordinate goes to the weather
/// service and nowhere else.
class Place {
  final String name; // "Siwan"
  final String region; // "Bihar"
  final double lat;
  final double lon;

  /// true when the user picked this themselves, which means the app must
  /// never silently replace it with a guess.
  final bool chosen;

  const Place({
    required this.name,
    required this.region,
    required this.lat,
    required this.lon,
    this.chosen = false,
  });

  String get label => region.isEmpty || region == name
      ? name
      : '$name, $region';

  Map<String, dynamic> toJson() => {
        'name': name,
        'region': region,
        'lat': lat,
        'lon': lon,
        'chosen': chosen,
      };

  static Place? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final lat = raw['lat'], lon = raw['lon'];
    if (lat is! num || lon is! num) return null;
    final name = '${raw['name'] ?? ''}';
    if (name.isEmpty) return null;
    return Place(
      name: name,
      region: '${raw['region'] ?? ''}',
      lat: lat.toDouble(),
      lon: lon.toDouble(),
      chosen: raw['chosen'] == true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Place &&
      other.name == name &&
      other.region == region &&
      (other.lat - lat).abs() < 0.0001 &&
      (other.lon - lon).abs() < 0.0001;

  @override
  int get hashCode => Object.hash(name, region, lat.round(), lon.round());
}

/// The place, kept on the phone between runs.
class PlaceStore {
  static const _key = 'place_v1';

  static Future<Place?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return Place.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(Place place) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(place.toJson()));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
