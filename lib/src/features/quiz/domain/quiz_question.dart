import 'package:equatable/equatable.dart';

class QuizQuestion extends Equatable {
  final String id;
  final String topicId;
  final String question_ar;
  final List<String> options_ar;
  final int correctOptionIndex;
  final int order;
  final String? explanation_ar;

  const QuizQuestion({
    required this.id,
    required this.topicId,
    required this.question_ar,
    required this.options_ar,
    required this.correctOptionIndex,
    required this.order,
    this.explanation_ar,
  });

  factory QuizQuestion.empty() => const QuizQuestion(
        id: '',
        topicId: '',
        question_ar: '',
        options_ar: [],
        correctOptionIndex: 0,
        order: 0,
      );

  @override
  List<Object?> get props => [
        id,
        topicId,
        question_ar,
        options_ar,
        correctOptionIndex,
        order,
        explanation_ar,
      ];

  @override
  bool get stringify => true;

  QuizQuestion copyWith({
    String? id,
    String? topicId,
    String? question_ar,
    List<String>? options_ar,
    int? correctOptionIndex,
    int? order,
    String? explanation_ar,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      question_ar: question_ar ?? this.question_ar,
      options_ar: options_ar ?? this.options_ar,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      order: order ?? this.order,
      explanation_ar: explanation_ar ?? this.explanation_ar,
    );
  }
}