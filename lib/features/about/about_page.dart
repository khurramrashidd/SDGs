import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ContentShell(
        maxWidth: 640,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 24, pad, 20),
          children: [
            const Center(child: _AppMark(size: 92)),
            const SizedBox(height: 18),
            Center(
              child: Text(
                Brand.appName,
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Version ${Brand.appVersion}',
                style: TextStyle(fontSize: 14, color: scheme.outline),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Practical tools for the 17 UN Sustainable\nDevelopment Goals',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: scheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 28),

            _Card(children: [
              _Row(
                icon: Icons.business_outlined,
                title: 'Designed and developed by',
                subtitle: Brand.companyName,
              ),
              const _Line(),
              _Row(
                icon: Icons.mail_outline,
                title: 'Contact',
                subtitle: Brand.supportEmail,
                action: _ActionKind.external,
                onTap: () => _mail(context),
              ),
              const _Line(),
              _Row(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                action: _ActionKind.internal,
                onTap: () => context.push('/terms'),
              ),
              const _Line(),
              _Row(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                action: _ActionKind.internal,
                onTap: () => context.push('/privacy'),
              ),
            ]),

            const SizedBox(height: 22),

            _Card(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                child: Text(
                  'Follow ${Brand.companyName}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
              const _Social(
                icon: Icons.language,
                tint: const Color(0xFF3B82F6),
                title: 'Website',
                subtitle: CompanyLinks.websiteLabel,
                url: CompanyLinks.website,
              ),
              const _Social(
                icon: Icons.play_arrow_rounded,
                tint: const Color(0xFFEF4444),
                title: 'YouTube',
                subtitle: CompanyLinks.youtubeLabel,
                url: CompanyLinks.youtube,
              ),
              const _Social(
                icon: Icons.camera_alt_outlined,
                tint: const Color(0xFFEC4899),
                title: 'Instagram',
                subtitle: CompanyLinks.instagramLabel,
                url: CompanyLinks.instagram,
              ),
              const _Social(
                icon: Icons.chat_bubble_outline,
                tint: const Color(0xFF22C55E),
                title: 'WhatsApp channel',
                subtitle: CompanyLinks.whatsappLabel,
                url: CompanyLinks.whatsapp,
              ),
              const _Social(
                icon: Icons.work_outline,
                tint: const Color(0xFF0A66C2),
                title: 'LinkedIn',
                subtitle: CompanyLinks.linkedinLabel,
                url: CompanyLinks.linkedin,
              ),
              const SizedBox(height: 8),
            ]),

            const SizedBox(height: 26),
            Center(
              child: Text(
                '© ${DateTime.now().year} ${Brand.companyName}',
                style: TextStyle(fontSize: 12, color: scheme.outline),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                Brand.tagline,
                style: TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: scheme.outline),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _mail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: Brand.supportEmail,
      queryParameters: {'subject': '${Brand.appName} — feedback'},
    );
    try {
      final ok = await launchUrl(uri);
      if (ok) return;
    } catch (_) {
      // fall through
    }
    // Plenty of devices have no mail app configured. Copying beats a dead
    // tap with no explanation.
    await Clipboard.setData(
        const ClipboardData(text: Brand.supportEmail));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No mail app found. Address copied instead.')),
      );
    }
  }
}

/// The app mark, drawn in code - same geometry as brand/icon_badge.svg.
class _AppMark extends StatelessWidget {
  final double size;
  const _AppMark({required this.size});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: CustomPaint(
          painter: const _MarkPainter(dot: Brand.accent)),
    );
  }
}

class _MarkPainter extends CustomPainter {
  final Color dot;
  const _MarkPainter({required this.dot});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(s * 0.45, s * 0.56), radius: s * 0.20),
      -0.26,
      5.24, // 300 degrees
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.105
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
        Offset(s * 0.70, s * 0.31), s * 0.105, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.dot != dot;
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
      child: Column(children: children),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line();
  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
      );
}

enum _ActionKind { none, internal, external }

class _Row extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final _ActionKind action;
  final VoidCallback? onTap;

  const _Row({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action = _ActionKind.none,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: scheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
            if (action == _ActionKind.internal)
              Icon(Icons.chevron_right, color: scheme.outline),
            if (action == _ActionKind.external)
              Icon(Icons.open_in_new, size: 19, color: scheme.outline),
          ],
        ),
      ),
    );
  }
}

class _Social extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final String url;

  const _Social({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _open(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 22, color: tint),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 1),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.open_in_new, size: 18, color: scheme.outline),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    try {
      final ok = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {
      // fall through
    }
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $title. Link copied.')),
      );
    }
  }
}
