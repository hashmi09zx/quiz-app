import 'package:flutter/material.dart';
import 'package:quizzy/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  // Future<void> register() async {
  //   try {
  //     await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: emailController.text.trim(),
  //       password: passwordController.text.trim(),
  //     );
  //     Navigator.pop(context); // go back to login
  //     // but in this case we wont go to login page as we are using StreamBuilder<User?> in main.dart as it listens for authStateChanges().
  //     // Since the user is now signed in, snapshot.hasData becomes true and you immediately get redirected to the home page instead of the login screen
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text(e.toString())));
  //   }
  // }
  void handleRegister() async {
    setState(() {
      isLoading = true;
    });
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    String? result = await AuthService().register(email, password);

    setState(() => isLoading = false);

    if (result == "success") {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result ?? "Registration failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: handleRegister,
                  child: const Text("Register"),
                ),
          ],
        ),
      ),
    );
  }
}
