import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save or update a user's score in the leaderboard
  Future<void> saveUserScore({
    required String quizId,
    required String userId,
    required String name,
    required int score,
  }) async {
    final userResultRef = _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('results')
        .doc(userId);

    final snapshot = await userResultRef.get();

    if (snapshot.exists) {
      // Update only if the new score is higher
      final existingScore = snapshot['score'] as int;
      if (score > existingScore) {
        await userResultRef.set({
          'name': name,
          'score': score,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } else {
      // First time saving
      await userResultRef.set({
        'name': name,
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Fetch top 5 leaderboard entries for a quiz
  Stream<List<Map<String, dynamic>>> getTopScores(String quizId) {
    return _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('results')
        .orderBy('score', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'name': data['name'] ?? 'Unknown',
              'score': data['score'] ?? 0,
            };
          }).toList();
        });
  }
}
