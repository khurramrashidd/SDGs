import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../i18n/locale_scope.dart';
import '../sdg/sdg_catalog.dart';

import '../../features/admin/admin_home_page.dart';
import '../../features/about/about_page.dart';
import '../../features/about/legal_page.dart';
import '../../features/auth/account_page.dart';
import '../../features/auth/forgot_password_page.dart';
import '../../features/auth/sign_in_page.dart';
import '../../features/auth/sign_up_page.dart';
import '../../core/sdg/sdg_roadmap.dart';
import '../../features/common/module_scaffold_page.dart';
import '../../features/home/home_page.dart';
import '../../features/notifications/notifications_page.dart';
import '../../features/sdg1_schemes/schemes_page.dart';
import '../../features/sdg2_food/food_home_page.dart';
import '../../features/sdg3_health/health_home_page.dart';
import '../../features/sdg4_scholarships/scholarships_page.dart';
import '../../features/sdg16_justice/justice_home_page.dart';
import '../../features/sdg8_work/work_home_page.dart';
import '../../features/sdg5_empower/empower_home_page.dart';
import '../../features/sdg6_water/water_home_page.dart';
import '../../features/sdg7_energy/energy_home_page.dart';
import '../../features/sdg9_enterprise/enterprise_home_page.dart';
import '../../features/settings/settings_page.dart';

/// A content route, wrapped so the screen can be read in another language
/// without changing the app language.
///
/// Only the SDG modules get this. Settings already owns the app-language
/// control, and a second language button there would be two controls for
/// overlapping jobs on one screen.
GoRoute _contentRoute(String path, Widget Function() build) => GoRoute(
      path: path,
      builder: (_, __) => LocaleScope(child: build()),
    );

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // The home grid names all 17 goals, so it is content too.
    _contentRoute('/', () => const HomePage()),

    // Auth - never a gate on browsing, only on acting.
    GoRoute(path: '/sign-in', builder: (_, __) => const SignInPage()),
    GoRoute(path: '/sign-up', builder: (_, __) => const SignUpPage()),
    GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordPage()),
    GoRoute(path: '/account', builder: (_, __) => const AccountPage()),

    GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
    GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsPage()),
    GoRoute(path: '/admin', builder: (_, __) => const AdminHomePage()),

    // Company and legal
    GoRoute(path: '/about', builder: (_, __) => const AboutPage()),
    GoRoute(path: '/terms', builder: (_, __) => const TermsPage()),
    GoRoute(path: '/privacy',
        builder: (_, __) => const PrivacyPolicyPage()),

    // ---- SDG modules ----
    _contentRoute('/sdg/1', () => const SchemesPage()),
    _contentRoute('/sdg/2', () => const FoodHomePage()),
    _contentRoute('/sdg/3', () => const HealthHomePage()),
    _contentRoute('/sdg/4', () => const ScholarshipsPage()),
    _contentRoute('/sdg/5', () => const EmpowerHomePage()),
    _contentRoute('/sdg/6', () => const WaterHomePage()),
    _contentRoute('/sdg/7', () => const EnergyHomePage()),
    _contentRoute('/sdg/8', () => const WorkHomePage()),
    _contentRoute('/sdg/9', () => const EnterpriseHomePage()),
    _contentRoute('/sdg/16', () => const JusticeHomePage()),

    // Goals 10-17. One route rather than nine: the plan for each lives in
    // kSdgRoadmap, so a locked tile explains what is coming instead of
    // showing a dead "coming soon" toast.
    GoRoute(
      path: '/sdg/planned/:goal',
      builder: (_, state) {
        final goal = int.tryParse(state.pathParameters['goal'] ?? '') ?? 0;
        return LocaleScope(
          child: ModuleScaffoldPage(
            goal: goal,
            titleKey: kSdgCatalog
                .firstWhere((e) => e.goal == goal,
                    orElse: () => kSdgCatalog.first)
                .titleKey,
            plannedFeatures: kSdgRoadmap[goal] ?? const [],
          ),
        );
      },
    ),
  ],
);
