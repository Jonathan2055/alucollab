import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/repositories/opportunity_repository.dart';

class ModerationFeedScreen extends StatefulWidget {
  const ModerationFeedScreen({super.key});

  @override
  State<ModerationFeedScreen> createState() => _ModerationFeedScreenState();
}

class _ModerationFeedScreenState extends State<ModerationFeedScreen> {
  int _filterIndex = 0;
  final List<String> _filters = ['All Listings', 'Reported', 'Ventures', 'Categories'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Moderation Feed',
                      style: TextStyle(
                          color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text('Oversee and prune live internship opportunities.',
                      style: TextStyle(color: AppColors.neutral, fontSize: 13)),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_filters.length, (i) {
                        final selected = _filterIndex == i;
                        return GestureDetector(
                          onTap: () => setState(() => _filterIndex = i),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.secondary : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(_filters[i],
                                style: TextStyle(
                                    color: selected ? Colors.black : AppColors.neutral,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<OpportunityModel>>(
                stream: OpportunityRepository().streamActiveOpportunities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: AppColors.secondary));
                  }
                  final opps = snapshot.data ?? [];
                  if (opps.isEmpty) {
                    return const Center(
                        child: Text('No listings to moderate.',
                            style: TextStyle(color: AppColors.neutral)));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: opps.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _ModerationCard(opportunity: opps[index], reportCount: index * 2),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModerationCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final int reportCount;
  const _ModerationCard({required this.opportunity, required this.reportCount});

  @override
  Widget build(BuildContext context) {
    final hasReports = reportCount > 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.background,
                child: const Icon(Icons.rocket_launch, color: AppColors.secondary, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(opportunity.startupName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        if (opportunity.isVerifiedVenture) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: AppColors.secondary, size: 12),
                        ],
                      ],
                    ),
                    const Text('VENTURE OWNER',
                        style: TextStyle(color: AppColors.neutral, fontSize: 10)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasReports
                      ? Colors.redAccent.withOpacity(0.15)
                      : AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasReports ? '$reportCount REPORTS' : 'CLEAN FEED',
                  style: TextStyle(
                      color: hasReports ? Colors.redAccent : AppColors.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(opportunity.title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(opportunity.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.neutral, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6, runSpacing: 4,
            children: opportunity.requiredSkills
                .take(2)
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(s,
                          style:
                              const TextStyle(color: AppColors.neutral, fontSize: 11)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF334155)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Moderate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.15),
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Remove Listing?', style: TextStyle(color: Colors.white)),
        content: Text('Remove "${opportunity.title}" from the ecosystem?',
            style: const TextStyle(color: AppColors.neutral)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.neutral)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              await OpportunityRepository().adminDeleteOpportunity(opportunity.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Listing removed.')),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}