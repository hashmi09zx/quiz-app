import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quizzy/screens/auth/login_screen.dart';
import 'package:quizzy/screens/auth/register_screen.dart';
import 'package:quizzy/screens/user/home_screen.dart';
import 'package:quizzy/screens/admin/admin_dashboard.dart';
import 'package:quizzy/screens/user/quiz_list_screen.dart';
import 'package:quizzy/screens/user/quiz_result_screen.dart';
import 'package:quizzy/screens/user/quiz_taking_screen.dart';
import 'package:quizzy/screens/user/quiz_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/user_home': (context) => const UserHomeScreen(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/quizList': (context) => const QuizListScreen(),
        '/quizDetail': (context) => const QuizDetailScreen(),
        '/quizTaking': (context) {
          final quizId = ModalRoute.of(context)!.settings.arguments as String;
          return QuizTakingScreen(quizId: quizId);
        },
        '/quizResult': (context) => const QuizResultScreen(),
      },
    );
  }
}
