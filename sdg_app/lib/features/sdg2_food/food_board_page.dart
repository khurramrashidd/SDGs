import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/brand.dart';
import 'food_board.dart';
import 'share_check.dart';
import 'share_check_page.dart';

String _kindLabel(FoodKind k, bool hi) => switch (k) {
      FoodKind.cookedHighRisk => hi ? 'पका खाना' : 'Cooked food',
      FoodKind.cookedLowRisk => hi ? 'रोटी / सूखा' : 'Roti / dry food',
      FoodKind.packagedSealed => hi ? 'सीलबंद पैकेट' : 'Sealed packets',
      FoodKind.rawProduce => hi ? 'कच्ची सब्ज़ी / फल' : 'Vegetables / fruit',
    };

String _timeLeft(DateTime t, bool hi) {
  final d = t.difference(DateTime.now());
  if (d.isNegative) return hi ? 'समय ख़त्म' : 'Expired';
  if (d.inMinutes < 60) {
    return hi ? '${d.inMinutes} मिनट बाक़ी' : '${d.inMinutes} min left';
  }
  return hi ? '${d.inHours} घंटे बाक़ी' : '${d.inHours} h left';
}

/// The board: live posts near you, and your own posts.
class FoodBoardPage extends StatefulWidget {
  const FoodBoardPage({super.key});

  @override
  State<FoodBoardPage> createState() => _FoodBoardPageState();
}

class _FoodBoardPageState extends State<FoodBoardPage> {
  String _area = '';

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  @override
  Widget build(BuildContext context) {
    final hi = _hi;
    final pad = context.pagePadding;
    final auth = context.watch<AuthService>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(hi ? 'खाना बाँटें, खाना पाएँ' : 'Food board'),
          actions: const [SectionLanguageButton()],
          bottom: TabBar(tabs: [
            Tab(text: hi ? 'उपलब्ध खाना' : 'Available'),
            Tab(text: hi ? 'मेरी पोस्ट' : 'My posts'),
          ]),
        ),
        floatingActionButton: FloatingActionButton.extended(
          // Posting always starts at the safety check. There is no other
          // way into the form.
          onPressed: () => Navigator.of(context)
              .push(localeScopedRoute(const ShareCheckPage())),
          icon: const Icon(Icons.add),
          label: Text(hi ? 'खाना दें' : 'Give food'),
        ),
        body: ContentShell(
          maxWidth: 700,
          child: TabBarView(children: [
            ListView(
              padding: EdgeInsets.fromLTRB(pad, 12, pad, 96),
              children: [
                const _SafetyStrip(),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.place_outlined),
                    hintText: hi
                        ? 'अपना इलाका या शहर लिखें'
                        : 'Type your area or town',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) =>
                      setState(() => _area = v.trim().toLowerCase()),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<FoodPost>>(
                  stream: FoodBoardService.live(),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return _Empty(hi
                          ? 'बोर्ड लोड नहीं हुआ। इंटरनेट जाँचें।'
                          : 'Could not load the board. Check the internet.');
                    }
                    if (!snap.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final posts = snap.data!
                        .where((p) =>
                            _area.isEmpty ||
                            p.area.toLowerCase().contains(_area))
                        .toList();
                    if (posts.isEmpty) {
                      return _Empty(hi
                          ? 'अभी कोई खाना उपलब्ध नहीं। बाद में देखें।'
                          : 'Nothing available right now. Check back later.');
                    }
                    return Column(children: [
                      for (final p in posts)
                        _PostCard(post: p, myUid: auth.user?.uid),
                    ]);
                  },
                ),
              ],
            ),
            auth.isSignedIn
                ? _MyPosts(hi: hi)
                : _SignInPrompt(hi: hi),
          ]),
        ),
      ),
    );
  }
}

