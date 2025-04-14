import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masarat_alnur/src/features/auth/data/auth_repository.dart';
// Import Screens (ensure these paths match your actual file locations)
import 'package:masarat_alnur/src/features/onboarding/presentation/onboarding_screen.dart'; // Main onboarding host screen
import 'package:masarat_alnur/src/features/main_app/presentation/main_screen.dart'; // Main app screen with BottomNav
import 'package:masarat_alnur/src/features/splash/presentation/splash_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Define App Routes Enum/Class
enum AppRoute {
  splash,
  onboarding, // Host for welcome, auth, nickname, congrats
  main,       // Host for home, profile etc.
}

// Provider for the GoRouter configuration
final goRouterProvider = Provider<GoRouter>((ref) {
  final authStateAsync = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/${AppRoute.splash.name}',
    debugLogDiagnostics: true,

    // Redirect logic - Simplified
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggingIn = state.matchedLocation == '/${AppRoute.onboarding.name}'; // Or specific auth route if nested
      final bool isSplash = state.matchedLocation == '/${AppRoute.splash.name}';

      // Handle auth state
      final String? redirectLocation = authStateAsync.when(
        data: (user) {
          // If logged out AND not already on the onboarding path, go to onboarding
          if (user == null) {
            return loggingIn ? null : '/${AppRoute.onboarding.name}';
          }
          // If logged in AND on splash or onboarding, redirect to main.
          // The main screen or its initial route will handle nickname check later.
          if (isSplash || loggingIn) {
            return '/${AppRoute.main.name}';
          }
          // Otherwise (logged in, already on main or other authenticated route), stay put.
          return null;
        },
        loading: () => isSplash ? null : '/${AppRoute.splash.name}', // Stay on splash if loading
        error: (err, stack) {
           print("Auth State Error in Redirect: $err");
           // On error, safest bet is to go to onboarding/auth flow
           return loggingIn ? null : '/${AppRoute.onboarding.name}';
        },
      );
      print("Redirect Decision: Current=${state.matchedLocation}, RedirectTo=$redirectLocation");
      return redirectLocation;
    },

    // Refresh based on auth state changes
    refreshListenable: GoRouterRefreshStream(ref.watch(authStateChangesProvider.stream)),

    // Define Routes
    routes: [
      GoRoute(
        path: '/${AppRoute.splash.name}',
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/${AppRoute.onboarding.name}', // Base path for onboarding flow
        name: AppRoute.onboarding.name,
        // We'll use nested routes for the onboarding steps for better structure
        builder: (context, state) => const OnboardingScreen(), // This screen will host the steps
        // TODO: Add nested routes for welcome, auth, nickname, congrats later
      ),
      GoRoute(
        path: '/${AppRoute.main.name}', // Base path for main app
        name: AppRoute.main.name,
        builder: (context, state) => const MainScreen(),
        // TODO: Add nested routes for Home, Profile etc. later
      ),
    ],
     errorBuilder: (context, state) => Scaffold( // Basic error screen
         body: Center(child: Text('Route not found: ${state.error}')),
      ),
  );
});

// --- Stream Wrapper for GoRouter Refresh ---
// (Required for refreshListenable)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}


// --- Main Application Widget ---
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'Masarat AlNur',
      localizationsDelegates: AppLocalizations.localizationsDelegates, // Use generated delegates
      supportedLocales: AppLocalizations.supportedLocales, // Use generated locales
      locale: const Locale('ar'), // Force Arabic
      theme: ThemeData(
         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
         // fontFamily: 'Tajawal', // Uncomment if font added
         useMaterial3: true,
         // Define consistent padding/margins maybe?
         // cardTheme: CardTheme(elevation: 2, margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
         // inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder())
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}