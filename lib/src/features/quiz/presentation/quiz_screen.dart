import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masarat_alnur/src/features/quiz/data/quiz_repository.dart';
import 'package:masarat_alnur/src/features/quiz/domain/quiz_question.dart';
import 'package:masarat_alnur/src/features/auth/data/auth_repository.dart';
import 'package:masarat_alnur/src/features/content/domain/topic.dart';
import 'package:masarat_alnur/src/features/content/data/content_repository.dart';
import 'package:masarat_alnur/src/features/auth/data/user_repository.dart';

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
  final Map<String, int> _answers = {};
  final Map<String, bool> _checkedAnswers = {};
  String? _currentQuestionId;
  bool _showCompleted = false;
  String? _subCategoryId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadTopicInfo();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadTopicInfo() async {
    final topic = await ref.read(quizRepositoryProvider).fetchTopic(widget.topicId);
    if (topic != null) {
      setState(() {
        _subCategoryId = topic.subCategoryId;
      });

      // Get the category ID
      final subCategory = await ref.read(contentRepositoryProvider).fetchSubCategory(topic.subCategoryId);
      if (subCategory != null) {
        final currentUser = ref.read(authStateChangesProvider).value;
        if (currentUser != null) {
          // Mark subcategory and category as started
          await ref.read(userRepositoryProvider).updateSubCategoryStarted(currentUser.uid, topic.subCategoryId);
          await ref.read(userRepositoryProvider).updateCategoryStarted(currentUser.uid, subCategory.categoryId);
        }
      }
    }
  }

  Future<void> _checkAnswer(String questionId, int selectedIndex) async {
    final currentUser = ref.read(authStateChangesProvider).value;
    if (currentUser == null) return;

    final isCorrect = await ref
        .read(quizRepositoryProvider)
        .saveAnswer(currentUser.uid, questionId, selectedIndex);

    setState(() {
      if (isCorrect) {
        _answers[questionId] = selectedIndex;
      }
      _currentQuestionId = questionId;
      _checkedAnswers[questionId] = isCorrect;
    });
  }

  void _nextQuestion() {
    final questions = ref.read(questionsStreamProvider(widget.topicId)).value ?? [];
    final currentIndex = questions.indexWhere((q) => q.id == _currentQuestionId);
    if (currentIndex < questions.length - 1) {
      setState(() {
        _checkedAnswers.remove(_currentQuestionId);
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Quiz completed, mark topic as complete
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    final currentUser = ref.read(authStateChangesProvider).value;
    if (currentUser == null) return;

    // Submit final answers and get score
    await ref
        .read(quizRepositoryProvider)
        .submitQuiz(currentUser.uid, widget.topicId, _answers);

    // Mark topic as complete - this will trigger subcategory and category completion checks
    await ref
        .read(userRepositoryProvider)
        .markTopicAsComplete(currentUser.uid, widget.topicId);

    setState(() {
      _showCompleted = true;
    });
  }

  void _retryQuestion() {
    setState(() {
      _checkedAnswers.remove(_currentQuestionId);
      _answers.remove(_currentQuestionId);  // Also clear the selected answer
    });
  }

  Future<void> _handleButtonPress() async {
    if (_currentQuestionId == null) return;

    if (!_checkedAnswers.containsKey(_currentQuestionId!)) {
      // Check answer
      await _checkAnswer(_currentQuestionId!, _answers[_currentQuestionId!]!);
      return;
    }

    final isCorrect = _checkedAnswers[_currentQuestionId!] ?? false;
    if (!isCorrect) {
      // Retry question
      _retryQuestion();
      return;
    }

    // Next question or complete
    _nextQuestion();
  }

  Future<void> _navigateToNextTopic(BuildContext context) async {
    if (_subCategoryId == null) return;
    
    // Get all topics for this subcategory
    final topics = await ref
        .read(quizRepositoryProvider)
        .watchTopics(_subCategoryId!)
        .first;

    // Sort topics by order
    final sortedTopics = List<Topic>.from(topics)
      ..sort((a, b) => a.order.compareTo(b.order));

    // Find current topic index
    final currentIndex = sortedTopics.indexWhere((t) => t.id == widget.topicId);
    
    // If there's a next topic, navigate to it
    if (currentIndex < sortedTopics.length - 1) {
      final nextTopic = sortedTopics[currentIndex + 1];
      if (context.mounted) {
        context.pushReplacement('/topics/${nextTopic.id}/quiz');
      }
    } else {
      // No more topics, go back to topics list
      if (context.mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsStreamProvider(widget.topicId));

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

          if (_showCompleted) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                    const SizedBox(height: 16),
                    Text(
                      'اكتمل الاختبار!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: () => _navigateToNextTopic(context),
                      child: const Text('الموضوع التالي'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('العودة إلى قائمة المواضيع'),
                    ),
                  ],
                ),
              ),
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
                      selectedAnswer: _answers[question.id],  // Just pass the current answer
                      showCorrectAnswer: _checkedAnswers.containsKey(question.id),
                      onAnswerSelected: _checkedAnswers.containsKey(question.id) ? 
                          null : 
                          (selectedIndex) {
                            setState(() {
                              _currentQuestionId = question.id;
                              _answers[question.id] = selectedIndex;
                            });
                          },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _currentQuestionId == null || 
                        (_answers[_currentQuestionId!] == null && !_checkedAnswers.containsKey(_currentQuestionId!))
                        ? null 
                        : _handleButtonPress,
                    child: Text(_getButtonText()),
                  ),
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

  String _getButtonText() {
    if (_currentQuestionId == null) {
      return 'تحقق'; // Check
    }

    if (!_checkedAnswers.containsKey(_currentQuestionId!)) {
      return 'تحقق'; // Check
    }

    final isCorrect = _checkedAnswers[_currentQuestionId!] ?? false;
    if (!isCorrect) {
      return 'أعد المحاولة'; // Try Again
    }

    final questions = ref.read(questionsStreamProvider(widget.topicId)).value ?? [];
    final currentIndex = questions.indexWhere((q) => q.id == _currentQuestionId);
    if (currentIndex == questions.length - 1) {
      return 'تم'; // Done
    }

    return 'السؤال التالي'; // Next Question
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
                  onTap: !showCorrectAnswer
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