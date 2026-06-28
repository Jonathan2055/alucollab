import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALUCollab',
      debugShowCheckedModeBanner: false,
      home: const ConnectionTestScreen(),
    );
  }
}

class ConnectionTestScreen extends StatelessWidget {
  const ConnectionTestScreen({super.key});

  Future<void> _testSignUp(BuildContext context) async {
    final authRepo = AuthRepository();
    try {
      final user = await authRepo.signUpStudent(
        fullName: 'Test Student',
        studentId: 'ALU-000001',
        email: 'teststudent1@alustudent.com',
        password: 'password123',
      );
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Created: ${user.fullName}')));
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _testSignUp(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2DD4BF),
          ),
          child: const Text('Test Sign Up'),
        ),
      ),
    );
  }
}
