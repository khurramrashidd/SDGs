import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../i18n/locale_scope.dart';
import '../widgets/goal_app.dart';
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
import '../../features/search/search_page.dart';
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
    GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
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
    // One route for all seventeen. Each goal draws itself from its own
    // issue list, so a new goal needs no new route and no new home screen.
    //
    // `?issue=g3i02` opens the goal with that tool already on screen,
    // which is how search and a saved bookmark get the user somewhere
    // useful without dropping them on a page with no way back.
    GoRoute(
      path: '/sdg/:goal',
      builder: (_, state) {
        final goal = int.tryParse(state.pathParameters['goal'] ?? '') ?? 1;
        if (goal < 1 || goal > 17) return const HomePage();
        return LocaleScope(
          child: GoalApp(
            goal: goal,
            openIssueId: state.uri.queryParameters['issue'],
          ),
        );
      },
    ),

    // Every goal is live now; this route stays so an old link to a planned
    // goal still opens its roadmap rather than a blank error.
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
