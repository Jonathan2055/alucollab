import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';

enum SignupPersona { student, startup }

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  SignupPersona _persona = SignupPersona.student;
  bool _isLoading = false;

  // Shared fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Student-only field
  final _studentIdController = TextEditingController();

  // Startup-only field
  final _startupNameController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _studentIdController.dispose();
    _startupNameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_persona == SignupPersona.student) {
        await context.read<AuthProvider>().signUpStudent(
          fullName: _fullNameController.text.trim(),
          studentId: _studentIdController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await context.read<AuthProvider>().signUpStartupOwner(
          fullName: _fullNameController.text.trim(),
          startupName: _startupNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      // AuthWrapper's stream listener handles navigation automatically.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_friendlyError(e))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('email-already-in-use')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('weak-password')) {
      return 'Password must be at least 6 characters.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.hub, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text(
                      'ALUCollab',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Create your account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Access Africa's elite startup ecosystem.",
                  style: TextStyle(color: AppColors.neutral),
                ),
                const SizedBox(height: 24),

                _buildPersonaToggle(),
                const SizedBox(height: 24),

                _buildLabel('Full Name'),
                TextFormField(
                  controller: _fullNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Amina Mansour'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Full name is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Conditional field based on persona
                if (_persona == SignupPersona.student) ...[
                  _buildLabel('ALU Student ID'),
                  TextFormField(
                    controller: _studentIdController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('ALU-098234'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Student ID is required'
                        : null,
                  ),
                ] else ...[
                  _buildLabel('Startup Name'),
                  TextFormField(
                    controller: _startupNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('EcoFlow Dynamics'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Startup name is required'
                        : null,
                  ),
                ],
                const SizedBox(height: 16),

                _buildLabel(
                  _persona == SignupPersona.student ? 'ALU Email' : 'Email',
                ),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('a.mansour@alueducation.com'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Email is required';
                    final emailPattern = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailPattern.hasMatch(v.trim()))
                      return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildLabel('Password'),
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: _inputDecoration('••••••••••'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6)
                      return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCreateAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: AppColors.neutral),
                        children: [
                          TextSpan(
                            text: 'Log in',
                            style: TextStyle(color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonaToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _toggleButton('Joining as a Student', SignupPersona.student),
          ),
          Expanded(
            child: _toggleButton('Joining as a Startup', SignupPersona.startup),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, SignupPersona persona) {
    final bool selected = _persona == persona;
    return GestureDetector(
      onTap: () => setState(() => _persona = persona),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.black : AppColors.neutral,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.neutral, fontSize: 13),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.neutral),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
