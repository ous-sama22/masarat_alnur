// lib/src/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masarat_alnur/src/features/auth/data/auth_repository.dart';
import 'package:masarat_alnur/src/features/auth/data/user_repository.dart';
import 'package:masarat_alnur/src/features/auth/domain/app_user.dart';
import 'package:masarat_alnur/src/features/content/domain/category.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Import Screens
import 'package:masarat_alnur/src/features/splash/presentation/splash_screen.dart';
import 'package:masarat_alnur/src/features/onboarding/presentation/welcome_screen.dart';
import 'package:masarat_alnur/src/features/auth/presentation/auth_screen_host.dart';
import 'package:masarat_alnur/src/features/onboarding/presentation/congrats_screen.dart';
import 'package:masarat_alnur/src/features/main_app/presentation/main_screen.dart';
import 'package:masarat_alnur/src/features/content/presentation/category_list_screen.dart';
import 'package:masarat_alnur/src/features/content/presentation/sub_category_list_screen.dart';
import 'package:masarat_alnur/src/features/content/data/content_repository.dart';

// --- App Routes ---
enum AppRoute {
  splash,
  // Onboarding steps
  onboardingWelcome,
  onboardingAuth,
  onboardingCongrats,
  // Main App
  main,
  // Content Routes
  categories,
  ongoingCategories,
  categorySubCategories,
  ongoingSubCategories,
  subCategoryTopics,
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final userRepo = ref.read(userRepositoryProvider);
  final contentRepo = ref.read(contentRepositoryProvider);

  return GoRouter(
    initialLocation: '/splash',
    navigatorKey: GlobalKey<NavigatorState>(),
    debugLogDiagnostics: true,

    redirect: (BuildContext context, GoRouterState state) async {
      final bool loading = authState is AsyncLoading;
      final bool loggedIn = authState.valueOrNull != null;
      final String? currentUserId = authState.valueOrNull?.uid;

      final bool goingToSplash = state.matchedLocation == '/splash';
      final bool inAuthFlow = state.matchedLocation.startsWith('/onboarding');

      if (loading) {
        return goingToSplash ? null : '/splash';
      }

      if (!loggedIn) {
        return inAuthFlow ? null : '/onboarding/welcome';
      }

      // --- User is Logged In ---
      if (currentUserId != null) {
        final userProfile = await userRepo.fetchUser(currentUserId);
        
        if (userProfile != null) {
          // User exists in Firestore, go to main or congrats based on current location
          if (state.matchedLocation == '/onboarding/auth') {
            return '/onboarding/congrats';
          } else if (goingToSplash || (inAuthFlow && state.matchedLocation != '/onboarding/congrats')) {
            return '/main';
          }
          return null; // Stay on current screen
        } else {
          return '/onboarding/auth';
        }
      }
      
      return '/onboarding/welcome';
    },

    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding/welcome',
        name: AppRoute.onboardingWelcome.name,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/auth',
        name: AppRoute.onboardingAuth.name,
        builder: (context, state) => const AuthScreenHost(),
      ),
      GoRoute(
        path: '/onboarding/congrats',
        name: AppRoute.onboardingCongrats.name,
        builder: (context, state) => const CongratsScreen(),
      ),
      GoRoute(
        path: '/main',
        name: AppRoute.main.name,
        builder: (context, state) => const MainScreen(),
      ),
      // Content Routes
      GoRoute(
        path: '/categories',
        name: AppRoute.categories.name,
        builder: (context, state) => const CategoryListScreen(),
      ),
      GoRoute(
        path: '/categories/ongoing',
        name: AppRoute.ongoingCategories.name,
        builder: (context, state) => const CategoryListScreen(ongoingOnly: true),
      ),
      GoRoute(
        path: '/categories/:categoryId/subcategories',
        name: AppRoute.categorySubCategories.name,
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          return FutureBuilder<Category?>(
            future: contentRepo.fetchCategory(categoryId),
            builder: (context, snapshot) => SubCategoryListScreen(
              categoryId: categoryId,
              categoryName: snapshot.data?.title_ar,
            ),
          );
        },
      ),
      GoRoute(
        path: '/subcategories/ongoing',
        name: AppRoute.ongoingSubCategories.name,
        builder: (context, state) => const SubCategoryListScreen(ongoingOnly: true),
      ),
      // Topic list route placeholder
      GoRoute(
        path: '/subcategories/:subCategoryId/topics',
        name: AppRoute.subCategoryTopics.name,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('المواضيع'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(child: Text('قريباً')), // Coming Soon
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

// --- Main Application Widget (Updated for Localization) ---
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'Masarat AlNur',

      // --- Localization Setup ---
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar'),
      // --- End Localization Setup ---

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}