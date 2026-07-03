import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/opportunity_provider.dart';

class PostOpportunityScreen extends StatefulWidget {
  final String startupId;
  final String startupName;
  const PostOpportunityScreen({
    super.key,
    required this.startupId,
    required this.startupName,
  });

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillController = TextEditingController();

  String _selectedCategory = 'Engineering';
  int _durationMonths = 3;
  List<String> _skills = [];
  bool _isLoading = false;

  final List<String> _categories = [
    'Engineering', 'Design', 'Business', 'Data Science', 'Marketing'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _skillController.dispose();
    super.dispose();
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

  Future<void> _handlePost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one required skill')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final opportunity = OpportunityModel(
        id: '',
        startupId: widget.startupId,
        startupName: widget.startupName,
        isVerifiedVenture: true,
        title: _titleController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        requiredSkills: _skills,
        durationMonths: _durationMonths,
        createdAt: DateTime.now(),
      );

      await context.read<OpportunityProvider>().createOpportunity(opportunity);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Opportunity posted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Post Opportunity', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ALU VERIFIED VENTURE',
                        style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Find your next elite intern.',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Drafting as: ${widget.startupName}',
                        style: const TextStyle(color: AppColors.neutral, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('ROLE TITLE'),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('e.g. Lead Software Engineer Intern'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('CATEGORY'),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(''),
                items: _categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                )).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),

              _buildLabel('DURATION: ${_durationMonths} Months'),
              Slider(
                value: _durationMonths.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                activeColor: AppColors.secondary,
                inactiveColor: const Color(0xFF1E293B),
                onChanged: (val) => setState(() => _durationMonths = val.toInt()),
              ),
              const SizedBox(height: 16),

              _buildLabel('REQUIRED SKILLS'),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _skills.map((skill) => Chip(
                  label: Text(skill, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  backgroundColor: const Color(0xFF1E293B),
                  deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.neutral),
                  onDeleted: () => setState(() => _skills.remove(skill)),
                )).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skillController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Type a skill and press add...'),
                      onFieldSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addSkill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Add', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('DESCRIPTION'),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: _inputDecoration('Define the mission, responsibilities...'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('▶ Post Internship',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(color: AppColors.neutral, fontSize: 12, fontWeight: FontWeight.bold)),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.neutral),
    filled: true,
    fillColor: const Color(0xFF1E293B),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );
}