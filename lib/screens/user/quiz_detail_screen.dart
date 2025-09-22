import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizDetailScreen extends StatelessWidget {
  const QuizDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String quizId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Details")),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('quizzes').doc(quizId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Quiz not found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? "Untitled Quiz",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(data['description'] ?? "No description"),
                const SizedBox(height: 8),
                Text("Time Limit: ${data['timeLimit'] ?? 0} seconds"),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to quiz-taking screen
                    Navigator.pushNamed(
                      context,
                      '/quizTaking',
                      arguments: quizId,
                    );
                  },
                  child: const Text("Start Quiz"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
