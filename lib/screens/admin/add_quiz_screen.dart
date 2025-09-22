import 'package:flutter/material.dart';
import 'package:quizzy/models/question_model.dart';
import 'package:quizzy/services/quiz_service.dart';

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final List<QuestionModel> _questions = [];
  final QuizService _quizService = QuizService();
  bool _loading = false;

  void _showAddQuestionDialog() {
    final qCtrl = TextEditingController();
    final optionCtrls = List.generate(4, (_) => TextEditingController());
    int selectedCorrect = 0;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Add Question'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: qCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Question',
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(4, (i) {
                        return Row(
                          children: [
                            Radio<int>(
                              value: i,
                              groupValue: selectedCorrect,
                              onChanged:
                                  (v) => setDialogState(
                                    () => selectedCorrect = v!,
                                  ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: optionCtrls[i],
                                decoration: InputDecoration(
                                  labelText: 'Option ${i + 1}',
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final qText = qCtrl.text.trim();
                      final opts =
                          optionCtrls.map((c) => c.text.trim()).toList();
                      if (qText.isEmpty || opts.any((o) => o.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fill question and all 4 options'),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        _questions.add(
                          QuestionModel(
                            question: qText,
                            options: opts,
                            correctAnswerIndex: selectedCorrect,
                          ),
                        );
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add at least 1 question')));
      return;
    }

    setState(() => _loading = true);
    try {
      final quizId = await _quizService.createQuiz(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        timeLimit: int.tryParse(_timeCtrl.text.trim()) ?? 60,
        questions: _questions,
      );
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Quiz saved successfully')));
      Navigator.pop(context); // back to admin dashboard
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Quiz Title'),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Enter title' : null,
                ),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator:
                      (v) =>
                          v == null || v.isEmpty ? 'Enter description' : null,
                ),
                TextFormField(
                  controller: _timeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Time Limit (seconds)',
                  ),
                  keyboardType: TextInputType.number,
                  validator:
                      (v) => v == null || v.isEmpty ? 'Enter time limit' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _showAddQuestionDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Question'),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _questions.length,
                  itemBuilder: (context, idx) {
                    final q = _questions[idx];
                    return Card(
                      child: ListTile(
                        title: Text(q.question),
                        subtitle: Text(
                          'Correct: Option ${q.correctAnswerIndex + 1}\n${q.options.join(' • ')}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed:
                              () => setState(() => _questions.removeAt(idx)),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _saveQuiz,
                      child: const Text('Save Quiz'),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
