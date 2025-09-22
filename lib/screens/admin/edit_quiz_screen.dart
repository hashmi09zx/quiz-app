import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizzy/screens/admin/question_edit_screen.dart';

class EditQuizScreen extends StatefulWidget {
  final String quizId;

  const EditQuizScreen({super.key, required this.quizId});

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeLimitController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    try {
      DocumentSnapshot quizDoc =
          await FirebaseFirestore.instance
              .collection('quizzes')
              .doc(widget.quizId)
              .get();

      if (!quizDoc.exists) return;

      var data = quizDoc.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _timeLimitController.text = (data['timelimit'] ?? 60).toString();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading quiz: $e")));
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveQuiz() async {
    try {
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .update({
            'title': _titleController.text,
            'description': _descriptionController.text,
            'timelimit': int.tryParse(_timeLimitController.text) ?? 60,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving quiz: $e")));
    }
  }

  Future<void> _deleteQuestion(String questionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .collection('questions')
          .doc(questionId)
          .delete();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting question: $e")));
    }
  }

  void _addQuestion() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => QuestionEditScreen(
              quizId: widget.quizId,
              questionId: null, // null = create new question
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Quiz'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveQuiz),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Quiz Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Quiz Description'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _timeLimitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Time Limit (seconds)',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('quizzes')
                      .doc(widget.quizId)
                      .collection('questions')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var questions = snapshot.data!.docs;

                if (questions.isEmpty) {
                  return const Text("No questions yet. Add some!");
                }

                return Column(
                  children: [
                    for (var q in questions)
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(q['question']),
                          subtitle: Text(
                            "Correct Answer: ${q['options'][q['correctAnswerIndex']]}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => QuestionEditScreen(
                                            quizId: widget.quizId,
                                            questionId: q.id,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteQuestion(q.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _addQuestion,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Question'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
