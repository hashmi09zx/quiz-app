import 'package:flutter/material.dart';
import 'package:quizzy/services/leaderboard_service.dart';

class LeaderboardScreen extends StatelessWidget {
  final String quizId;
  const LeaderboardScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    final leaderboardService = LeaderboardService();

    return Scaffold(
      appBar: AppBar(title: const Text("🏆 Leaderboard"), centerTitle: true),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: leaderboardService.getTopScores(quizId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final leaderboard = snapshot.data!;

          if (leaderboard.isEmpty) {
            return const Center(child: Text("No scores yet. Be the first!"));
          }

          return ListView.builder(
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final entry = leaderboard[index];
              final name = entry['name'];
              final score = entry['score'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      index == 0
                          ? Colors.amber
                          : index == 1
                          ? Colors.grey
                          : index == 2
                          ? Colors.brown
                          : Colors.blue,
                  child: Text("${index + 1}"),
                ),
                title: Text(name, style: const TextStyle(fontSize: 18)),
                trailing: Text(
                  score.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
