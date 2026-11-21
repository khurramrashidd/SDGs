import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../i18n/locale_scope.dart';
import '../i18n/strings.dart';
import '../issues/issue.dart';
import '../issues/registry.dart';
import '../issues/saved_tools.dart';
import '../layout/responsive.dart';
import '../place/place_picker_page.dart';
import '../place/place_service.dart';
import '../place/weather.dart';
import '../sdg/sdg_catalog.dart';
import '../theme/brand.dart';

/// A goal, as its own small app.
///
/// Opening goal 6 should feel like opening a water app, not like scrolling
/// to the sixth section of one long app. So each goal gets its own colour,
/// its own menu of problems, its own side panel and its own footer, and the
/// app's own home screen becomes the place you leave to get here.
///
/// Everything on screen is read from [goalIssues]. There is no second list
/// of what a goal contains, which is the only way seventeen of these stay
/// consistent with each other.
class GoalApp extends StatefulWidget {
  final int goal;

  /// Opens straight on this issue's screen - used by search and by a
  /// saved tool, so the user lands inside the goal rather than at its home.
  final String? openIssueId;

  const GoalApp({super.key, required this.goal, this.openIssueId});

  @override
  State<GoalApp> createState() => _GoalAppState();
}

class _GoalAppState extends State<GoalApp> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _tab = 0;
  String? _group;
  Timer? _clock;
  DateTime _now = DateTime.now();

  late final GoalIssues _goal = goalIssues(widget.goal);

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  @override
  void initState() {
    super.initState();
    // The header shows a live clock. A minute is fine: a seconds-accurate
    // clock would rebuild the whole screen sixty times a minute for nothing.
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    final id = widget.openIssueId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final issue = issueById(id);
        if (issue != null && mounted) openIssue(context, issue);
      });
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = _hi;
    final wide = context.isWide;
    final accent = SdgColors.of(widget.goal);
    final entry = kSdgCatalog.firstWhere((e) => e.goal == widget.goal,
        orElse: () => kSdgCatalog.first);

    final body = switch (_tab) {
      0 => _GoalHome(
          goal: _goal,
          onSeeAll: () => setState(() {
            _tab = 1;
            _group = null;
          }),
        ),
      1 => _GoalProblems(
          goal: _goal,
          only: _group,
          onOnly: (g) => setState(() => _group = g),
        ),
      2 => _GoalSaved(goal: _goal),
      _ => _GoalHelp(goal: _goal),
    };

    final menu = _GoalMenu(
      goal: _goal,
      onPick: (group) {
        setState(() {
          _tab = 1;
          _group = group;
        });
        if (!wide) Navigator.of(context).maybePop();
      },
    );
    final panel = _GoalPanel(goal: _goal);

    return Scaffold(
      key: _scaffoldKey,
      // On a phone both panels slide in. On a tablet or a browser window
      // they are simply there, which is what makes the wide layout worth
      // having at all.
      drawer: wide ? null : Drawer(child: SafeArea(child: menu)),
      endDrawer: wide ? null : Drawer(child: SafeArea(child: panel)),
      appBar: AppBar(
        title: _GoalTitle(
            goal: widget.goal, titleKey: entry.titleKey, now: _now),
        titleSpacing: 4,
        actions: [
          IconButton(
            tooltip: hi ? 'खोजें' : 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          const SectionLanguageButton(),
          if (!wide)
            Builder(
              builder: (ctx) => IconButton(
                tooltip: hi ? 'मौसम और मदद' : 'Weather and help',
                icon: const Icon(Icons.wb_sunny_outlined),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: accent),
        ),
      ),
      body: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 260, child: menu),
                const VerticalDivider(width: 1),
                Expanded(child: body),
                const VerticalDivider(width: 1),
                SizedBox(width: 300, child: panel),
              ],
            )
          : body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() {
          _tab = i;
          if (i != 1) _group = null;
        }),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: hi ? 'घर' : 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.checklist_outlined),
            selectedIcon: const Icon(Icons.checklist),
            label: hi ? 'समस्याएँ' : 'Problems',
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_outline),
            selectedIcon: const Icon(Icons.bookmark),
            label: hi ? 'सहेजे' : 'Saved',
          ),
          NavigationDestination(
            icon: const Icon(Icons.support_agent_outlined),
            selectedIcon: const Icon(Icons.support_agent),
            label: hi ? 'मदद' : 'Help',
          ),
        ],
      ),
    );
  }
}

