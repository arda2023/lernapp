import 'package:go_router/go_router.dart';

import 'main_screen.dart';

/// Single route for now; feature routes get added as screens land.
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const MainScreen(),
    ),
  ],
);
