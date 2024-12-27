import 'package:flutter/material.dart';
import 'package:qr_hub/qr_hub.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Qr Hub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffFDB624)),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('fa', 'IR')
          // Add more supported locales if needed
        ],
      /*  builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: child!,
          );
        },*/
        routerConfig: RoutePages.router,
      );
}
