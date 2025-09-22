import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuestionEditScreen extends StatefulWidget {
  final String quizId;
  final String? questionId; // nullable

  const QuestionEditScreen({super.key, required this.quizId, this.questionId});

  @override
  State<QuestionEditScreen> createState() => _QuestionEditScreenState();
}

class _QuestionEditScreenState extends State<QuestionEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  int _correctIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.questionId != null) {
      _loadQuestion();
    }
  }

  Future<void> _loadQuestion() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.quizId)
            .collection('questions')
            .doc(widget.questionId)
            .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      _questionController.text = data['question'] ?? '';
      final options = List<String>.from(data['options'] ?? []);
      for (int i = 0; i < _optionControllers.length; i++) {
        _optionControllers[i].text = i < options.length ? options[i] : '';
      }
      _correctIndex = data['correctAnswerIndex'] ?? 0;
      setState(() {});
    }
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'question': _questionController.text,
      'options': _optionControllers.map((c) => c.text).toList(),
      'correctAnswerIndex': _correctIndex,
    };

    final ref = FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.quizId)
        .collection('questions');

    if (widget.questionId == null) {
      // Add new question
      await ref.add(data);
    } else {
      // Update existing question
      await ref.doc(widget.questionId).update(data);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.questionId == null ? 'Add Question' : 'Edit Question',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question'),
                validator: (v) => v!.isEmpty ? 'Enter question' : null,
              ),
              const SizedBox(height: 16),
              ...List.generate(
                4,
                (i) => TextFormField(
                  controller: _optionControllers[i],
                  decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                  validator: (v) => v!.isEmpty ? 'Enter option' : null,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _correctIndex,
                items: List.generate(
                  4,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text('Option ${i + 1}'),
                  ),
                ),
                onChanged: (val) => setState(() => _correctIndex = val ?? 0),
                decoration: const InputDecoration(labelText: 'Correct Answer'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveQuestion,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
