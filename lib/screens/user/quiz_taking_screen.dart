import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // For current user

class QuizTakingScreen extends StatefulWidget {
  final String quizId;
  const QuizTakingScreen({super.key, required this.quizId});

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  int currentQuestionIndex = 0;
  List<DocumentSnapshot> questions = [];
  int score = 0;
  int timeLeft = 0;
  Timer? timer;
  int totalQuizTime = 0;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void loadQuestions() async {
    final quizDoc =
        await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.quizId)
            .get();

    totalQuizTime = quizDoc['timelimit'];

    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.quizId)
            .collection('questions')
            .get();

    setState(() {
      questions = querySnapshot.docs;
      timeLeft = (totalQuizTime / questions.length).floor();
    });

    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        nextQuestion();
      }
    });
  }

  void answerQuestion(int selectedIndex) {
    final correctAnswer = questions[currentQuestionIndex]['correctAnswerIndex'];
    if (selectedIndex == correctAnswer) {
      score++;
    }
    nextQuestion();
  }

  Future<void> saveResult() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // user not logged in

    final resultRef = FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.quizId)
        .collection('results')
        .doc(user.uid);

    await resultRef.set({
      'name': user.displayName ?? 'Anonymous',
      'score': score,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // merge so it updates if exists
  }

  void nextQuestion() async {
    timer?.cancel();

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        timeLeft = (totalQuizTime / questions.length).floor();
      });
      startTimer();
    } else {
      // Quiz Ended --- save result then navigate
      await saveResult();

      Navigator.pushReplacementNamed(
        context,
        '/quizResult',
        arguments: {'score': score, 'total': questions.length},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Question ${currentQuestionIndex + 1}"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Text(
                "$timeLeft s",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question['question'], style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ...List.generate(4, (index) {
              final option = question['options'][index];
              return ElevatedButton(
                onPressed: () => answerQuestion(index),
                child: Text(option),
              );
            }),
          ],
        ),
      ),
    );
  }
}
