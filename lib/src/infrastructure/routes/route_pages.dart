import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../pages/home_page/commons/home_page_bindings.dart';
import '../../pages/home_page/view/home_page.dart';
import '../../pages/home_page/view/widget/QRCodeCamera.dart';
import '../../pages/splash_screen/commons/splash_bindings.dart';
import '../../pages/splash_screen/view/splash_screen.dart';
import 'route_names.dart';

class RoutePages {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splashPage,
    routes: [
      GoRoute(
        path: RouteNames.splashPage,
        pageBuilder: (context, state) {
          // Initialize bindings here
          SplashBindings().dependencies();
          return const MaterialPage(
            child: SplashScreen(),
          );
        },
      ),
      GoRoute(
        path: RouteNames.homePage,
        pageBuilder: (context, state) {
          // Initialize bindings here
          HomePageBindings().dependencies();
          return const MaterialPage(
            child: HomePage(),
          );
        },
      ),
    ],
  );
}
