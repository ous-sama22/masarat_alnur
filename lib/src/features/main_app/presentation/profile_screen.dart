import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masarat_alnur/src/features/auth/data/auth_repository.dart';
import 'package:masarat_alnur/src/features/auth/data/user_repository.dart';
import 'package:masarat_alnur/src/features/content/data/content_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileStreamProvider);
    final userProgressAsync = ref.watch(userProgressStreamProvider);
    final isAdminAsync = ref.watch(isCurrentUserAdminProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Profile Section
              userProfileAsync.when(
                data: (userProfile) => Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userProfile?.displayName ?? '',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => const Text('خطأ في تحميل الملف الشخصي'),
              ),
              const SizedBox(height: 32),

              // Progress Statistics Section
              userProgressAsync.when(
                data: (progress) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تقدمك',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _StatisticTile(
                          icon: Icons.check_circle_outline,
                          title: l10n.profileTopicsCompletedLabel,
                          value: progress?.completedTopicIds.length ?? 0,
                        ),
                        const Divider(),
                        _StatisticTile(
                          icon: Icons.folder_open,
                          title: l10n.profileSubCategoriesCompletedLabel,
                          value: progress?.completedSubCategoryIds.length ?? 0,
                        ),
                        const Divider(),
                        _StatisticTile(
                          icon: Icons.category,
                          title: l10n.profileCategoriesCompletedLabel,
                          value: progress?.completedCategoryIds.length ?? 0,
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => const Text('خطأ في تحميل التقدم'),
              ),

              const Spacer(),

              // Admin Section
              isAdminAsync.when(
                data: (isAdmin) => isAdmin
                    ? Column(
                        children: [
                          FilledButton.icon(
                            onPressed: () {
                              ref.read(contentRepositoryProvider).generateSampleData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم إنشاء البيانات التجريبية')),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('إنشاء بيانات تجريبية'),
                          ),
                          const SizedBox(height: 16),
                        ],
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Action Buttons
              FilledButton.icon(
                onPressed: () {
                  // TODO: Implement rate us functionality
                },
                icon: const Icon(Icons.star),
                label: Text(l10n.rateUsButton),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) {
                    context.go('/onboarding/welcome');
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(l10n.logoutButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatisticTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;

  const _StatisticTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}