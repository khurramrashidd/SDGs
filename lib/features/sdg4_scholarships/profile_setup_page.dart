import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/layout/responsive.dart';
import '../../core/widgets/selection_tile.dart';
import 'student_profile.dart';

/// One-time form. Everything entered here stays on the device.
class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  String _level = '';
  int _class = 0;
  String _category = '';
  String _gender = '';
  bool _disability = false;
  int _income = -1;
  String _state = '';

  @override
  void initState() {
    super.initState();
    final p = context.read<StudentProfileStore>().profile;
    if (p.isComplete) {
      _level = p.level;
      _class = p.studyClass;
      _category = p.category;
      _gender = p.gender;
      _disability = p.disability;
      _income = p.annualIncome;
      _state = p.state;
    }
  }

  bool get _canSave => _level.isNotEmpty && _category.isNotEmpty;

  List<int> get _classOptions => switch (_level) {
        'pre_matric' => [8, 9, 10],
        'post_matric' => [11, 12],
        _ => const [],
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(title: const Text('Your details')),
      body: ContentShell(
        maxWidth: 620,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
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
                  Icon(Icons.phone_android,
                      size: 20, color: scheme.onPrimaryContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This stays on your phone only. It is never uploaded, '
                      'and you do not need an account.',
                      style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: scheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const _Q('What are you studying?'),
            ...kLevelOptions.entries.map(
              (e) => SelectionTile(
                label: e.value,
                selected: _level == e.key,
                onTap: () => setState(() {
                  _level = e.key;
                  _class = _classOptions.isEmpty ? 99 : 0;
                }),
              ),
            ),

            if (_classOptions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const _Q('Which class?'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _classOptions
                    .map((c) => ChoiceChip(
                          label: Text('Class $c'),
                          selected: _class == c,
                          onSelected: (_) => setState(() => _class = c),
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 24),
            const _Q('Category'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kCategoryOptions.entries
                  .map((e) => ChoiceChip(
                        label: Text(e.value),
                        selected: _category == e.key,
                        onSelected: (_) =>
                            setState(() => _category = e.key),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 24),
            const _Q('Gender'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final g in ['female', 'male', 'other'])
                  ChoiceChip(
                    label:
                        Text('${g[0].toUpperCase()}${g.substring(1)}'),
                    selected: _gender == g,
                    onSelected: (_) => setState(() => _gender = g),
                  ),
              ],
            ),

            const SizedBox(height: 16),
            SwitchListTile(
              value: _disability,
              contentPadding: EdgeInsets.zero,
              title: const Text('I have a disability certificate'),
              subtitle: const Text(
                'Unlocks schemes reserved for students with disabilities',
                style: TextStyle(fontSize: 12),
              ),
              onChanged: (v) => setState(() => _disability = v),
            ),

            const SizedBox(height: 24),
            const _Q('Family annual income'),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Used only to flag schemes worth double-checking. Nothing '
                'is hidden from you because of this.',
                style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: scheme.onSurfaceVariant),
              ),
            ),
            ...kIncomeBands.entries.map(
              (e) => SelectionTile(
                label: e.key,
                selected: _income == e.value,
                onTap: () => setState(() => _income = e.value),
              ),
            ),

            const SizedBox(height: 24),
            const _Q('State'),
            DropdownButtonFormField<String>(
              initialValue: _state.isEmpty ? null : _state,
              isExpanded: true,
              hint: const Text('Select your state'),
              items: kStates
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _state = v ?? ''),
            ),
            const SizedBox(height: 28),

            FilledButton(
              onPressed: _canSave ? _save : null,
              child: const Text('Show my scholarships'),
            ),
            const SizedBox(height: 8),
            if (!_canSave)
              Center(
                child: Text(
                  'Pick what you are studying and your category to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    await context.read<StudentProfileStore>().save(
          StudentProfile(
            level: _level,
            studyClass: _classOptions.isEmpty ? 99 : _class,
            category: _category,
            gender: _gender,
            disability: _disability,
            annualIncome: _income < 0 ? 0 : _income,
            state: _state,
          ),
        );
    if (mounted) Navigator.of(context).pop(true);
  }
}

class _Q extends StatelessWidget {
  final String text;
  const _Q(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700)),
      );
}