/// Goal name, with where you are and what time it is underneath.
class _GoalTitle extends StatelessWidget {
  final int goal;
  final String titleKey;
  final DateTime now;

  const _GoalTitle(
      {required this.goal, required this.titleKey, required this.now});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final service = context.watch<PlaceService>();
    final place = service.place;
    final weather = service.now;
    final fmt = DateFormat(hi ? 'EEE, d MMM · HH:mm' : 'EEE d MMM · HH:mm');

    final bits = <String>[fmt.format(now)];
    if (weather != null) {
      final glyph = weatherGlyph(weather.code, day: weather.isDay);
      bits.insert(0, '${weather.tempC.round()}°  $glyph');
    }
    if (place != null) bits.insert(0, place.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.tr(titleKey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        InkWell(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const PlacePickerPage())),
          child: Padding(
            padding: const EdgeInsets.only(top: 1, bottom: 1, right: 4),
            child: Text(
              bits.join('  ·  '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, height: 1.1),
            ),
          ),
        ),
      ],
    );
  }
}

/// The hamburger menu: this goal's problems, grouped.
class _GoalMenu extends StatelessWidget {
  final GoalIssues goal;
  final void Function(String group) onPick;

  const _GoalMenu({required this.goal, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final hi = lang == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final accent = SdgColors.of(goal.goal);
    final entry = kSdgCatalog.firstWhere((e) => e.goal == goal.goal,
        orElse: () => kSdgCatalog.first);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          color: accent.withValues(alpha: 0.12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SDG ${goal.goal}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: accent)),
              const SizedBox(height: 2),
              Text(context.tr(entry.titleKey),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                hi
                    ? '${goal.issues.length} समस्याएँ · '
                        '${goal.builtCount} अभी काम करती हैं'
                    : '${goal.issues.length} problems · '
                        '${goal.builtCount} working now',
                style:
                    TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        for (final g in goal.groups)
          ListTile(
            dense: true,
            leading: Icon(Icons.folder_outlined, color: scheme.primary),
            title: Text(g.label(lang),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: Text('${goal.inGroup(g.key).length}',
                style:
                    TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            onTap: () => onPick(g.key),
          ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.grid_view_outlined),
          title: Text(hi ? 'सभी 17 लक्ष्य' : 'All 17 goals'),
          onTap: () => context.go('/'),
        ),
        ListTile(
          leading: const Icon(Icons.search),
          title: Text(hi ? 'हर चीज़ में खोजें' : 'Search everything'),
          onTap: () => context.push('/search'),
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: Text(hi ? 'सेटिंग' : 'Settings'),
          onTap: () => context.push('/settings'),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// The right-hand panel: weather, helplines, saved tools, notices.
class _GoalPanel extends StatelessWidget {
  final GoalIssues goal;
  const _GoalPanel({required this.goal});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final hi = lang == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final service = context.watch<PlaceService>();
    final saved = context.watch<SavedTools>();
    final forecast = service.forecast;
    final recent = [
      for (final id in saved.recent) issueById(id),
    ].whereType<Issue>().where((i) => i.goal == goal.goal).take(4).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
      children: [
        _PanelHeading(hi ? 'मौसम' : 'Weather'),
        _WeatherCard(goal: goal.goal),
        if (forecast != null && forecast.days.length > 1) ...[
          const SizedBox(height: 8),
          for (final d in forecast.days.skip(1).take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                      width: 42,
                      child: Text(DateFormat('EEE').format(d.date),
                          style: const TextStyle(fontSize: 12.5))),
                  Text(weatherGlyph(d.code)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(weatherWord(d.code, hi),
                        style: TextStyle(
                            fontSize: 12, color: scheme.onSurfaceVariant)),
                  ),
                  if (d.rainChance >= 40)
                    Text('${d.rainChance}% ',
                        style: const TextStyle(fontSize: 12)),
                  Text('${d.maxC.round()}° / ${d.minC.round()}°',
                      style: const TextStyle(fontSize: 12.5)),
                ],
              ),
            ),
        ],
        if (goal.helplines.isNotEmpty) ...[
          _PanelHeading(hi ? 'मदद के नंबर' : 'Help numbers'),
          for (final h in goal.helplines)
            Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                leading: Icon(Icons.phone_outlined, color: scheme.primary),
                title: Text(h.number,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(h.label(lang),
                    style: const TextStyle(fontSize: 12)),
                onTap: () =>
                    launchUrl(Uri(scheme: 'tel', path: h.number)),
              ),
            ),
        ],
        if (recent.isNotEmpty) ...[
          _PanelHeading(hi ? 'हाल में खोले' : 'Recently opened'),
          for (final i in recent)
            Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                leading: Icon(i.icon, size: 20),
                title: Text(i.title(lang),
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13, height: 1.25)),
                onTap: () => openIssue(context, i),
              ),
            ),
        ],
        _PanelHeading(hi ? 'सूचनाएँ' : 'Notices'),
        _GoalNotices(goal: goal.goal),
      ],
    );
  }
}

