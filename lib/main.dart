import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/core/services/local_notification_service.dart';
import 'package:dukaan_ai/core/services/notification_service.dart';
import 'package:dukaan_ai/core/router/app_router.dart';
import 'package:dukaan_ai/core/theme/app_theme.dart';
import 'package:dukaan_ai/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    // duplicate-app is thrown on hot restart because native Firebase
    // is already initialised — safe to ignore.
    if (e.code != 'duplicate-app') rethrow;
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // DEV ONLY: best-effort anonymous sign-in for SKIP_AUTH local runs.
  if (const bool.fromEnvironment('SKIP_AUTH') &&
      FirebaseService.currentUserId == null) {
    try {
      await FirebaseService.auth.signInAnonymously();
      debugPrint(
        '[DEV] SKIP_AUTH anonymous sign-in -> ${FirebaseService.currentUserId}',
      );
    } catch (error) {
      debugPrint('[DEV] SKIP_AUTH anonymous sign-in failed: $error');
    }
  }

  await NotificationService.init();
  await LocalNotificationService.instance.initialize();

  runApp(
    const ProviderScope(
      child: DukaanApp(),
    ),
  );
}

class DukaanApp extends ConsumerWidget {
  const DukaanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
    );
  }
}
