import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masarat_alnur/src/features/auth/data/auth_repository.dart';
import 'package:masarat_alnur/src/features/auth/data/user_repository.dart';

class CongratsScreen extends ConsumerWidget {
  const CongratsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileStreamProvider);
    final fbAuth = ref.watch(firebaseAuthProvider);
    
    // Get Firebase metadata
    final fbUser = fbAuth.currentUser;
    final isNewUser = fbUser != null && 
        fbUser.metadata.creationTime?.isAtSameMomentAs(
          fbUser.metadata.lastSignInTime ?? DateTime.now()
        ) == true;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isNewUser ? 'مرحباً!' : 'مرحباً بعودتك!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              userProfileAsync.when(
                data: (userProfile) => Text(
                  isNewUser 
                    ? 'تم إنشاء حسابك بنجاح ${userProfile?.displayName ?? ""}'
                    : 'نحن سعداء بعودتك ${userProfile?.displayName ?? ""}',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('حدث خطأ: $error'),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => context.go('/main'),
                child: const Text('متابعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}