import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizzy/models/question_model.dart';

class QuizService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createQuiz({
    required String title,
    required String description,
    required int timeLimit,
    required List<QuestionModel> questions,
  }) async {
    final quizRef = _db.collection('quizzes').doc(); //auto id
    final batch = _db.batch();

    batch.set(quizRef, {
      'title': title,
      'description': description,
      'timelimit': timeLimit,
      'createdAt': FieldValue.serverTimestamp(),
    });

    for (var q in questions) {
      final qRef = quizRef.collection('questions').doc();
      batch.set(qRef, q.toMAp());
    }

    await batch.commit();
    return quizRef.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamQuizzes() {
    return _db
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<List<QuestionModel>> getQuestions(String quizId) async {
    final snap =
        await _db
            .collection('quizzes')
            .doc(quizId)
            .collection('questions')
            .get();
    return snap.docs.map((d) => QuestionModel.fromDoc(d)).toList();
  }
}
