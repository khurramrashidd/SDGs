import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// IBTIDAA TECH BRAND
///
/// >>> THIS IS THE ONLY FILE YOU EDIT TO RE-SKIN THE WHOLE APP. <<<
///
/// These are placeholder values until Laiq sends the real ibtidaatech.com
/// palette. Replace the four hex codes below and every screen, button, tile
/// and dialog in the app updates automatically. Nothing else needs touching.
/// ---------------------------------------------------------------------------
class Brand {
  const Brand._();

  /// Primary brand colour - app bars, primary buttons, active states.
  static const Color primary = Color(0xFF0E6E6E);

  /// Secondary brand colour - supporting surfaces and highlights.
  static const Color secondary = Color(0xFF14919B);

  /// Accent - call-to-action, badges, "new" markers.
  static const Color accent = Color(0xFFF2A93B);

  /// Deep neutral used for headings in light mode.
  static const Color ink = Color(0xFF14231F);

  static const String companyName = 'Ibtidaa Tech';
  static const String tagline = 'From Beginning to Impact';
  static const String supportEmail = 'ibtidaatech@gmail.com';

  static const String appName = 'SDG App';

  /// Shown in the drawer and on the About page.
  ///
  /// Kept in sync with `version:` in pubspec.yaml by hand. The alternative is
  /// the package_info_plus plugin, which reads it at runtime - not worth an
  /// extra native dependency for one string.
  static const String appVersion = '1.0.0';
}

/// Where the company lives online.
///
/// Carried over from the Ibtidaa Tech apps already published. Change a handle
/// here and every link in the app follows.
class CompanyLinks {
  const CompanyLinks._();

  static const String website = 'https://ibtidaatech.com';
  static const String websiteLabel = 'ibtidaatech.com';

  static const String youtube = 'https://youtube.com/@IbtidaaTech';
  static const String youtubeLabel = '@IbtidaaTech';

  static const String instagram = 'https://instagram.com/ibtidaatech';
  static const String instagramLabel = '@ibtidaatech';

  /// Replace with the real invite link from WhatsApp → Channel → Share.
  static const String whatsapp = 'https://whatsapp.com/channel/';
  static const String whatsappLabel = 'Ibtidaa Tech';

  static const String linkedin =
      'https://www.linkedin.com/company/ibtidaatech';
  static const String linkedinLabel = 'Ibtidaa Tech';

  /// Must be a publicly reachable page before the app can go on Play Store -
  /// Google requires a privacy policy URL on the store listing, and an
  /// in-app page alone does not satisfy it.
  static const String privacyPolicy = 'https://ibtidaatech.com/privacy';
}

/// The 17 official UN SDG colours. Used ONLY as accents - a thin stripe on a
/// tile, a small dot, a chip border - never as the dominant surface colour.
/// Decision from planning: Ibtidaa brand leads, SDG colours accent.
class SdgColors {
  const SdgColors._();

  static const Map<int, Color> byGoal = {
    1: Color(0xFFE5243B), // No Poverty
    2: Color(0xFFDDA63A), // Zero Hunger
    3: Color(0xFF4C9F38), // Good Health
    4: Color(0xFFC5192D), // Quality Education
    5: Color(0xFFFF3A21), // Gender Equality
    6: Color(0xFF26BDE2), // Clean Water
    7: Color(0xFFFCC30B), // Affordable Energy
    8: Color(0xFFA21942), // Decent Work
    9: Color(0xFFFD6925), // Industry & Innovation
    10: Color(0xFFDD1367), // Reduced Inequalities
    11: Color(0xFFFD9D24), // Sustainable Cities
    12: Color(0xFFBF8B2E), // Responsible Consumption
    13: Color(0xFF3F7E44), // Climate Action
    14: Color(0xFF0A97D9), // Life Below Water
    15: Color(0xFF56C02B), // Life on Land
    16: Color(0xFF00689D), // Peace & Justice
    17: Color(0xFF19486A), // Partnerships
  };

  static Color of(int goal) => byGoal[goal] ?? Brand.primary;
}

/// Accent choices the user can pick in Settings.
/// Decision from planning: user can choose theme AND font colour.
class AccentOption {
  final String id;
  final String label;
  final Color color;
  const AccentOption(this.id, this.label, this.color);
}

const List<AccentOption> kAccentOptions = [
  AccentOption('brand', 'Ibtidaa Teal', Brand.primary),
  AccentOption('indigo', 'Indigo', Color(0xFF3F51B5)),
  AccentOption('emerald', 'Emerald', Color(0xFF0E8A5F)),
  AccentOption('amber', 'Amber', Color(0xFFCC8400)),
  AccentOption('rose', 'Rose', Color(0xFFBE3455)),
  AccentOption('slate', 'Slate', Color(0xFF455A64)),
];

/// Font-size steps the user can pick. Important for the rural / low-literacy
/// audience - bigger text is a genuine accessibility need, not a nicety.
class TextScaleOption {
  final String id;
  final String label;
  final double scale;
  const TextScaleOption(this.id, this.label, this.scale);
}

const List<TextScaleOption> kTextScaleOptions = [
  TextScaleOption('small', 'Small', 0.9),
  TextScaleOption('normal', 'Normal', 1.0),
  TextScaleOption('large', 'Large', 1.15),
  TextScaleOption('xlarge', 'Extra large', 1.35),
];
