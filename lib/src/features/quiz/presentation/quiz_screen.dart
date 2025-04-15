import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masarat_alnur/src/features/quiz/data/quiz_repository.dart';
import 'package:masarat_alnur/src/features/quiz/domain/quiz_question.dart';
import 'package:masarat_alnur/src/features/quiz/domain/quiz_progress.dart';
import 'package:masarat_alnur/src/features/auth/data/auth_repository.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String topicId;

  const QuizScreen({
    super.key,
    required this.topicId,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late PageController _pageController;
  Map<String, int> _answers = {};
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submitAnswer(String questionId, int selectedIndex) async {
    final currentUser = ref.read(authStateChangesProvider).value;
    if (currentUser == null) return;

    setState(() {
      _answers[questionId] = selectedIndex;
    });

    await ref
        .read(quizRepositoryProvider)
        .saveAnswer(currentUser.uid, questionId, selectedIndex);
  }

  Future<void> _submitQuiz() async {
    final currentUser = ref.read(authStateChangesProvider).value;
    if (currentUser == null) return;

    await ref
        .read(quizRepositoryProvider)
        .submitQuiz(currentUser.uid, widget.topicId, _answers);

    setState(() {
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsStreamProvider(widget.topicId));
    final currentUser = ref.watch(authStateChangesProvider).value;
    final progressAsync = currentUser != null
        ? ref.watch(quizProgressStreamProvider(currentUser.uid, widget.topicId))
        : const AsyncValue.data(null);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('الاختبار'), // Quiz
      ),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(
              child: Text('لا توجد أسئلة متاحة'), // No questions available
            );
          }

          return Column(
            children: [
              LinearProgressIndicator(
                value: (_answers.length) / questions.length,
                backgroundColor: Colors.grey[200],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return _QuestionCard(
                      question: question,
                      selectedAnswer: _answers[question.id],
                      showCorrectAnswer: _showResults,
                      onAnswerSelected: (selectedIndex) {
                        _submitAnswer(question.id, selectedIndex);
                        if (index < questions.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_pageController.hasClients &&
                        _pageController.page?.toInt() != 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text('السابق'), // Previous
                        ),
                      ),
                    if (_pageController.hasClients &&
                        _pageController.page?.toInt() != 0)
                      const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: _answers.length == questions.length &&
                                !_showResults
                            ? _submitQuiz
                            : null,
                        child: Text(_showResults ? 'تم' : 'إرسال'), // Done : Submit
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final int? selectedAnswer;
  final bool showCorrectAnswer;
  final ValueChanged<int>? onAnswerSelected;

  const _QuestionCard({
    required this.question,
    this.selectedAnswer,
    this.showCorrectAnswer = false,
    this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question_ar,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          ...List.generate(
            question.options_ar.length,
            (index) {
              final isSelected = selectedAnswer == index;
              final isCorrect = showCorrectAnswer && index == question.correctOptionIndex;
              final isWrong = showCorrectAnswer && isSelected && !isCorrect;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: selectedAnswer == null && !showCorrectAnswer
                      ? () => onAnswerSelected?.call(index)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isWrong
                            ? Colors.red
                            : isCorrect
                                ? Colors.green
                                : isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isWrong
                          ? Colors.red.withOpacity(0.1)
                          : isCorrect
                              ? Colors.green.withOpacity(0.1)
                              : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            question.options_ar[index],
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        if (showCorrectAnswer && (isCorrect || isWrong))
                          Icon(
                            isCorrect
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (showCorrectAnswer && question.explanation_ar != null) ...[
            const SizedBox(height: 24),
            Text(
              'التوضيح:', // Explanation:
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              question.explanation_ar!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}