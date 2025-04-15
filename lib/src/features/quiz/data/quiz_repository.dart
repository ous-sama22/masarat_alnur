import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:masarat_alnur/src/features/quiz/domain/quiz_question.dart';
import 'package:masarat_alnur/src/features/quiz/domain/quiz_progress.dart';
import 'package:masarat_alnur/src/features/auth/data/user_repository.dart';
import 'package:masarat_alnur/src/features/content/domain/topic.dart';
import 'package:masarat_alnur/src/features/content/domain/content_status.dart';

part 'quiz_repository.g.dart';

class QuizRepository {
  final FirebaseFirestore _firestore;
  
  QuizRepository(this._firestore);

  // Collection References
  CollectionReference<Topic> _topicsRef() =>
      _firestore.collection('topics').withConverter<Topic>(
            fromFirestore: (snapshot, _) => Topic(
              id: snapshot.id,
              subCategoryId: snapshot.data()?['subCategoryId'] ?? '',
              title_ar: snapshot.data()?['title_ar'] ?? '',
              description_ar: snapshot.data()?['description_ar'] ?? '',
              order: snapshot.data()?['order'] ?? 0,
              status: ContentStatus.values.firstWhere(
                (e) => e.name == (snapshot.data()?['status'] ?? 'PUBLISHED'),
                orElse: () => ContentStatus.PUBLISHED,
              ),
            ),
            toFirestore: (topic, _) => {
              'subCategoryId': topic.subCategoryId,
              'title_ar': topic.title_ar,
              'description_ar': topic.description_ar,
              'order': topic.order,
              'status': topic.status.name,
            },
          );

  CollectionReference<QuizQuestion> _questionsRef() =>
      _firestore.collection('questions').withConverter<QuizQuestion>(
            fromFirestore: (snapshot, _) => QuizQuestion(
              id: snapshot.id,
              topicId: snapshot.data()?['topicId'] ?? '',
              question_ar: snapshot.data()?['question_ar'] ?? '',
              options_ar: List<String>.from(snapshot.data()?['options_ar'] ?? []),
              correctOptionIndex: snapshot.data()?['correctOptionIndex'] ?? 0,
              order: snapshot.data()?['order'] ?? 0,
              explanation_ar: snapshot.data()?['explanation_ar'],
            ),
            toFirestore: (question, _) => {
              'topicId': question.topicId,
              'question_ar': question.question_ar,
              'options_ar': question.options_ar,
              'correctOptionIndex': question.correctOptionIndex,
              'order': question.order,
              if (question.explanation_ar != null)
                'explanation_ar': question.explanation_ar,
            },
          );

  // Fetch Methods
  Stream<List<Topic>> watchTopics(String subCategoryId) {
    return _topicsRef()
        .where('subCategoryId', isEqualTo: subCategoryId)
        .orderBy('order')
        .where('status', isEqualTo: ContentStatus.PUBLISHED.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<QuizQuestion>> watchQuestions(String topicId) {
    return _questionsRef()
        .where('topicId', isEqualTo: topicId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<Topic?> fetchTopic(String topicId) async {
    final doc = await _topicsRef().doc(topicId).get();
    return doc.data();
  }

  // User Progress Methods
  Future<bool> saveAnswer(String userId, String questionId, int selectedOptionIndex) async {
    final progressRef = _firestore
        .collection('userProgress')
        .doc(userId)
        .collection('quizProgress');

    final QuizQuestion? question = await _questionsRef()
        .doc(questionId)
        .get()
        .then((doc) => doc.data());

    if (question == null) return false;

    final isCorrect = selectedOptionIndex == question.correctOptionIndex;
    
    // Update the progress document for this topic
    final progressDoc = progressRef.doc(question.topicId);
    final existingProgress = await progressDoc.get();

    if (!existingProgress.exists) {
      await progressDoc.set({
        'status': QuizStatus.IN_PROGRESS.name,
        'answers': isCorrect ? {questionId: selectedOptionIndex} : {},
        'lastAttemptDate': FieldValue.serverTimestamp(),
      });
    } else {
      final currentAnswers = (existingProgress.data()?['answers'] as Map<String, dynamic>?)?.cast<String, int>() ?? {};
      
      if (isCorrect) {
        currentAnswers[questionId] = selectedOptionIndex;
      }

      await progressDoc.update({
        'status': QuizStatus.IN_PROGRESS.name,
        'answers': currentAnswers,
        'lastAttemptDate': FieldValue.serverTimestamp(),
      });
    }

    return isCorrect;
  }

  Future<void> submitQuiz(String userId, String topicId, Map<String, int> answers) async {
    final questions = await _questionsRef()
        .where('topicId', isEqualTo: topicId)
        .get()
        .then((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

    int correctAnswers = 0;
    for (final question in questions) {
      final selectedAnswer = answers[question.id];
      if (selectedAnswer == question.correctOptionIndex) {
        correctAnswers++;
      }
    }

    final score = questions.isEmpty ? 0 : (correctAnswers / questions.length * 100).round();

    await _firestore
        .collection('userProgress')
        .doc(userId)
        .collection('quizProgress')
        .doc(topicId)
        .set({
          'status': QuizStatus.COMPLETED.name,
          'answers': answers,
          'score': score,
          'lastAttemptDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Stream<QuizProgress?> watchQuizProgress(String userId, String topicId) {
    return _firestore
        .collection('userProgress')
        .doc(userId)
        .collection('quizProgress')
        .doc(topicId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;

      return QuizProgress(
        topicId: topicId,
        status: QuizStatus.values.firstWhere(
          (e) => e.name == (doc.data()?['status'] ?? 'NOT_STARTED'),
          orElse: () => QuizStatus.NOT_STARTED,
        ),
        answers: Map<String, int>.from(doc.data()?['answers'] ?? {}),
        score: doc.data()?['score'] ?? 0,
        lastAttemptDate: (doc.data()?['lastAttemptDate'] as Timestamp?)?.toDate(),
      );
    });
  }
}

@Riverpod(keepAlive: true)
QuizRepository quizRepository(QuizRepositoryRef ref) {
  return QuizRepository(ref.watch(firebaseFirestoreProvider));
}

@riverpod
Stream<List<Topic>> topicsStream(TopicsStreamRef ref, String subCategoryId) {
  return ref.watch(quizRepositoryProvider).watchTopics(subCategoryId);
}

@riverpod
Stream<List<QuizQuestion>> questionsStream(QuestionsStreamRef ref, String topicId) {
  return ref.watch(quizRepositoryProvider).watchQuestions(topicId);
}

@riverpod
Stream<QuizProgress?> quizProgressStream(
  QuizProgressStreamRef ref, 
  String userId, 
  String topicId,
) {
  return ref.watch(quizRepositoryProvider).watchQuizProgress(userId, topicId);
}