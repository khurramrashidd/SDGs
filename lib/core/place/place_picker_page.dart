import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layout/responsive.dart';
import 'place.dart';
import 'place_service.dart';

/// "Which town are you in?" - typed, not tapped through a list of 780
/// districts, because most users know their own town's name and nobody
/// enjoys scrolling to find it.
class PlacePickerPage extends StatefulWidget {
  const PlacePickerPage({super.key});

  @override
  State<PlacePickerPage> createState() => _PlacePickerPageState();
}

class _PlacePickerPageState extends State<PlacePickerPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Place> _results = const [];
  bool _searching = false;
  String? _error;

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _results = const [];
        _error = null;
      });
      return;
    }
    // Wait for the typing to settle: one request per word, not per letter.
    _debounce = Timer(const Duration(milliseconds: 450), () => _search(value));
  }

  Future<void> _search(String value) async {
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final list = await PlaceService.searchTowns(value);
      if (!mounted) return;
      setState(() {
        _results = list;
        _searching = false;
        _error = list.isEmpty
            ? (_hi
                ? 'यह नाम नहीं मिला। पास के बड़े क़स्बे या ज़िले का नाम लिखें।'
                : 'No match. Try the nearest bigger town or the district name.')
            : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _error = _hi
            ? 'खोज नहीं हो पाई। इंटरनेट जाँचें।'
            : 'Could not search. Check the internet connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hi = _hi;
    final pad = context.pagePadding;
    final scheme = Theme.of(context).colorScheme;
    final service = context.watch<PlaceService>();
    final current = service.place;

    return Scaffold(
      appBar: AppBar(title: Text(hi ? 'आपकी जगह' : 'Your place')),
      body: ContentShell(
        maxWidth: 640,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: [
            Text(
              hi
                  ? 'मौसम और कुछ सलाह आपकी जगह के हिसाब से दिखती है। अपना क़स्बा, '
                      'गाँव या ज़िला लिखकर चुनें।'
                  : 'Weather, and some of the advice, follows where you are. '
                      'Type your town, village or district and pick it.',
              style: TextStyle(
                  fontSize: 13.5, height: 1.5, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: hi ? 'क़स्बा, गाँव या ज़िला' : 'Town, village or district',
                border: const OutlineInputBorder(),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : null,
              ),
              onChanged: _onChanged,
              onSubmitted: _search,
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
            const SizedBox(height: 10),
            for (final p in _results)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(p.name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: p.region.isEmpty ? null : Text(p.region),
                  onTap: () async {
                    final nav = Navigator.of(context);
                    await context.read<PlaceService>().setPlace(p);
                    if (nav.canPop()) nav.pop();
                  },
                ),
              ),
            if (current != null) ...[
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 6),
              Text(hi ? 'अभी सेट है' : 'Set now',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(current.label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                current.chosen
                    ? (hi ? 'आपने चुना था' : 'You chose this')
                    : (hi
                        ? 'नेटवर्क से अंदाज़ा लगाया गया — ग़लत हो तो ऊपर सही जगह चुनें'
                        : 'Guessed from the network — pick the right one above '
                            'if it is wrong'),
                style:
                    TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
              ),
              if (current.chosen) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        context.read<PlaceService>().clearPlace(),
                    icon: const Icon(Icons.restart_alt),
                    label: Text(
                        hi ? 'अपने आप पता लगाएँ' : 'Go back to automatic'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
