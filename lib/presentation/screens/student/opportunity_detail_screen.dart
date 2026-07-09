import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/models/application_model.dart';
import '../../../data/repositories/application_repository.dart';
import '../../../data/repositories/opportunity_repository.dart';
import '../../../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final OpportunityModel opportunity;
  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  bool _isApplying = false;

  Future<void> _handleApply() async {
  final user = context.read<AuthProvider>().currentUser;
  if (user == null) return;

  setState(() => _isApplying = true);
  try {
    //  Check for existing application first 
    final existing = await FirebaseFirestore.instance
        .collection('applications')
        .where('studentId', isEqualTo: user.uid)
        .where('opportunityId', isEqualTo: widget.opportunity.id)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already applied to this opportunity.')),
      );
      return;
    }

    final application = ApplicationModel(
      id: '',
      opportunityId: widget.opportunity.id,
      opportunityTitle: widget.opportunity.title,
      startupId: widget.opportunity.startupId,
      startupName: widget.opportunity.startupName,
      studentId: user.uid,
      appliedAt: DateTime.now(),
    );

    await ApplicationRepository().applyToOpportunity(application);
    await OpportunityRepository().incrementApplicantCount(widget.opportunity.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application submitted!')),
    );
    Navigator.of(context).pop();
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    if (mounted) setState(() => _isApplying = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final opp = widget.opportunity;
    final surface = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Opportunity', style: TextStyle(color: textPrimary)),
        actions: const [
          Icon(Icons.share_outlined, color: AppColors.neutral),
          SizedBox(width: 8),
          Icon(Icons.bookmark_border, color: AppColors.neutral),
          SizedBox(width: 12),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isApplying ? null : _handleApply,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isApplying
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  'Apply Now',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Header card ─
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (opp.isVerifiedVenture)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            color: AppColors.secondary,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'ALU Verified Venture',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    opp.title,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${opp.startupName} · ${opp.category}',
                    style: const TextStyle(color: AppColors.secondary),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: opp.requiredSkills
                        .map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background(context),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                color: AppColors.neutral,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            //  Commitment 
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: AppColors.secondary, width: 3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'COMMITMENT & LOCATION',
                          style: TextStyle(
                            color: AppColors.neutral,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${opp.durationMonths} months · On-campus',
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            //  Role Overview ─
            Text(
              'Role Overview',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              opp.description,
              style: TextStyle(color: AppColors.neutral, height: 1.6),
            ),
            const SizedBox(height: 20),

            //  Applicants count 
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_outline, color: AppColors.secondary),
                  const SizedBox(width: 10),
                  Text(
                    '${opp.applicantCount} applicants so far',
                    style: TextStyle(color: textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
