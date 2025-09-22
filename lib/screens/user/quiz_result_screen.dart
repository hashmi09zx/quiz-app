import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  Future<void> _saveScore(String quizId, int score) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final resultRef = FirebaseFirestore.instance
        .collection('quizzes')
        .doc(quizId)
        .collection('results')
        .doc(user.uid);

    final snapshot = await resultRef.get();

    // Save only if it's the first attempt OR new score is higher
    if (!snapshot.exists || (snapshot.data()?['score'] ?? 0) < score) {
      await resultRef.set({
        'name': user.displayName ?? "Anonymous",
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final int score = args['score'];
    final int total = args['total'];
    final String quizId = args['quizId']; // pass quizId when navigating here

    // Save score as soon as screen builds
    _saveScore(quizId, score);

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Result")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "🎉 Quiz Completed!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text("Your Score", style: TextStyle(fontSize: 20)),
              Text(
                "$score / $total",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(
                    context,
                    ModalRoute.withName('/user_home'),
                  );
                },
                child: const Text("Back to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
