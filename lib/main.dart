import 'package:chess_game/Pages/Settings.dart';
import 'package:chess_game/Pages/Start.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'Gameboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/Start',
  routes: <RouteBase>[
    GoRoute(
      name: 'Start',
      path: '/Start',
      builder: (context, state) => const Start(),
      pageBuilder: (context, state) {
        return CustomTransitionPage<void>(
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          key: state.pageKey,
          child: const Start(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
            opacity: fadeInTransition.animate(animation),
            child: child,
          ),
        );
      },
    ),
    GoRoute(
      name: 'Gameboard',
      path: '/Gameboard',
      builder: (context, state) => const GameBoard(),
      pageBuilder: (context, state) {
        return CustomTransitionPage<void>(
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          key: state.pageKey,
          child: const GameBoard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
            opacity: fadeInTransition.animate(animation),
            child: child,
          ),
        );
      },
    ),
    GoRoute(
      name: 'Settings',
      path: '/Settings',
      builder: (context, state) => const Settings(),
      pageBuilder: (context, state) {
        return CustomTransitionPage<void>(
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          key: state.pageKey,
          child: const Settings(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
            opacity: fadeInTransition.animate(animation),
            child: child,
          ),
        );
      },
    ),
  ],
);

final Animatable<Offset> slideInTransition = Tween<Offset>(
  begin: Offset(-30.0, 0.0),
  end: Offset.zero,
).chain(CurveTween(curve: Easing.legacy));
final Animatable<Offset> slideInTransition2 = Tween<Offset>(
  begin: Offset(30.0, 0.0),
  end: Offset.zero,
).chain(CurveTween(curve: Easing.legacy));

final Animatable<double> fadeInTransition = CurveTween(
  curve: Easing.legacyDecelerate,
).chain(CurveTween(curve: const Interval(0.3, 1.0)));
