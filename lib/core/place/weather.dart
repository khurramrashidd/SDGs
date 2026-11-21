/// Weather, as plain data and pure functions.
///
/// The app shows weather in the header of every goal, but it is not a
/// weather app: the point is that the same reading can change what a tool
/// says. A heat warning belongs on an outdoor-work screen (goal 8) and a
/// heat-illness screen (goal 13); a rain warning belongs on a food-sharing
/// screen (goal 2) and a crop screen (goal 13).
library;

/// WMO weather codes, which is what Open-Meteo returns.
/// Reference: Open-Meteo docs, "Weather variable documentation".
String weatherWord(int code, bool hi) {
  if (code == 0) return hi ? 'साफ़' : 'Clear';
  if (code <= 2) return hi ? 'कुछ बादल' : 'Part cloud';
  if (code == 3) return hi ? 'बादल' : 'Cloudy';
  if (code == 45 || code == 48) return hi ? 'कोहरा' : 'Fog';
  if (code >= 51 && code <= 57) return hi ? 'बूँदाबाँदी' : 'Drizzle';
  if (code >= 61 && code <= 67) return hi ? 'बारिश' : 'Rain';
  if (code >= 71 && code <= 77) return hi ? 'बर्फ़' : 'Snow';
  if (code >= 80 && code <= 82) return hi ? 'तेज़ बारिश' : 'Showers';
  if (code == 85 || code == 86) return hi ? 'बर्फ़बारी' : 'Snow showers';
  if (code >= 95) return hi ? 'आँधी-तूफ़ान' : 'Thunderstorm';
  return hi ? 'मौसम' : 'Weather';
}

/// A single-character stand-in for an icon, so the header stays legible on a
/// 320dp phone without shipping an icon font.
String weatherGlyph(int code, {bool day = true}) {
  if (code == 0) return day ? '☀' : '☾';
  if (code <= 2) return day ? '⛅' : '☁';
  if (code == 3) return '☁';
  if (code == 45 || code == 48) return '≈';
  if (code >= 51 && code <= 67) return '☂';
  if (code >= 71 && code <= 77) return '❄';
  if (code >= 80 && code <= 82) return '☔';
  if (code == 85 || code == 86) return '❄';
  if (code >= 95) return '⚡';
  return '•';
}

bool codeIsWet(int code) =>
    (code >= 51 && code <= 67) || (code >= 80 && code <= 82) || code >= 95;

bool codeIsStorm(int code) => code >= 95;

class WeatherNow {
  final double tempC;
  final double feelsLikeC;
  final int code;
  final bool isDay;
  final int humidity;
  final double windKph;

  const WeatherNow({
    required this.tempC,
    required this.feelsLikeC,
    required this.code,
    required this.isDay,
    required this.humidity,
    required this.windKph,
  });

  Map<String, dynamic> toJson() => {
        't': tempC,
        'f': feelsLikeC,
        'c': code,
        'd': isDay,
        'h': humidity,
        'w': windKph,
      };

  static WeatherNow? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final t = raw['t'];
    if (t is! num) return null;
    double n(Object? v) => v is num ? v.toDouble() : 0;
    return WeatherNow(
      tempC: t.toDouble(),
      feelsLikeC: n(raw['f']),
      code: raw['c'] is num ? (raw['c'] as num).toInt() : 0,
      isDay: raw['d'] != false,
      humidity: raw['h'] is num ? (raw['h'] as num).toInt() : 0,
      windKph: n(raw['w']),
    );
  }
}

class WeatherDay {
  final DateTime date;
  final double maxC;
  final double minC;
  final int code;

  /// Chance of rain in percent, as the forecast gives it for the whole day.
  final int rainChance;

  /// Total rain expected over the day, in millimetres. Null when the reading
  /// came from a cache written before this field existed - a tool must treat
  /// that as "not known", never as "no rain".
  final double? rainMm;

  /// Strongest gust expected over the day, km/h. Null when not known, for
  /// the same reason.
  final double? gustKph;

  const WeatherDay({
    required this.date,
    required this.maxC,
    required this.minC,
    required this.code,
    required this.rainChance,
    this.rainMm,
    this.gustKph,
  });

  Map<String, dynamic> toJson() => {
        'd': date.toIso8601String(),
        'x': maxC,
        'n': minC,
        'c': code,
        'r': rainChance,
        if (rainMm != null) 'p': rainMm,
        if (gustKph != null) 'g': gustKph,
      };

