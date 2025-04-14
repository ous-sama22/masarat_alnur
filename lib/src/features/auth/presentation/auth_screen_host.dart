import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masarat_alnur/src/app.dart'; // For AppRoute
import 'package:masarat_alnur/src/features/auth/presentation/login_view.dart'; // Create this widget
import 'package:masarat_alnur/src/features/auth/presentation/signup_view.dart'; // Create this widget
import 'package:masarat_alnur/src/features/auth/presentation/auth_view_model.dart'; // Import ViewModel
import 'package:masarat_alnur/src/utils/async_value_ui.dart'; // Create this helper
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthScreenHost extends ConsumerStatefulWidget {
  const AuthScreenHost({super.key});

  @override
  ConsumerState<AuthScreenHost> createState() => _AuthScreenHostState();
}

class _AuthScreenHostState extends ConsumerState<AuthScreenHost>
    with SingleTickerProviderStateMixin { // For TabController
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
     // Reset state when entering auth screen?
     // WidgetsBinding.instance.addPostFrameCallback((_) {
     //   ref.read(authViewModelProvider.notifier).resetUiStateToIdle();
     // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // --- Listen to ViewModel state for navigation / errors ---
    ref.listen<AuthUiState>(authViewModelProvider, (_, state) { // Listen to state provider
      // Show snackbar on error
       state.showSnackBarOnError(context); // Use extension method

      // Navigate on success state AFTER auth
      if (state is AuthUiAuthSuccessful) {
        // Auth is done (login or signup), move to congrats screen
        context.goNamed(AppRoute.onboardingCongrats.name);
        // Reset state after handling navigation
        ref.read(authViewModelProvider.notifier).resetUiStateToIdle();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle), // Or specific auth title
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.loginTitle),
            Tab(text: l10n.signupTitle),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Pass the callback to switch tabs
            LoginView(onGoToSignUp: () => _tabController.animateTo(1)),
            SignUpView(onGoToSignIn: () => _tabController.animateTo(0)),
          ],
        ),
      ),
    );
  }
}

// TODO: Create LoginView and SignUpView widgets in separate files
// TODO: Create AuthViewModel and AuthUiState (with AuthSuccessful state)
// TODO: Create AsyncValueUI helper extension