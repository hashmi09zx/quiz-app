import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  Map<String, dynamic> toMAp() => {
    'question': question,
    'options': options,
    'correctAnswerIndex': correctAnswerIndex,
  };

  factory QuestionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswerIndex: (data['correctAnswerIndex'] ?? 0) as int,
    );
  }
}