class _SafetyStrip extends StatelessWidget {
  const _SafetyStrip();

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        hi
            ? 'लेने से पहले: दिन में, किसी खुली जगह पर मिलें; अकेले न जाएँ। खाना '
                'ख़ुद देखें और सूँघें — शक हो तो न लें। खाने के पैसे कभी न दें; '
                'जो पैसे माँगे, उसकी रिपोर्ट करें।'
            : 'Before you collect: meet in daylight, somewhere open, and not '
                'alone. Look at and smell the food yourself — if in doubt, '
                'leave it. Never pay for food here; report anyone who asks.',
        style: TextStyle(
            fontSize: 12.8, height: 1.45, color: scheme.onTertiaryContainer),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      );
}

class _SignInPrompt extends StatelessWidget {
  final bool hi;
  const _SignInPrompt({required this.hi});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hi
                    ? 'खाना देने या लेने के लिए साइन इन करें। देखने के लिए नहीं।'
                    : 'Sign in to give or collect food. Looking needs no '
                        'account.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => context.push('/sign-in'),
                child: Text(hi ? 'साइन इन' : 'Sign in'),
              ),
            ],
          ),
        ),
      );
}

class _PostCard extends StatelessWidget {
  final FoodPost post;
  final String? myUid;
  const _PostCard({required this.post, required this.myUid});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final mine = post.uid == myUid;
    final claimedByMe = myUid != null && post.claimedBy == myUid;
    final claimed = post.status == 'claimed';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => _PostSheet(post: post, hi: hi),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Chip(_kindLabel(post.kind, hi)),
                  _Chip(hi
                      ? '${post.servings} लोगों के लिए'
                      : 'Serves ${post.servings}'),
                  _Chip(post.area, icon: Icons.place_outlined),
                  _Chip(_timeLeft(post.expiresAt, hi),
                      icon: Icons.timer_outlined),
                ],
              ),
              if (mine || claimed) ...[
                const SizedBox(height: 8),
                Text(
                  mine
                      ? (hi ? 'आपकी पोस्ट' : 'Your post')
                      : claimedByMe
                          ? (hi ? 'आपने लिया — संपर्क देखें' : 'You claimed this — tap for contact')
                          : (hi ? 'कोई ले चुका है' : 'Already claimed'),
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final IconData? icon;
  const _Chip(this.text, {this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: scheme.onSurfaceVariant),
            const SizedBox(width: 3),
          ],
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

/// Detail, claim, contact and report, in one sheet.
class _PostSheet extends StatefulWidget {
  final FoodPost post;
  final bool hi;
  const _PostSheet({required this.post, required this.hi});

  @override
  State<_PostSheet> createState() => _PostSheetState();
}

class _PostSheetState extends State<_PostSheet> {
  bool _busy = false;
  FoodContact? _contact;
  String? _message;
  late bool _claimedByMe =
      widget.post.claimedBy != null &&
          widget.post.claimedBy == FoodBoardService.myUid;

  @override
  void initState() {
    super.initState();
    if (_claimedByMe || widget.post.uid == FoodBoardService.myUid) {
      _loadContact();
    }
  }

  Future<void> _loadContact() async {
    try {
      final c = await FoodBoardService.contact(widget.post.id);
      if (mounted) setState(() => _contact = c);
    } catch (_) {}
  }

  Future<void> _claim() async {
    final hi = widget.hi;
    setState(() => _busy = true);
    try {
      final ok = await FoodBoardService.claim(widget.post.id);
      if (!mounted) return;
      if (ok) {
        _claimedByMe = true;
        await _loadContact();
      }
      setState(() {
        _busy = false;
        _message = ok
            ? null
            : (hi
                ? 'माफ़ कीजिए, किसी और ने पहले ले लिया।'
                : 'Sorry, someone else claimed it first.');
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = hi
            ? 'नहीं हो पाया। समय ख़त्म हो गया हो सकता है।'
            : 'That did not work. The listing may have expired.';
      });
    }
  }

  Future<void> _report() async {
    final hi = widget.hi;
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(hi ? 'रिपोर्ट क्यों?' : 'Why report this?'),
        children: [
          for (final r in reportReasons)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, r.$1),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(hi ? r.$3 : r.$2),
              ),
            ),
        ],
      ),
    );
    if (reason == null) return;
    try {
      await FoodBoardService.report(widget.post, reason);
      if (!mounted) return;
      setState(() => _message = hi
          ? 'रिपोर्ट मिल गई। धन्यवाद।'
          : 'Reported. Thank you.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = hi
          ? 'आप यह पोस्ट पहले ही रिपोर्ट कर चुके हैं।'
          : 'You have already reported this post.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hi = widget.hi;
    final p = widget.post;
    final signedIn = FoodBoardService.myUid != null;
    final mine = p.uid == FoodBoardService.myUid;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(p.title,
                style: const TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              '${_kindLabel(p.kind, hi)} · '
              '${hi ? '${p.servings} लोगों के लिए' : 'serves ${p.servings}'} · '
              '${p.area} · ${_timeLeft(p.expiresAt, hi)}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            if (p.verdict == ShareVerdict.soon) ...[
              const SizedBox(height: 10),
              Text(
                hi
                    ? 'देने वाले की जाँच में: इसे बहुत जल्दी खाना है।'
                    : "The giver's check said: this must be eaten very soon.",
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: scheme.error),
              ),
            ],
            const SizedBox(height: 14),
            const _SafetyStrip(),
            const SizedBox(height: 16),
            if (_contact != null)
              _ContactBox(contact: _contact!, hi: hi, mine: mine)
            else if (mine)
              const SizedBox.shrink()
            else if (!signedIn)
              FilledButton(
                onPressed: () {
                  // Grab the router before the sheet's context goes away.
                  final router = GoRouter.of(context);
                  Navigator.pop(context);
                  router.push('/sign-in');
                },
                child: Text(hi ? 'लेने के लिए साइन इन करें' : 'Sign in to claim'),
              )
            else if (p.status == 'open' && !p.expired)
              FilledButton.icon(
                onPressed: _busy ? null : _claim,
                icon: const Icon(Icons.volunteer_activism_outlined),
                label: Text(hi ? 'मैं लूँगा/लूँगी' : 'I will collect this'),
              )
            else
              Text(hi ? 'यह अब उपलब्ध नहीं है।' : 'This is no longer available.'),
            if (_message != null) ...[
              const SizedBox(height: 10),
              Text(_message!, style: TextStyle(color: scheme.primary)),
            ],
            if (signedIn && !mine) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _report,
                  icon: const Icon(Icons.flag_outlined),
                  label: Text(hi ? 'रिपोर्ट करें' : 'Report'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactBox extends StatelessWidget {
  final FoodContact contact;
  final bool hi;
  final bool mine;
  const _ContactBox(
      {required this.contact, required this.hi, required this.mine});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mine
                ? (hi ? 'आपने जो संपर्क दिया' : 'The contact you gave')
                : (hi ? 'देने वाले से संपर्क' : 'Contact the giver'),
            style: TextStyle(
                fontWeight: FontWeight.w800, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 8),
          if (contact.pickup.isNotEmpty)
            Text(contact.pickup,
                style: TextStyle(
                    height: 1.45, color: scheme.onPrimaryContainer)),
          const SizedBox(height: 10),
          if (!mine)
            FilledButton.icon(
              onPressed: () =>
                  launchUrl(Uri(scheme: 'tel', path: contact.phone)),
              icon: const Icon(Icons.phone),
              label: Text(contact.phone),
            )
          else
            Text(contact.phone,
                style: TextStyle(color: scheme.onPrimaryContainer)),
        ],
      ),
    );
  }
}

