import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/application_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/application_repository.dart';

class ApplicantListScreen extends StatelessWidget {
  final String opportunityId;
  final String opportunityTitle;

  const ApplicantListScreen({
    super.key,
    required this.opportunityId,
    required this.opportunityTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(opportunityTitle,
            style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: StreamBuilder<List<ApplicationModel>>(
        stream: ApplicationRepository()
            .streamOpportunityApplications(opportunityId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.secondary));
          }

          final applications = snapshot.data ?? [];

          if (applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline,
                      color: AppColors.neutral, size: 48),
                  const SizedBox(height: 12),
                  Text('No applicants yet.',
                      style: TextStyle(
                          color: AppColors.textSecondary(context))),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statChip('Total',
                        '${applications.length}', Colors.white),
                    _statChip(
                        'Interview',
                        '${applications.where((a) => a.status == ApplicationStatus.interview).length}',
                        const Color(0xFF38BDF8)),
                    _statChip(
                        'Accepted',
                        '${applications.where((a) => a.status == ApplicationStatus.accepted).length}',
                        AppColors.secondary),
                  ],
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: applications.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _ApplicantCard(
                      application: applications[index],
                      opportunityTitle: opportunityTitle,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                color: AppColors.neutral, fontSize: 12)),
      ],
    );
  }
}

class _ApplicantCard extends StatefulWidget {
  final ApplicationModel application;
  final String opportunityTitle;

  const _ApplicantCard({
    required this.application,
    required this.opportunityTitle,
  });

  @override
  State<_ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends State<_ApplicantCard> {
  bool _isExpanded = false;
  UserModel? _studentProfile;
  bool _loadingProfile = false;

  Future<void> _loadProfile() async {
    if (_studentProfile != null) return;
    setState(() => _loadingProfile = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.application.studentId)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _studentProfile = UserModel.fromSnapshot(doc);
          _loadingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.accepted:
        return AppColors.secondary;
      case ApplicationStatus.interview:
        return const Color(0xFF38BDF8);
      case ApplicationStatus.withdrawn:
        return Colors.redAccent;
      default:
        return AppColors.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border(
            left: BorderSide(
                color: _statusColor(app.status), width: 3)),
      ),
      child: Column(
        children: [
          //  Main row 
          ListTile(
            onTap: () {
              final willExpand = !_isExpanded;
              setState(() => _isExpanded = willExpand);
              if (willExpand) _loadProfile();
            },
            leading: CircleAvatar(
              backgroundColor: AppColors.secondary.withOpacity(0.2),
              child: Text(
                _studentProfile?.fullName.isNotEmpty == true
                    ? _studentProfile!.fullName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              _studentProfile?.fullName ?? 'Loading...',
              style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              _studentProfile?.email ?? app.studentId,
              style: const TextStyle(
                  color: AppColors.neutral, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(app.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    app.status.name.toUpperCase(),
                    style: TextStyle(
                        color: _statusColor(app.status),
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.neutral,
                ),
              ],
            ),
          ),

          //  Expanded details 
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFF334155)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _loadingProfile
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.secondary))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_studentProfile != null) ...[
                          _infoRow(Icons.badge_outlined, 'Student ID',
                              _studentProfile!.studentId ?? 'N/A'),
                          const SizedBox(height: 8),

                          if (_studentProfile!.bio.isNotEmpty) ...[
                            const Text('Bio',
                                style: TextStyle(
                                    color: AppColors.neutral,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(_studentProfile!.bio,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.5)),
                            const SizedBox(height: 12),
                          ],

                          if (_studentProfile!.experience.isNotEmpty) ...[
                            const Text('Experience',
                                style: TextStyle(
                                    color: AppColors.neutral,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            ..._studentProfile!.experience.map((exp) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.work_outline,
                                          color: AppColors.neutral, size: 14),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(exp,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 12),
                          ],

                          if (_studentProfile!.coreCompetencies.isNotEmpty) ...[
                            const Text('Core Competencies',
                                style: TextStyle(
                                    color: AppColors.neutral,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _studentProfile!
                                  .coreCompetencies
                                  .map((skill) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: AppColors.secondary
                                                  .withOpacity(0.3)),
                                        ),
                                        child: Text(skill,
                                            style: const TextStyle(
                                                color: AppColors.secondary,
                                                fontSize: 11)),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 12),
                          ],

                          if (_studentProfile!.linkedinUrl?.isNotEmpty == true) ...[
                            _infoRow(Icons.link, 'LinkedIn',
                                _studentProfile!.linkedinUrl!),
                            const SizedBox(height: 8),
                          ],

                          if (_studentProfile!.githubUrl?.isNotEmpty == true) ...[
                            _infoRow(Icons.code, 'GitHub',
                                _studentProfile!.githubUrl!),
                            const SizedBox(height: 12),
                          ],

                          _infoRow(Icons.calendar_today_outlined, 'Applied',
                              _timeAgo(app.appliedAt)),
                          const SizedBox(height: 16),
                        ],

                        //  Action buttons 
                        if (app.status != ApplicationStatus.accepted)
                          Row(
                            children: [
                              if (app.status !=
                                  ApplicationStatus.interview)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _updateStatus(
                                        context,
                                        ApplicationStatus.interview),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          const Color(0xFF38BDF8),
                                      side: const BorderSide(
                                          color: Color(0xFF38BDF8)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Invite Interview'),
                                  ),
                                ),
                              if (app.status !=
                                  ApplicationStatus.interview)
                                const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _updateStatus(
                                      context,
                                      ApplicationStatus.accepted),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Accept',
                                      style:
                                          TextStyle(color: Colors.black)),
                                ),
                              ),
                            ],
                          ),

                        if (app.status != ApplicationStatus.withdrawn)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () => _updateStatus(
                                    context,
                                    ApplicationStatus.withdrawn),
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.redAccent),
                                child: const Text('Reject Applicant'),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _updateStatus(
      BuildContext context, ApplicationStatus status) async {
    try {
      await ApplicationRepository().updateApplicationStatus(
        widget.application.id,
        status,
        widget.application.studentId,
        widget.opportunityTitle,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Status updated to ${status.name}. Student notified.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neutral, size: 14),
        const SizedBox(width: 6),
        Text('$label: ',
            style: const TextStyle(
                color: AppColors.neutral, fontSize: 12)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 12,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}