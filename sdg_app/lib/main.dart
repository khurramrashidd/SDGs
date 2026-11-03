import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/i18n/strings.dart';
import 'core/router/app_router.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/admin/admin_service.dart';
import 'core/theme/settings_controller.dart';
import 'features/sdg4_scholarships/student_profile.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final settings = SettingsController();
  await settings.load();

  runApp(SdgApp(settings: settings));
}

class SdgApp extends StatelessWidget {
  final SettingsController settings;
  const SdgApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => StudentProfileStore()..load()),
        ChangeNotifierProvider(create: (_) => AdminService()..refresh()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, s, _) {
          return MaterialApp.router(
            title: 'SDG App',
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,

            theme: AppTheme.light(s.accentColor),
            darkTheme: AppTheme.dark(s.accentColor),
            themeMode: s.themeMode,

            locale: s.locale,
            supportedLocales: S.supportedLocales,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // The user's chosen text size is applied globally rather than
            // per-widget, so one setting scales the whole app.
            builder: (context, child) => MediaQuery.withClampedTextScaling(
              minScaleFactor: s.textScale,
              maxScaleFactor: s.textScale,
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
