/// One piece of advice a decision tool hands back.
///
/// Pure Dart, no Flutter, so the tool logic that builds these can be read
/// and checked on its own. [toRow] gives the same shape as a content
/// dataset row, so results render with the shared GuideCard (title, body,
/// official link, and a call button when [phone] is set).
class Advice {
  final String title;
  final String titleHi;
  final String body;
  final String bodyHi;

  /// Official page the reader can check this against. Always https.
  final String source;

  /// Digits only, or empty.
  final String phone;

  const Advice({
    required this.title,
    required this.titleHi,
    required this.body,
    required this.bodyHi,
    required this.source,
    this.phone = '',
  });

  Map<String, dynamic> toRow() => {
        'title': title,
        'titleHi': titleHi,
        'body': body,
        'bodyHi': bodyHi,
        'source': source,
        if (phone.isNotEmpty) 'phone': phone,
      };
}
