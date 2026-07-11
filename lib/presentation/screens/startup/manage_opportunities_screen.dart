import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../providers/opportunity_provider.dart';
import 'post_opportunity_screen.dart';
import 'applicant_list_screen.dart';

class ManageOpportunitiesScreen extends StatelessWidget {
  final String startupId;
  final String startupName;
  const ManageOpportunitiesScreen({
    super.key,
    required this.startupId,
    required this.startupName,
  });

  @override
  Widget build(BuildContext context) {
    final oppProvider = context.read<OpportunityProvider>();

    return Column(
      children: [
        Expanded(
          child: Container(
            color: AppColors.background(context),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage Opportunities',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Review and update active listings.',
                      style: TextStyle(color: AppColors.neutral, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: StreamBuilder<List<OpportunityModel>>(
                        stream: oppProvider.streamStartupOpportunities(
                          startupId,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.secondary,
                              ),
                            );
                          }

                          final opps = snapshot.data ?? [];

                          if (opps.isEmpty) {
                            return const Center(
                              child: Text(
                                'No listings yet. Tap + to post one.',
                                style: TextStyle(color: AppColors.neutral),
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: opps.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final opp = opps[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.background(context),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  opp.category,
                                                  style: const TextStyle(
                                                    color: AppColors.secondary,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                              if (opp.isVerifiedVenture) ...[
                                                const SizedBox(width: 6),
                                                const Icon(
                                                  Icons.verified,
                                                  color: AppColors.secondary,
                                                  size: 14,
                                                ),
                                                const Text(
                                                  ' ALU Verified',
                                                  style: TextStyle(
                                                    color: AppColors.secondary,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            opp.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.people_outline,
                                                color: AppColors.neutral,
                                                size: 14,
                                              ),
                                              Text(
                                                ' ${opp.applicantCount} Applicants',
                                                style: const TextStyle(
                                                  color: AppColors.neutral,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Icon(
                                                Icons.schedule,
                                                color: AppColors.neutral,
                                                size: 14,
                                              ),
                                              Text(
                                                ' ${opp.durationMonths}mo',
                                                style: const TextStyle(
                                                  color: AppColors.neutral,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.people_outline, color: AppColors.secondary),
                                          onPressed: () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => ApplicantListScreen(
                                                opportunityId: opp.id,
                                                opportunityTitle: opp.title,
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () =>
                                              _confirmDelete(context, opp),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20, right: 20),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.add, color: Colors.black),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PostOpportunityScreen(
                    startupId: startupId,
                    startupName: startupName,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, OpportunityModel opp) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Delete Listing?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove "${opp.title}" permanently?',
          style: const TextStyle(color: AppColors.neutral),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.neutral),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<OpportunityProvider>().deleteOpportunity(
                opp.id,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
