import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Quizzes')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('quizzes')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text('No quizzes yet'));
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No quizzes available.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final quizDoc = docs[index];
              final data = quizDoc.data() as Map<String, dynamic>;
              // ✅ Safe retrieval for missing fields
              final description = data['description'] ?? '';
              final timelimit =
                  data.containsKey('timelimit') ? data['timelimit'] : 0;

              return StreamBuilder<QuerySnapshot>(
                stream: quizDoc.reference.collection('questions').snapshots(),
                builder: (context, questionSnap) {
                  int questionCount = 0;
                  if (questionSnap.hasData) {
                    questionCount = questionSnap.data!.docs.length;
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(data['title'] ?? 'Untitled Quiz'),
                      subtitle: Text(
                        '$description\nQuestions: $questionCount | Time: ${timelimit}s',
                      ),
                      isThreeLine: true,
                      onTap: () {
                        // navigate to quiz attempt screen (pass quizId: d.id)
                        Navigator.pushNamed(
                          context,
                          '/quizDetail',
                          arguments: docs[index].id,
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
