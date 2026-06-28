import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Center(
        child: Text(
          'Firebase Connected',
          style: TextStyle(color: Color(0xFF2DD4BF), fontSize: 20),
        ),
      ),
    );
  }
}