class _PanelHeading extends StatelessWidget {
  final String text;
  const _PanelHeading(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
}

class _WeatherCard extends StatelessWidget {
  final int goal;
  const _WeatherCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final service = context.watch<PlaceService>();
    final now = service.now;
    final place = service.place;

    if (now == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.loading
                    ? (hi ? 'मौसम लाया जा रहा है…' : 'Getting the weather…')
                    : (hi
                        ? 'मौसम नहीं मिला। अपनी जगह चुनें।'
                        : 'No weather yet. Set your place.'),
                style: const TextStyle(height: 1.4),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PlacePickerPage())),
                icon: const Icon(Icons.place_outlined),
                label: Text(hi ? 'जगह चुनें' : 'Set place'),
              ),
            ],
          ),
        ),
      );
    }

    final risk = heatRisk(now.feelsLikeC);
    final rain = rainOutlook(service.forecast?.days ?? const []);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weatherGlyph(now.code, day: now.isDay),
                    style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${now.tempC.round()}°C',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                      Text(weatherWord(now.code, hi),
                          style: TextStyle(
                              fontSize: 12.5,
                              color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (place != null)
                  Flexible(
                    child: Text(place.name,
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              hi
                  ? 'महसूस ${now.feelsLikeC.round()}°  ·  नमी ${now.humidity}%'
                  : 'Feels ${now.feelsLikeC.round()}°  ·  '
                      'humidity ${now.humidity}%',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
            if (service.isStale)
              Text(
                hi ? 'पुरानी रीडिंग' : 'Last known reading',
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
            // The weather only earns its place here when it changes what
            // someone should do, so a warning shows only on the goals it
            // actually bears on.
            if (risk != HeatRisk.none && const [3, 8, 13].contains(goal)) ...[
              const SizedBox(height: 8),
              _Warn(text: heatLine(risk, hi), severe: risk == HeatRisk.severe),
            ],
            if (rain.chance >= 60 && const [2, 11, 13, 15].contains(goal)) ...[
              const SizedBox(height: 8),
              _Warn(
                text: hi
                    ? 'बारिश की संभावना ${rain.chance}% — खुला सामान ढक दें।'
                    : 'Rain likely (${rain.chance}%) — cover anything '
                        'left in the open.',
                severe: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Warn extends StatelessWidget {
  final String text;
  final bool severe;
  const _Warn({required this.text, required this.severe});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: severe ? scheme.errorContainer : scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: severe
                  ? scheme.onErrorContainer
                  : scheme.onTertiaryContainer)),
    );
  }
}

/// Notices an admin sent, for this goal or for the whole app.
class _GoalNotices extends StatelessWidget {
  final int goal;
  const _GoalNotices({required this.goal});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final hi = lang == 'hi';
    final scheme = Theme.of(context).colorScheme;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      // No ordering and no goal filter in the query: either would need a
      // composite index, and this list is short. Filtering happens here.
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .limit(40)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final rows = snap.data!.docs
            .map((d) => d.data())
            .where((m) => m['goal'] == null || m['goal'] == goal)
            .toList()
          ..sort((a, b) {
            final x = a['createdAt'], y = b['createdAt'];
            if (x is Timestamp && y is Timestamp) return y.compareTo(x);
            return 0;
          });
        if (rows.isEmpty) {
          return Text(hi ? 'कोई सूचना नहीं।' : 'Nothing new.',
              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant));
        }
        return Column(
          children: [
            for (final m in rows.take(4))
              Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${m['title'] ?? ''}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 3),
                      Text('${m['body'] ?? ''}',
                          style: const TextStyle(fontSize: 12.5, height: 1.4)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Opens an issue, or explains that it is still being built.
void openIssue(BuildContext context, Issue issue) {
  final lang = Localizations.localeOf(context).languageCode;
    final hi = lang == 'hi';
  final build = issue.open;
  if (build == null) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(issue.title(lang),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(issue.blurb(lang), style: const TextStyle(height: 1.5)),
            const SizedBox(height: 14),
            Text(
              hi
                  ? 'यह अभी बन रहा है। ऐप अपडेट होने पर यहीं दिखेगा — सूची '
                      'में इसलिए '
                      'रखा है ताकि आप देख सकें कि क्या आ रहा है।'
                  : 'This one is still being built. It will appear right here '
                      'when the app updates. It is listed so you can see what '
                      'is coming, rather than being hidden.',
              style: TextStyle(
                  height: 1.5,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
    return;
  }
  context.read<SavedTools>().markOpened(issue.id);
  Navigator.of(context).push(localeScopedRoute(Builder(builder: build)));
}

/// The goal's own home: the strongest tool first, then the groups.
class _GoalHome extends StatelessWidget {
  final GoalIssues goal;
  final VoidCallback onSeeAll;
  const _GoalHome({required this.goal, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final hi = lang == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final pad = context.pagePadding;
    final accent = SdgColors.of(goal.goal);
    final hero = goal.issues.firstWhere((i) => i.isBuilt,
        orElse: () => goal.issues.first);
    final rest = goal.issues.where((i) => i.isBuilt && i.id != hero.id);

    return ContentShell(
      maxWidth: 760,
      child: ListView(
        padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
        children: [
          Card(
            color: accent.withValues(alpha: 0.10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hero.title(lang),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.3)),
                  const SizedBox(height: 8),
                  Text(hero.blurb(lang),
                      style: const TextStyle(fontSize: 14, height: 1.55)),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => openIssue(context, hero),
                    icon: Icon(hero.icon),
                    label: Text(hi ? 'खोलें' : 'Open'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hi
                ? 'इस लक्ष्य में ${goal.issues.length} समस्याएँ हैं। '
                    '${goal.builtCount} अभी काम करती हैं।'
                : '${goal.issues.length} problems in this goal. '
                    '${goal.builtCount} work now.',
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          for (final i in rest) _IssueTile(issue: i),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onSeeAll,
            icon: const Icon(Icons.checklist_outlined),
            label: Text(hi
                ? 'सभी ${goal.issues.length} समस्याएँ देखें'
                : 'See all ${goal.issues.length} problems'),
          ),
        ],
      ),
    );
  }
}

/// Every problem in the goal, grouped, with the built ones first.
class _GoalProblems extends StatelessWidget {
  final GoalIssues goal;

  /// Which group is showing, or null for all. Held by the goal's own state
  /// so that picking a group in the menu a second time still works.
  final String? only;
  final void Function(String?) onOnly;

  const _GoalProblems(
      {required this.goal, required this.only, required this.onOnly});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final hi = lang == 'hi';
    final pad = context.pagePadding;
    final groups =
        only == null ? goal.groups : goal.groups.where((g) => g.key == only);

    return ContentShell(
      maxWidth: 760,
      child: ListView(
        padding: EdgeInsets.fromLTRB(pad, 12, pad, 36),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              ChoiceChip(
                label: Text(hi ? 'सभी' : 'All'),
                selected: only == null,
                onSelected: (_) => onOnly(null),
              ),
              for (final g in goal.groups) ...[
                const SizedBox(width: 6),
                ChoiceChip(
                  label: Text(g.label(lang)),
                  selected: only == g.key,
                  onSelected: (_) => onOnly(g.key),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 8),
          for (final g in groups) ...[
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 6, left: 2),
              child: Text(
                g.label(lang).toUpperCase(),
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            // Working tools first, then the ones still being built.
            for (final i in sortedForList(goal.inGroup(g.key)))
              _IssueTile(issue: i),
          ],
        ],
      ),
    );
  }
}

class _GoalSaved extends StatelessWidget {
  final GoalIssues goal;
  const _GoalSaved({required this.goal});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final pad = context.pagePadding;
    final saved = context.watch<SavedTools>();
    final mine = [for (final id in saved.saved) issueById(id)]
        .whereType<Issue>()
        .toList();
    final recent = [for (final id in saved.recent) issueById(id)]
        .whereType<Issue>()
        .toList();

    return ContentShell(
      maxWidth: 760,
      child: ListView(
        padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
        children: [
          if (mine.isEmpty && recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.bookmark_outline,
                      size: 44,
                      color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 10),
                  Text(
                    hi
                        ? 'किसी टूल पर बुकमार्क दबाएँ, वह यहाँ दिखेगा।'
                        : 'Tap the bookmark on any tool and it appears here.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          if (mine.isNotEmpty) ...[
            Text(hi ? 'सहेजे हुए' : 'Saved',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            for (final i in mine) _IssueTile(issue: i, showGoal: true),
          ],
          if (recent.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(hi ? 'हाल में खोले' : 'Recently opened',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            for (final i in recent) _IssueTile(issue: i, showGoal: true),
          ],
        ],
      ),
    );
  }
}

class _GoalHelp extends StatelessWidget {
  final GoalIssues goal;
  const _GoalHelp({required this.goal});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final hi = lang == 'hi';
    final pad = context.pagePadding;
    final scheme = Theme.of(context).colorScheme;

    return ContentShell(
      maxWidth: 680,
      child: ListView(
        padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
        children: [
          Text(hi ? 'मदद के नंबर' : 'Help numbers',
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            hi
                ? 'सभी मुफ़्त हैं। दबाकर सीधे कॉल करें।'
                : 'All free. Tap to call straight away.',
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          for (final h in goal.helplines)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(Icons.phone, color: scheme.onPrimaryContainer),
                ),
                title: Text(h.number,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                subtitle: Text(h.label(lang)),
                onTap: () => launchUrl(Uri(scheme: 'tel', path: h.number)),
              ),
            ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hi ? 'कुछ ग़लत दिखा?' : 'Something wrong here?',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    hi
                        ? 'ग़लत नंबर, बंद लिंक, या बदली हुई राशि — बताएँ, '
                            'सबके लिए ठीक हो जाएगी।'
                        : 'A wrong number, a dead link, an amount that has '
                            'changed — tell us and it is fixed for everyone.',
                    style: const TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => context.push('/sdg/17'),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(hi ? 'सुधार भेजें' : 'Send a correction'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hi
                ? 'इस ऐप की हर जानकारी के साथ उसका सरकारी स्रोत दिया है। '
                    'कोई क़दम उठाने से पहले वह लिंक खोलकर देख लें — नियम '
                    'बदलते रहते हैं।'
                : 'Every fact in this app carries a link to its government '
                    'source. Open it before you act — rules change.',
            style: TextStyle(
                fontSize: 12.5, height: 1.5, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Built tools first, order otherwise unchanged.
List<Issue> sortedForList(List<Issue> issues) {
  final out = [...issues];
  out.sort((a, b) => (b.isBuilt ? 1 : 0) - (a.isBuilt ? 1 : 0));
  return out;
}

/// One problem in a list. Greyed when it is not built yet.
class _IssueTile extends StatelessWidget {
  final Issue issue;
  final bool showGoal;
  const _IssueTile({required this.issue, this.showGoal = false});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final hi = lang == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final saved = context.watch<SavedTools>();
    final on = issue.isBuilt;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.only(left: 14, right: 4, top: 6, bottom: 6),
        leading: Icon(issue.icon,
            color: on ? SdgColors.of(issue.goal) : scheme.outline),
        title: Text(
          issue.title(lang),
          style: TextStyle(
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: on ? null : scheme.onSurfaceVariant),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            on
                ? issue.blurb(lang)
                : '${issue.blurb(lang)}  ·  '
                    '${hi ? 'बन रहा है' : 'being built'}',
            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (on)
              IconButton(
                tooltip: hi ? 'सहेजें' : 'Save',
                icon: Icon(saved.isSaved(issue.id)
                    ? Icons.bookmark
                    : Icons.bookmark_outline),
                onPressed: () =>
                    context.read<SavedTools>().toggleSaved(issue.id),
              ),
            Icon(on ? Icons.chevron_right : Icons.schedule,
                color: scheme.outline),
            const SizedBox(width: 6),
          ],
        ),
        onTap: () => openIssue(context, issue),
      ),
    );
  }
}
