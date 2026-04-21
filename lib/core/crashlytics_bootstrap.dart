import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Initializes Firebase and wires framework and async errors to Crashlytics.
///
/// Call after [WidgetsFlutterBinding.ensureInitialized].
///
/// Crashlytics upload is off in debug builds unless [forceEnableCollection] is
/// true. Analytics stays enabled in debug so Realtime / DebugView work during
/// `flutter run`; disable collection in code only if you need that.
Future<void> initializeFirebaseAndCrashlytics({
  bool forceEnableCollection = false,
}) async {
  await Firebase.initializeApp();

  final collectCrashlytics = forceEnableCollection || !kDebugMode;
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(collectCrashlytics);
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

/// Breadcrumb-style log line attached to the next crash or non-fatal report.
void crashlyticsLog(String message) {
  FirebaseCrashlytics.instance.log(message);
}

/// Example: report a caught exception as non-fatal (app keeps running).
///
/// Use this pattern in `catch` blocks for errors you handle in UI but still
/// want visibility on in Crashlytics.
Future<void> reportExampleNonFatalError() async {
  try {
    throw StateError('Example non-fatal error for Crashlytics');
  } catch (e, st) {
    await FirebaseCrashlytics.instance.recordError(
      e,
      st,
      reason: 'reportExampleNonFatalError demo',
      fatal: false,
    );
  }
}
