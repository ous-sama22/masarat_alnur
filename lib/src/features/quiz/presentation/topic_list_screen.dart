import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masarat_alnur/src/features/quiz/data/quiz_repository.dart';
import 'package:masarat_alnur/src/features/content/domain/topic.dart';
import 'package:masarat_alnur/src/features/quiz/domain/quiz_progress.dart';
import 'package:masarat_alnur/src/features/auth/data/auth_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TopicListScreen extends ConsumerWidget {
  final String subCategoryId;
  final String? subCategoryName;

  const TopicListScreen({
    super.key,
    required this.subCategoryId,
    this.subCategoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final topicsAsync = ref.watch(topicsStreamProvider(subCategoryId));
    final currentUser = ref.watch(authStateChangesProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(subCategoryName ?? l10n.topicsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: topicsAsync.when(
        data: (topics) => topics.isEmpty
            ? Center(
                child: Text(
                  'لا توجد مواضيع متاحة',  // No topics available
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  if (currentUser != null) {
                    return _TopicProgressCard(
                      topic: topic,
                      userId: currentUser.uid,
                    );
                  }
                  return _TopicCard(topic: topic);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final Topic topic;

  const _TopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/topics/${topic.id}/quiz'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic.title_ar,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (topic.description_ar.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  topic.description_ar,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicProgressCard extends ConsumerWidget {
  final Topic topic;
  final String userId;

  const _TopicProgressCard({
    required this.topic,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(
      quizProgressStreamProvider(userId, topic.id),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/topics/${topic.id}/quiz'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      topic.title_ar,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  progressAsync.when(
                    data: (progress) {
                      if (progress == null) {
                        return const Icon(Icons.play_circle_outline);
                      }
                      switch (progress.status) {
                        case QuizStatus.NOT_STARTED:
                          return const Icon(Icons.play_circle_outline);
                        case QuizStatus.IN_PROGRESS:
                          return const Icon(Icons.pause_circle_outline);
                        case QuizStatus.COMPLETED:
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${progress.score}%',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle_outline),
                            ],
                          );
                      }
                    },
                    loading: () => const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => const Icon(Icons.error_outline),
                  ),
                ],
              ),
              if (topic.description_ar.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  topic.description_ar,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}