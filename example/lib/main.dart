import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qr_hub/qr_hub.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'my_app.dart';

const String dsnSentry =
    'https://1ed3e58ad41e5f93a30ebdfbb32aa1eb@o4508677163646976.ingest.de.sentry.io/4508677165875280';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(QrCodeScanHistoryAdapter());
  Hive.registerAdapter(QrCodeGenerateHistoryAdapter());
  await SentryFlutter.init(
    (options) {
      options.dsn = dsnSentry;
      options.tracesSampleRate = 1;
      options.profilesSampleRate = 1;
    },
    appRunner: () => runApp(const Directionality(
      textDirection: TextDirection.rtl,
      child: MyApp(),
    )),
  );
}
