import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';

/// Literacy rates, from the World Bank's open API.
///
/// Carried over from LearningVersity's Literacy Tracker, with two changes.
///
/// The original passed whatever country name the user typed straight into
/// the API URL, which expects an ISO country code, so most searches would
/// have come back empty. This uses a fixed list with the right codes.
///
/// And it shows women and men side by side. The overall figure hides the
/// thing that matters most for this app: in India the gap between the two
/// is large, and that gap is the reason SDG 4 and SDG 5 sit next to each
/// other on the home screen.
class LiteracyPage extends StatefulWidget {
  const LiteracyPage({super.key});

  @override
  State<LiteracyPage> createState() => _LiteracyPageState();
}

class _Country {
  final String code;
  final String name;
  final String nameHi;
  const _Country(this.code, this.name, this.nameHi);
}

const _countries = [
  _Country('IND', 'India', 'भारत'),
  _Country('BGD', 'Bangladesh', 'बांग्लादेश'),
  _Country('NPL', 'Nepal', 'नेपाल'),
  _Country('PAK', 'Pakistan', 'पाकिस्तान'),
  _Country('LKA', 'Sri Lanka', 'श्रीलंका'),
  _Country('CHN', 'China', 'चीन'),
  _Country('WLD', 'World', 'विश्व'),
];

class _Reading {
  final double? value;
  final String? year;
  const _Reading(this.value, this.year);
}

class _Row {
  final _Country country;
  final _Reading total;
  final _Reading female;
  final _Reading male;
  const _Row(this.country, this.total, this.female, this.male);
}

class _LiteracyPageState extends State<LiteracyPage> {
  late Future<List<_Row>> _future = _load();

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  /// Fetches a window of years and keeps the latest year that has a value.
  /// Literacy surveys are infrequent, so the newest year is usually empty;
  /// asking for one year would show "no data" for most countries.
  Future<_Reading> _indicator(String code, String indicator) async {
    final uri = Uri.parse(
        'https://api.worldbank.org/v2/country/$code/indicator/$indicator'
        '?format=json&date=2000:2030&per_page=40');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) return const _Reading(null, null);
    final body = jsonDecode(res.body);
    if (body is! List || body.length < 2 || body[1] is! List) {
      return const _Reading(null, null);
    }
    for (final row in body[1] as List) {
      if (row is Map && row['value'] is num) {
        return _Reading((row['value'] as num).toDouble(), '${row['date']}');
      }
    }
    return const _Reading(null, null);
  }

  Future<List<_Row>> _load() async {
    final out = <_Row>[];
    for (final c in _countries) {
      final results = await Future.wait([
        _indicator(c.code, 'SE.ADT.LITR.ZS'),
        _indicator(c.code, 'SE.ADT.LITR.FE.ZS'),
        _indicator(c.code, 'SE.ADT.LITR.MA.ZS'),
      ]);
      out.add(_Row(c, results[0], results[1], results[2]));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    final hi = _hi;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? 'साक्षरता दर' : 'Literacy rates'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(4)),
        ),
      ),
      body: ContentShell(
        maxWidth: 680,
        child: FutureBuilder<List<_Row>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError || snap.data == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hi
                            ? 'आँकड़े लोड नहीं हुए। इंटरनेट जाँचें।'
                            : 'Could not load the figures. Check the '
                                'internet connection.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => setState(() => _future = _load()),
                        child: Text(hi ? 'फिर कोशिश करें' : 'Try again'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final rows = snap.data!;
            return ListView(
              padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
              children: [
                Text(
                  hi
                      ? '15 साल और उससे ऊपर के लोग जो पढ़-लिख सकते हैं, प्रतिशत में। '
                          'हर देश का सबसे हाल का उपलब्ध साल दिखाया गया है।'
                      : 'People aged 15 and over who can read and write, as a '
                          'percentage. Each country shows its most recent '
                          'available year.',
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                for (final r in rows) _CountryCard(row: r, hi: hi),
                const SizedBox(height: 8),
                Text(
                  hi
                      ? 'स्रोत: विश्व बैंक, विश्व विकास संकेतक।'
                      : 'Source: World Bank, World Development Indicators.',
                  style: TextStyle(
                      fontSize: 11.5, color: scheme.onSurfaceVariant),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CountryCard extends StatelessWidget {
  final _Row row;
  final bool hi;
  const _CountryCard({required this.row, required this.hi});

  String _pct(_Reading r) =>
      r.value == null ? '—' : '${r.value!.toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final f = row.female.value;
    final m = row.male.value;
    final gap = (f != null && m != null) ? m - f : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(hi ? row.country.nameHi : row.country.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                ),
                Text(_pct(row.total),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: scheme.primary)),
              ],
            ),
            if (row.total.year != null)
              Text(row.total.year!,
                  style: TextStyle(
                      fontSize: 11.5, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            _Bar(
                label: hi ? 'महिलाएँ' : 'Women',
                value: f,
                color: Colors.pink.shade400),
            const SizedBox(height: 4),
            _Bar(
                label: hi ? 'पुरुष' : 'Men',
                value: m,
                color: Colors.blue.shade400),
            if (gap != null && gap > 0.5) ...[
              const SizedBox(height: 6),
              Text(
                hi
                    ? 'अंतर: ${gap.toStringAsFixed(1)} प्रतिशत अंक'
                    : 'Gap: ${gap.toStringAsFixed(1)} percentage points',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double? value;
  final Color color;
  const _Bar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final v = value;
    return Row(
      children: [
        SizedBox(
            width: 64,
            child: Text(label, style: const TextStyle(fontSize: 12.5))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: v == null ? 0 : (v / 100).clamp(0.0, 1.0),
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
            ),
          ),
        ),
        SizedBox(
          width: 52,
          child: Text(v == null ? '—' : '${v.toStringAsFixed(1)}%',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12.5)),
        ),
      ],
    );
  }
}
