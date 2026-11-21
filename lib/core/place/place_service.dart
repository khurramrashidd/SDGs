import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'place.dart';
import 'weather.dart';

/// Finds where the user is and what the weather is doing there.
///
/// Two ways in, in this order:
///
///  1. The place the user picked themselves. Once chosen it is never
///     replaced by a guess, because a person in a village whose mobile
///     network reports the nearest city knows better than the network does.
///  2. A best-effort guess from the network address, which needs no
///     permission, no native package and no manifest edit. It is accurate to
///     roughly the town or district, which is all a weather reading needs.
///
/// Satellite location (GPS) is not used yet: the package for it needs a
/// newer Flutter than this project is pinned to, and a wrong guess here
/// costs nothing that the manual picker cannot fix.
///
/// Weather comes from Open-Meteo, which is free and needs no key. The last
/// reading is kept on the phone, so the header still shows something useful
/// with no network.
class PlaceService extends ChangeNotifier {
  static const _forecastKey = 'forecast_v1';

  Place? _place;
  Forecast? _forecast;
  bool _loading = false;
  bool _failed = false;

  Place? get place => _place;
  Forecast? get forecast => _forecast;
  WeatherNow? get now => _forecast?.now;
  bool get loading => _loading;

  /// True when we tried and could not get a place or a reading. The header
  /// then offers "Set your place" rather than showing nothing.
  bool get failed => _failed;

  bool get isStale => _forecast?.isStale ?? true;

  HeatRisk get heat =>
      now == null ? HeatRisk.none : heatRisk(now!.feelsLikeC);

  /// Loads what is on the phone, then refreshes in the background.
  Future<void> start() async {
    _place = await PlaceStore.load();
    _forecast = await _loadForecast();
    if (_place != null || _forecast != null) notifyListeners();
    await refresh();
  }

  Future<void> refresh({bool force = false}) async {
    if (_loading) return;
    if (!force && _place != null && _forecast != null && !isStale) return;
    _loading = true;
    _failed = false;
    notifyListeners();

    try {
      var place = _place;
      // Only guess when the user has not chosen a place themselves.
      if (place == null || !place.chosen) {
        place = await _guessPlace() ?? place;
      }
      if (place != null) {
        _place = place;
        await PlaceStore.save(place);
        final f = await _fetchWeather(place);
        if (f != null) {
          _forecast = f;
          await _saveForecast(f);
        }
      }
      _failed = _place == null;
    } catch (_) {
      _failed = _forecast == null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Sets the place the user picked. Marked chosen, so no later guess
  /// overwrites it.
  Future<void> setPlace(Place place) async {
    _place = Place(
      name: place.name,
      region: place.region,
      lat: place.lat,
      lon: place.lon,
      chosen: true,
    );
    await PlaceStore.save(_place!);
    notifyListeners();
    await refresh(force: true);
  }

  Future<void> clearPlace() async {
    await PlaceStore.clear();
    _place = null;
    notifyListeners();
    await refresh(force: true);
  }

  // ---- network ----------------------------------------------------------

  /// Town or district from the network address. No coordinates are sent:
  /// the service reads the address the request arrives from, the way any
  /// website does.
  Future<Place?> _guessPlace() async {
    final uri = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client'
        '?localityLanguage=en');
    final res = await http.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) return null;
    final m = jsonDecode(res.body);
    if (m is! Map) return null;
    final lat = m['latitude'], lon = m['longitude'];
    if (lat is! num || lon is! num) return null;
    final name = '${m['city'] ?? ''}'.trim().isNotEmpty
        ? '${m['city']}'
        : '${m['locality'] ?? ''}';
    if (name.trim().isEmpty) return null;
    return Place(
      name: name.trim(),
      region: '${m['principalSubdivision'] ?? ''}'.trim(),
      lat: lat.toDouble(),
      lon: lon.toDouble(),
    );
  }

