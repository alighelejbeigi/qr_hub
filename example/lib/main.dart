import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qr_hub/qr_hub.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'my_app.dart';

/*
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(QrCodeScanHistoryAdapter());
  Hive.registerAdapter(QrCodeGenerateHistoryAdapter());
  runApp(const MyApp());
}
*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(QrCodeScanHistoryAdapter());
  Hive.registerAdapter(QrCodeGenerateHistoryAdapter());
  Hive.registerAdapter(UserIdAdapter());
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://1ed3e58ad41e5f93a30ebdfbb32aa1eb@o4508677163646976.ingest.de.sentry.io/4508677165875280';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(const MyApp()),
  );

  // or define SENTRY_DSN via Dart environment variable (--dart-define)
}
