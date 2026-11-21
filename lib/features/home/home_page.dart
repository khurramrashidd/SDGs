import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/strings.dart';
import '../../core/issues/registry.dart';
import '../../core/place/place_picker_page.dart';
import '../../core/place/place_service.dart';
import '../../core/layout/responsive.dart';
import '../../core/sdg/sdg_catalog.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/brand.dart';
import '../shell/app_drawer.dart';
import '../shell/quick_panel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;

    return Scaffold(
      drawer: const AppDrawer(),
      endDrawer: const QuickPanel(),
      // No SafeArea here on purpose: SliverAppBar already offsets itself by
      // the status bar inset, and wrapping it would count that padding twice.
      body: ContentShell(
        child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                titleSpacing: pad,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _LogoMark(size: 30),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        context.tr('app_name'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                actions: [
                  const _NotificationBell(),
                  Builder(
                    builder: (context) => IconButton(
                      tooltip: 'Quick settings',
                      icon: const Icon(Icons.tune),
                      onPressed: () =>
                          Scaffold.of(context).openEndDrawer(),
                    ),
                  ),
                  SizedBox(width: pad - 8),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 8, pad, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('home_title'),
                        style: TextStyle(
                          fontSize: context.responsive(
                              compact: 20, regular: 22, medium: 26),
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('home_subtitle'),
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _SearchBar(),
                      const SizedBox(height: 10),
                      const _PlaceLine(),
                    ],
                  ),
                ),
              ),

              // Column count comes from the available width, so this is the
              // same code on a 320dp phone (2 columns) and a desktop browser
              // (4 or 5), with no separate layouts to keep in sync.
              AdaptiveSliverGrid(
                padding: EdgeInsets.fromLTRB(pad, 0, pad, 28),
                targetTileWidth: context.isCompact ? 150 : 185,
                spacing: context.isCompact ? 10 : 12,
                childAspectRatio: context.responsive(
                    compact: 0.92, regular: 0.95, medium: 1.0),
                children: kSdgCatalog
                    .map((e) => _SdgTile(entry: e))
                    .toList(),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 0, pad, 36),
                  child: Center(
                    child: Text(
                      '${Brand.companyName} · ${Brand.tagline}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              ),
            ],
        ),
      ),
    );
  }
}

/// The app mark, drawn in code rather than loaded as an image so it picks up
/// the current theme and stays crisp at any size.
class _LogoMark extends StatelessWidget {
  final double size;
  const _LogoMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(
          ring: Theme.of(context).colorScheme.primary,
          dot: Brand.accent,
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color ring;
  final Color dot;
  const _LogoPainter({required this.ring, required this.dot});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    // Same proportions as brand/icon_badge.svg: open ring with a 60 degree
    // gap in the upper right, and the impact dot sitting in that gap.
    final strokeW = s * 0.17;
    final radius = s * 0.30;
    final centre = Offset(s * 0.42, s * 0.56);

    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      -0.26, // start just above the 3 o'clock position
      5.24, // 300 degrees in radians
      false,
      Paint()
        ..color = ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      Offset(s * 0.74, s * 0.26),
      s * 0.17,
      Paint()..color = dot,
    );
  }

  @override
  bool shouldRepaint(_LogoPainter old) =>
      old.ring != ring || old.dot != dot;
}

class _SdgTile extends StatelessWidget {
  final SdgEntry entry;
  const _SdgTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sdgColor = SdgColors.of(entry.goal);
    final live = entry.isLive;
    final compact = context.isCompact;

    return Opacity(
      opacity: live ? 1 : 0.45,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // A locked tile is still worth opening: it shows what is planned
          // for that goal, which is more use than a toast that says nothing.
          onTap: () => context.push(
              live ? entry.route! : '/sdg/planned/${entry.goal}'),
          child: Padding(
            padding: EdgeInsets.all(compact ? 11 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: compact ? 30 : 34,
                      height: compact ? 30 : 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: live
                            ? sdgColor
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '${entry.goal}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: compact ? 13 : 15,
                          color: live
                              ? Colors.white
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      live ? entry.icon : Icons.lock_outline,
                      size: compact ? 17 : 20,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  live ? context.tr(entry.titleKey) : entry.titleKey,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: compact ? 13.5 : 15,
                      fontWeight: FontWeight.w700,
                      height: 1.2),
                ),
                const SizedBox(height: 3),
                Text(
                  live
                      ? context.tr(entry.descKey)
                      : context.tr('coming_soon'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 11 : 12,
                    height: 1.3,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (live) ...[
                  const SizedBox(height: 4),
                  Text(
                    () {
                      final g = goalIssues(entry.goal);
                      return Localizations.localeOf(context).languageCode ==
                              'hi'
                          ? '${g.builtCount}/${g.issues.length} तैयार'
                          : '${g.builtCount}/${g.issues.length} ready';
                    }(),
                    style: TextStyle(
                      fontSize: compact ? 10.5 : 11.5,
                      fontWeight: FontWeight.w700,
                      color: sdgColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final service = context.watch<NotificationService>();

    return StreamBuilder<List<AppNotification>>(
      stream: service.feed(),
      builder: (context, snap) {
        final items = snap.data ?? const <AppNotification>[];
        final unread = service.unreadCount(items);

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: context.tr('notifications'),
              icon: const Icon(Icons.notifications_none),
              onPressed: () => context.push('/notifications'),
            ),
            if (unread > 0)
              Positioned(
                top: 8,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Brand.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// The one box that searches every problem in the app.
///
/// Not a real text field: tapping it opens the search screen, which keeps
/// the home screen cheap to build and means the keyboard never covers the
/// goal grid.
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/search'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.search, color: scheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hi
                      ? 'अपनी समस्या खोजें — ${kAllIssues.length} में से'
                      : 'Search your problem — ${kAllIssues.length} of them',
                  style: TextStyle(
                      fontSize: 14, color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Where the app thinks you are, and the weather there. Tapping it opens
/// the place picker, because the guess is often a nearby town.
class _PlaceLine extends StatelessWidget {
  const _PlaceLine();

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final service = context.watch<PlaceService>();
    final place = service.place;
    final now = service.now;

    final text = place == null
        ? (service.loading
            ? (hi ? 'जगह पता की जा रही है…' : 'Finding your place…')
            : (hi ? 'अपनी जगह चुनें' : 'Set your place'))
        : now == null
            ? place.label
            : '${place.label}  ·  ${now.tempC.round()}°C';

    return InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const PlacePickerPage())),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(Icons.place_outlined, size: 16, color: scheme.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12.5, color: scheme.onSurfaceVariant)),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit_outlined, size: 13, color: scheme.outline),
          ],
        ),
      ),
    );
  }
}
