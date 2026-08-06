import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:chess_ritter/Pages/Gameboard.dart';
import 'package:chess_ritter/Pages/Settings.dart';
import 'package:chess_ritter/Pages/Start.dart';
import 'package:chess_ritter/state/chess_app_state.dart';
import 'package:chess_ritter/services/feedback_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await ChessAppState.instance.initialize();
  await FeedbackService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Chess Ritter',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'queen',
        scaffoldBackgroundColor: const Color(0xFF08080A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFDC3FDF),
          brightness: Brightness.dark,
        ),
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
