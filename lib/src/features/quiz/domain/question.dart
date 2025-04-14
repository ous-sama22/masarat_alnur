import 'package:equatable/equatable.dart';
import 'package:masarat_alnur/src/features/quiz/domain/question_type.dart'; // Import enum

class Question extends Equatable {
  final String id;
  final String topicId; // Link back to the Topic (Quiz)
  final String questionText_ar;
  final QuestionType questionType;
  // For MCQ
  final List<String> options_ar;
  final int correctOptionIndex;
  // Add order field
  final int order;

  const Question({
    required this.id,
    this.topicId = '',
    this.questionText_ar = '',
    this.questionType = QuestionType.MCQ,
    this.options_ar = const [],
    this.correctOptionIndex = -1,
    this.order = 0,
  });

   factory Question.empty() => const Question(id: '');

  @override
  List<Object?> get props => [
        id,
        topicId,
        questionText_ar,
        questionType,
        options_ar,
        correctOptionIndex,
        order,
      ];

  @override
  bool get stringify => true;

   // copyWith
   Question copyWith({
     String? id,
     String? topicId,
     String? questionText_ar,
     QuestionType? questionType,
     List<String>? options_ar,
     int? correctOptionIndex,
     int? order,
   }) {
     return Question(
       id: id ?? this.id,
       topicId: topicId ?? this.topicId,
       questionText_ar: questionText_ar ?? this.questionText_ar,
       questionType: questionType ?? this.questionType,
       options_ar: options_ar ?? this.options_ar,
       correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
       order: order ?? this.order,
     );
   }
}