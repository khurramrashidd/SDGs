import 'package:flutter/material.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/i18n/strings.dart';
import '../../core/theme/brand.dart';
import '../../core/layout/responsive.dart';

/// Honest placeholder for the goals that are planned but not built yet
/// (6 to 17). It lists exactly what is coming, so the screen never pretends
/// to work and the roadmap is visible inside the app rather than only in a
/// document. Each one is replaced by a real module as it is built.
class ModuleScaffoldPage extends StatelessWidget {
  final int goal;
  final String titleKey;
  final List<String> plannedFeatures;

  const ModuleScaffoldPage({
    super.key,
    required this.goal,
    required this.titleKey,
    required this.plannedFeatures,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sdgColor = SdgColors.of(goal);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(titleKey)),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: sdgColor),
        ),
      ),
      body: ContentShell(
        maxWidth: 700,
        child: ListView(
          padding: EdgeInsets.fromLTRB(context.pagePadding, 24, context.pagePadding, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.construction_outlined,
                      color: scheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This module is being built. Nothing here is live yet.',
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Planned for this goal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            ...plannedFeatures.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: sdgColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(f,
                          style:
                              const TextStyle(fontSize: 15, height: 1.45)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
