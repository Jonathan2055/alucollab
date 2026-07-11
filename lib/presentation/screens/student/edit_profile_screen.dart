import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _githubController;
  late final TextEditingController _skillController;
  late final TextEditingController _experienceController;
  late List<String> _skills;
  late List<String> _experience;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _bioController = TextEditingController(text: widget.user.bio);
    _linkedinController = TextEditingController(text: widget.user.linkedinUrl ?? '');
    _githubController = TextEditingController(text: widget.user.githubUrl ?? '');
    _skillController = TextEditingController();
    _experienceController = TextEditingController();
    _skills = List.from(widget.user.coreCompetencies);
    _experience = List.from(widget.user.experience);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _skillController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final uid = widget.user.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fullName': _fullNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'linkedinUrl': _linkedinController.text.trim(),
        'githubUrl': _githubController.text.trim(),
        'coreCompetencies': _skills,
        'experience': _experience,
      });

      if (!mounted) return;
      await context.read<AuthProvider>().loadUserProfile(uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _addExperience() {
    final experience = _experienceController.text.trim();
    if (experience.isNotEmpty) {
      setState(() {
        _experience.add(experience);
        _experienceController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Edit Profile',
            style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.secondary,
                    ),
                  )
                : const Text('Save',
                    style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.secondary,
                child: Text(
                  widget.user.fullName.isNotEmpty
                      ? widget.user.fullName[0].toUpperCase()
                      : 'S',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _sectionLabel('BASIC INFO'),
            _field('Full Name', _fullNameController, 'Amina Adams'),
            const SizedBox(height: 12),
            _field('Bio', _bioController, 'Tell startups about yourself...', maxLines: 3),
            const SizedBox(height: 20),
            _sectionLabel('LINKS'),
            _field('LinkedIn URL', _linkedinController, 'https://linkedin.com/in/yourname'),
            const SizedBox(height: 12),
            _field('GitHub URL', _githubController, 'https://github.com/yourname'),
            const SizedBox(height: 20),
            _sectionLabel('CORE COMPETENCIES & SKILLS'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills
                  .map((skill) => Chip(
                        label: Text(skill,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                        backgroundColor: AppColors.secondary.withOpacity(0.2),
                        deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.neutral),
                        onDeleted: () => setState(() => _skills.remove(skill)),
                        side: BorderSide(color: AppColors.secondary.withOpacity(0.4)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    style: TextStyle(color: AppColors.textPrimary(context)),
                    decoration: _inputDecoration('Add a skill e.g. Flutter, Python'),
                    onSubmitted: (_) => _addSkill(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addSkill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Add', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sectionLabel('EXPERIENCE'),
            ..._experience.asMap().entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.work_outline, color: AppColors.neutral, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(entry.value,
                          style: TextStyle(
                              color: AppColors.textPrimary(context), fontSize: 13)),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _experience.removeAt(entry.key)),
                      child: const Icon(Icons.close, color: AppColors.neutral, size: 16),
                    ),
                  ],
                ),
              );
            }),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _experienceController,
                    style: TextStyle(color: AppColors.textPrimary(context)),
                    decoration: _inputDecoration('e.g. Software Intern at ALU Labs (2024)'),
                    onSubmitted: (_) => _addExperience(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addExperience,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Add', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2)),
    );
  }

  Widget _field(String label, TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.neutral, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: AppColors.textPrimary(context)),
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.neutral),
      filled: true,
      fillColor: AppColors.surface(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