class _MyPosts extends StatelessWidget {
  final bool hi;
  const _MyPosts({required this.hi});

  Future<void> _confirmDelete(BuildContext context, FoodPost p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(hi ? 'पोस्ट मिटाएँ?' : 'Delete this post?'),
        content: Text(p.title),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(hi ? 'रहने दें' : 'Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(hi ? 'मिटाएँ' : 'Delete')),
        ],
      ),
    );
    if (ok == true) await FoodBoardService.delete(p.id);
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    return StreamBuilder<List<FoodPost>>(
      stream: FoodBoardService.mine(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final posts = snap.data!;
        if (posts.isEmpty) {
          return _Empty(hi
              ? 'आपने अभी कुछ पोस्ट नहीं किया।'
              : 'You have not posted anything yet.');
        }
        return ListView(
          padding: EdgeInsets.fromLTRB(pad, 12, pad, 96),
          children: [
            for (final p in posts)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(
                        p.expired
                            ? (hi ? 'समय ख़त्म — अब किसी को नहीं दिखती' : 'Expired — no longer shown')
                            : switch (p.status) {
                                'claimed' => hi
                                    ? 'किसी ने ले लिया — वे आपको फ़ोन करेंगे'
                                    : 'Claimed — they will call you',
                                'closed' => hi ? 'बंद' : 'Closed',
                                _ => hi
                                    ? 'खुली · ${_timeLeft(p.expiresAt, hi)}'
                                    : 'Open · ${_timeLeft(p.expiresAt, hi)}',
                              },
                      ),
                      if (p.hidden)
                        Text(
                          hi
                              ? 'रिपोर्ट के कारण छिपी हुई'
                              : 'Hidden after reports',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, children: [
                        if (p.status == 'claimed' && !p.expired)
                          OutlinedButton(
                            onPressed: () => FoodBoardService.release(p.id),
                            child: Text(hi
                                ? 'कोई नहीं आया — फिर खोलें'
                                : 'Nobody came — reopen'),
                          ),
                        if (p.status != 'closed' && !p.expired)
                          OutlinedButton(
                            onPressed: () => FoodBoardService.close(p.id),
                            child: Text(hi ? 'दे दिया — बंद करें' : 'Given — close'),
                          ),
                        TextButton(
                          onPressed: () => _confirmDelete(context, p),
                          child: Text(hi ? 'मिटाएँ' : 'Delete'),
                        ),
                      ]),
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

/// The posting form. Reached only from a passing share check, which hands
/// over its answers so the listing time is computed, not typed.
class PostFoodPage extends StatefulWidget {
  final FoodKind kind;
  final ShareVerdict verdict;
  final double hours;

  const PostFoodPage({
    super.key,
    required this.kind,
    required this.verdict,
    required this.hours,
  });

  @override
  State<PostFoodPage> createState() => _PostFoodPageState();
}

class _PostFoodPageState extends State<PostFoodPage> {
  final _title = TextEditingController();
  final _area = TextEditingController();
  final _phone = TextEditingController();
  final _pickup = TextEditingController();
  int _servings = 5;
  bool _pledge = false;
  bool _busy = false;
  String? _error;

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  @override
  void dispose() {
    _title.dispose();
    _area.dispose();
    _phone.dispose();
    _pickup.dispose();
    super.dispose();
  }

  /// Accepts "+91 98765 43210", "098765-43210" and the like.
  String? _cleanPhone(String raw) {
    var d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.length == 12 && d.startsWith('91')) d = d.substring(2);
    if (d.length == 11 && d.startsWith('0')) d = d.substring(1);
    return RegExp(r'^[6-9]\d{9}$').hasMatch(d) ? d : null;
  }

  Future<void> _submit() async {
    final hi = _hi;
    final phone = _cleanPhone(_phone.text);
    String? err;
    if (_title.text.trim().length < 3) {
      err = hi ? 'खाने का नाम लिखें।' : 'Say what the food is.';
    } else if (_area.text.trim().length < 2) {
      err = hi ? 'इलाका लिखें।' : 'Add your area.';
    } else if (phone == null) {
      err = hi
          ? 'सही 10 अंकों का मोबाइल नंबर डालें।'
          : 'Enter a valid 10-digit mobile number.';
    } else if (!_pledge) {
      err = hi ? 'ऊपर दी गई बात पर टिक करें।' : 'Tick the box above.';
    }
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FoodBoardService.create(
        title: _title.text.trim(),
        kind: widget.kind,
        servings: _servings,
        area: _area.text.trim(),
        verdict: widget.verdict,
        hours: widget.hours,
        phone: phone!,
        pickup: _pickup.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(hi ? 'पोस्ट हो गया।' : 'Posted.')));
      Navigator.of(context)
        ..pop()
        ..pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = hi
            ? 'पोस्ट नहीं हो पाया। इंटरनेट जाँचें और फिर कोशिश करें।'
            : 'Could not post. Check the internet and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hi = _hi;
    final pad = context.pagePadding;
    final auth = context.watch<AuthService>();
    final scheme = Theme.of(context).colorScheme;
    final mins = (widget.hours * 60).floor();
    final listed = mins >= 120
        ? (hi ? '${mins ~/ 60} घंटे' : '${mins ~/ 60} hours')
        : (hi ? '$mins मिनट' : '$mins minutes');

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? 'खाना दें' : 'Give food'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(2)),
        ),
      ),
      body: ContentShell(
        maxWidth: 640,
        child: !auth.isSignedIn
            ? _SignInPrompt(hi: hi)
            : ListView(
                padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hi
                          ? '${_kindLabel(widget.kind, hi)} · यह पोस्ट $listed तक '
                              'दिखेगी, फिर अपने आप हट जाएगी — क्योंकि उसके बाद '
                              'खाना सुरक्षित नहीं रहता।'
                          : '${_kindLabel(widget.kind, hi)} · This post will '
                              'show for $listed, then disappear by itself — '
                              'after that the food is no longer safe.',
                      style: TextStyle(
                          height: 1.45, color: scheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _title,
                    maxLength: 80,
                    decoration: InputDecoration(
                      labelText: hi ? 'क्या खाना है' : 'What food is it',
                      hintText: hi
                          ? 'जैसे: दाल-चावल, शादी से बचा, ढका हुआ'
                          : 'e.g. dal and rice from a wedding, covered',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                          child: Text(hi
                              ? 'कितने लोगों के लिए: $_servings'
                              : 'Serves about: $_servings')),
                      IconButton.outlined(
                        onPressed: _servings > 1
                            ? () => setState(() => _servings--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 6),
                      IconButton.outlined(
                        onPressed: _servings < 500
                            ? () => setState(() => _servings += _servings >= 20 ? 10 : 1)
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _area,
                    maxLength: 60,
                    decoration: InputDecoration(
                      labelText: hi ? 'इलाका / शहर' : 'Area / town',
                      helperText: hi
                          ? 'सबको दिखेगा। पूरा पता यहाँ न लिखें।'
                          : 'Everyone sees this. Do not put your full address here.',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [LengthLimitingTextInputFormatter(16)],
                    decoration: InputDecoration(
                      labelText: hi ? 'मोबाइल नंबर' : 'Mobile number',
                      helperText: hi
                          ? 'सिर्फ़ उसे दिखेगा जो खाना लेगा।'
                          : 'Shown only to the one person who claims it.',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pickup,
                    maxLength: 300,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: hi
                          ? 'कहाँ और कब लें (वैकल्पिक)'
                          : 'Where and when to collect (optional)',
                      helperText: hi
                          ? 'सिर्फ़ लेने वाले को दिखेगा। कोई सार्वजनिक जगह बेहतर है।'
                          : 'Shown only to the claimer. A public spot is best.',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _pledge,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (v) => setState(() => _pledge = v ?? false),
                    title: Text(
                      hi
                          ? 'मैंने जो बताया वह सच है। खाना परोसा नहीं गया, ढका रहेगा, '
                              'और मैं इसके लिए पैसे नहीं लूँगा/लूँगी।'
                          : 'What I said in the check is true. The food has not '
                              'been served, will stay covered, and I will not '
                              'ask for money.',
                      style: const TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: TextStyle(color: scheme.error)),
                  ],
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(hi ? 'पोस्ट करें' : 'Post it'),
                  ),
                ],
              ),
      ),
    );
  }
}