  /// Towns matching what the user typed. Used by the place picker.
  static Future<List<Place>> searchTowns(String query) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    final uri = Uri.parse('https://geocoding-api.open-meteo.com/v1/search'
        '?name=${Uri.encodeQueryComponent(q)}&count=10&language=en');
    final res = await http.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) return const [];
    final body = jsonDecode(res.body);
    if (body is! Map || body['results'] is! List) return const [];
    // Indian results first: this app is for India, so a search for "Siwan"
    // must not open with a town somewhere else.
    final indian = <Place>[], rest = <Place>[];
    for (final r in body['results'] as List) {
      if (r is! Map) continue;
      final lat = r['latitude'], lon = r['longitude'];
      if (lat is! num || lon is! num) continue;
      final name = '${r['name'] ?? ''}'.trim();
      if (name.isEmpty) continue;
      final inIndia = '${r['country_code'] ?? ''}' == 'IN';
      final region = [
        '${r['admin2'] ?? ''}',
        '${r['admin1'] ?? ''}',
        if (!inIndia) '${r['country'] ?? ''}',
      ].where((s) => s.trim().isNotEmpty).join(', ');
      final place = Place(
        name: name,
        region: region,
        lat: lat.toDouble(),
        lon: lon.toDouble(),
      );
      (inIndia ? indian : rest).add(place);
    }
    return [...indian, ...rest];
  }

  Future<Forecast?> _fetchWeather(Place p) async {
    final uri = Uri.parse('https://api.open-meteo.com/v1/forecast'
        '?latitude=${p.lat.toStringAsFixed(4)}'
        '&longitude=${p.lon.toStringAsFixed(4)}'
        '&current=temperature_2m,apparent_temperature,relative_humidity_2m,'
        'weather_code,is_day,wind_speed_10m'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
        'precipitation_probability_max,precipitation_sum,wind_gusts_10m_max'
        '&forecast_days=4&timezone=auto');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) return null;
    final body = jsonDecode(res.body);
    if (body is! Map) return null;

    final c = body['current'];
    if (c is! Map || c['temperature_2m'] is! num) return null;
    double n(Object? v) => v is num ? v.toDouble() : 0;
    int i(Object? v) => v is num ? v.toInt() : 0;

    final now = WeatherNow(
      tempC: n(c['temperature_2m']),
      feelsLikeC: c['apparent_temperature'] is num
          ? n(c['apparent_temperature'])
          : n(c['temperature_2m']),
      code: i(c['weather_code']),
      isDay: i(c['is_day']) == 1,
      humidity: i(c['relative_humidity_2m']),
      windKph: n(c['wind_speed_10m']),
    );

    final days = <WeatherDay>[];
    final d = body['daily'];
    if (d is Map && d['time'] is List) {
      final times = d['time'] as List;
      List at(String key) => d[key] is List ? d[key] as List : const [];
      final codes = at('weather_code');
      final maxs = at('temperature_2m_max');
      final mins = at('temperature_2m_min');
      final rains = at('precipitation_probability_max');
      final mms = at('precipitation_sum');
      final gusts = at('wind_gusts_10m_max');
      double? maybe(List l, int k) =>
          k < l.length && l[k] is num ? (l[k] as num).toDouble() : null;
      for (var k = 0; k < times.length && k < 4; k++) {
        final date = DateTime.tryParse('${times[k]}');
        if (date == null) continue;
        days.add(WeatherDay(
          date: date,
          maxC: k < maxs.length ? n(maxs[k]) : 0,
          minC: k < mins.length ? n(mins[k]) : 0,
          code: k < codes.length ? i(codes[k]) : 0,
          rainChance: k < rains.length ? i(rains[k]) : 0,
          rainMm: maybe(mms, k),
          gustKph: maybe(gusts, k),
        ));
      }
    }
    return Forecast(now: now, days: days, fetchedAt: DateTime.now());
  }

  // ---- cache ------------------------------------------------------------

  Future<Forecast?> _loadForecast() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_forecastKey);
    if (raw == null) return null;
    try {
      return Forecast.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveForecast(Forecast f) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_forecastKey, jsonEncode(f.toJson()));
  }
}
