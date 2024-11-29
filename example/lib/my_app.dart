import 'package:flutter/material.dart';
import 'package:qr_hub/qr_hub.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Qr Hub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('fa', 'IR'), // Persian locale
          // Add more supported locales if needed
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        routerConfig: RoutePages.router,
      );
}
