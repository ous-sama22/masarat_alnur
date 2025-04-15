import 'package:equatable/equatable.dart';

enum QuizStatus {
  NOT_STARTED,
  IN_PROGRESS,
  COMPLETED,
}

class QuizProgress extends Equatable {
  final String topicId;
  final QuizStatus status;
  final Map<String, int> answers; // questionId -> selectedOptionIndex
  final int score;
  final DateTime? lastAttemptDate;

  const QuizProgress({
    required this.topicId,
    this.status = QuizStatus.NOT_STARTED,
    this.answers = const {},
    this.score = 0,
    this.lastAttemptDate,
  });

  factory QuizProgress.empty() => const QuizProgress(topicId: '');

  @override
  List<Object?> get props => [topicId, status, answers, score, lastAttemptDate];

  @override
  bool get stringify => true;

  QuizProgress copyWith({
    String? topicId,
    QuizStatus? status,
    Map<String, int>? answers,
    int? score,
    DateTime? lastAttemptDate,
    bool clearLastAttemptDate = false,
  }) {
    return QuizProgress(
      topicId: topicId ?? this.topicId,
      status: status ?? this.status,
      answers: answers ?? this.answers,
      score: score ?? this.score,
      lastAttemptDate: clearLastAttemptDate ? null : (lastAttemptDate ?? this.lastAttemptDate),
    );
  }
}