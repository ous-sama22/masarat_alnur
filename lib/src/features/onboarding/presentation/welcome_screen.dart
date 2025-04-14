import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masarat_alnur/src/app.dart'; // For AppRoute
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea( // Use SafeArea
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons
            children: [
              // TODO: Add your App Logo Widget here
              Icon(Icons.lightbulb_outline, size: 100, color: colorScheme.primary),
              const SizedBox(height: 32),
              Text(
                l10n.welcomeMessage,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.welcomeTagline,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              const Spacer(), // Push button to bottom
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                // Navigate to the Auth step
                onPressed: () => context.goNamed(AppRoute.onboardingAuth.name),
                child: Text(l10n.startButton),
              ),
              const SizedBox(height: 20), // Spacing at bottom
            ],
          ),
        ),
      ),
    );
  }
}