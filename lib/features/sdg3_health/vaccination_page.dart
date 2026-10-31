import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import 'health_models.dart';

/// The Universal Immunisation Programme schedule, as a reference.
///
/// A reference, not a tracker: a tracker would need the child's date of
/// birth and would start telling people they are late, which needs to be
/// right about a real child on a real date. This just answers "what is due
/// at this age, and is it free" - which is the question people actually ask.
class VaccinationPage extends StatefulWidget {
  const VaccinationPage({super.key});

  @override
  State<VaccinationPage> createState() => _VaccinationPageState();
}

class _VaccinationPageState extends State<VaccinationPage> {
  late final Future<List<VaccineStage>> _future = _load();

  Future<List<VaccineStage>> _load() async {
    final raw =
        await rootBundle.loadString('assets/data/vaccination_schedule.json');
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => VaccineStage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? 'टीकाकरण सूची' : 'Vaccination schedule'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(3)),
        ),
      ),
      body: ContentShell(
        maxWidth: 680,
        child: FutureBuilder<List<VaccineStage>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final stages = snap.data ?? const <VaccineStage>[];

            return ListView(
              padding: EdgeInsets.fromLTRB(pad, 14, pad, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.payments_outlined,
                          size: 19, color: scheme.onPrimaryContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          hi
                              ? 'ये सभी टीके हर सरकारी स्वास्थ्य केंद्र और '
                                  'आँगनवाड़ी पर पूरी तरह निःशुल्क हैं। अपना '
                                  'टीकाकरण कार्ड साथ ले जाएँ।'
                              : 'Every vaccine here is completely free at any '
                                  'government health centre and anganwadi. '
                                  'Take your immunisation card with you.',
                          style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: scheme.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ...stages.map((s) => _Stage(stage: s, hi: hi)),
                const SizedBox(height: 14),
                Text(
                  hi
                      ? 'कोई खुराक छूट गई हो तो भी देर नहीं हुई — स्वास्थ्य '
                          'केंद्र जाकर पूछें, वे बची हुई खुराकें लगा देंगे।'
                      : 'If a dose has been missed it is not too late — go to '
                          'the health centre and ask; they will give the '
                          'remaining doses.',
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: scheme.onSurfaceVariant),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  final VaccineStage stage;
  final bool hi;
  const _Stage({required this.stage, required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = SdgColors.of(3);
    final lang = LocaleScope.languageOf(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: accent, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    stage.ageText(lang),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...stage.vaccineList(lang).map(
                  (v) => Padding(
                    padding: const EdgeInsets.only(bottom: 7, left: 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.vaccines_outlined,
                            size: 16, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(v,
                              style: const TextStyle(
                                  fontSize: 14, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ),
            if (stage.noteText(lang).isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Text(
                  stage.noteText(lang),
                  style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