  static WeatherDay? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final d = DateTime.tryParse('${raw['d']}');
    if (d == null) return null;
    double n(Object? v) => v is num ? v.toDouble() : 0;
    return WeatherDay(
      date: d,
      maxC: n(raw['x']),
      minC: n(raw['n']),
      code: raw['c'] is num ? (raw['c'] as num).toInt() : 0,
      rainChance: raw['r'] is num ? (raw['r'] as num).toInt() : 0,
      rainMm: raw['p'] is num ? (raw['p'] as num).toDouble() : null,
      gustKph: raw['g'] is num ? (raw['g'] as num).toDouble() : null,
    );
  }
}

class Forecast {
  final WeatherNow now;
  final List<WeatherDay> days;
  final DateTime fetchedAt;

  const Forecast(
      {required this.now, required this.days, required this.fetchedAt});

  /// Older than this and the header shows it as a last-known reading.
  bool get isStale =>
      DateTime.now().difference(fetchedAt) > const Duration(hours: 3);

  Map<String, dynamic> toJson() => {
        'now': now.toJson(),
        'days': days.map((d) => d.toJson()).toList(),
        'at': fetchedAt.toIso8601String(),
      };

  static Forecast? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final now = WeatherNow.fromJson(raw['now']);
    final at = DateTime.tryParse('${raw['at']}');
    if (now == null || at == null) return null;
    final days = <WeatherDay>[];
    if (raw['days'] is List) {
      for (final d in raw['days'] as List) {
        final day = WeatherDay.fromJson(d);
        if (day != null) days.add(day);
      }
    }
    return Forecast(now: now, days: days, fetchedAt: at);
  }
}

/// How dangerous today's heat is for someone working outdoors.
///
/// India's heat warnings are issued by the Meteorological Department against
/// each station's normal temperature, which an app cannot compute from one
/// reading. So this is deliberately a plain-language risk band on the
/// apparent temperature (heat plus humidity), not a claim about an official
/// warning, and every screen that shows it says so.
enum HeatRisk { none, warm, high, severe }

HeatRisk heatRisk(double feelsLikeC) {
  if (feelsLikeC >= 45) return HeatRisk.severe;
  if (feelsLikeC >= 40) return HeatRisk.high;
  if (feelsLikeC >= 35) return HeatRisk.warm;
  return HeatRisk.none;
}

String heatLine(HeatRisk risk, bool hi) => switch (risk) {
      HeatRisk.severe => hi
          ? 'बहुत ख़तरनाक गर्मी। दोपहर में बाहर का काम रोकें।'
          : 'Dangerous heat. Stop outdoor work in the middle of the day.',
      HeatRisk.high => hi
          ? 'तेज़ गर्मी। हर 15-20 मिनट में पानी पिएँ, छाँव में रुकें।'
          : 'Strong heat. Drink every 15-20 minutes and rest in shade.',
      HeatRisk.warm => hi
          ? 'गर्मी है। भारी काम सुबह या शाम को करें।'
          : 'Hot. Do heavy work early morning or evening.',
      HeatRisk.none => '',
    };

/// Rain worth acting on in the next three days: the highest chance found,
/// and the day it falls on.
({int chance, WeatherDay? day}) rainOutlook(List<WeatherDay> days) {
  var best = 0;
  WeatherDay? on;
  for (final d in days) {
    if (d.rainChance > best) {
      best = d.rainChance;
      on = d;
    }
  }
  return (chance: best, day: on);
}

/// How heavy a day's rain is, in the Meteorological Department's own bands
/// for 24-hour rainfall. Null in, null out.
enum RainBand { none, light, moderate, heavy, veryHeavy, extreme }

RainBand? rainBand(double? mm) {
  if (mm == null) return null;
  if (mm >= 204.5) return RainBand.extreme;
  if (mm >= 115.6) return RainBand.veryHeavy;
  if (mm >= 64.5) return RainBand.heavy;
  if (mm >= 15.6) return RainBand.moderate;
  if (mm >= 2.5) return RainBand.light;
  return RainBand.none;
}

String rainBandWord(RainBand b, bool hi) {
  switch (b) {
    case RainBand.none:
      return hi ? 'बारिश नहीं या नाम-मात्र' : 'None or a trace';
    case RainBand.light:
      return hi ? 'हल्की' : 'Light';
    case RainBand.moderate:
      return hi ? 'मध्यम' : 'Moderate';
    case RainBand.heavy:
      return hi ? 'भारी' : 'Heavy';
    case RainBand.veryHeavy:
      return hi ? 'बहुत भारी' : 'Very heavy';
    case RainBand.extreme:
      return hi ? 'अत्यधिक भारी' : 'Extremely heavy';
  }
}
