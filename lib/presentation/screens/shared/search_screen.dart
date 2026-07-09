import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/repositories/opportunity_repository.dart';
import '../student/opportunity_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All', 'Engineering', 'Design', 'Business', 'Data Science', 'Marketing'
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //  Search bar 
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            onChanged: (val) => setState(() => _query = val.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search opportunities...',
              hintStyle: const TextStyle(color: AppColors.neutral),
              prefixIcon: const Icon(Icons.search, color: AppColors.neutral),
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          //  Category filters 
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = _selectedCategory == _categories[i];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = _categories[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.secondary : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_categories[i],
                        style: TextStyle(
                            color: selected ? Colors.black : AppColors.neutral,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          //  Results 
          Expanded(
            child: StreamBuilder<List<OpportunityModel>>(
              stream: OpportunityRepository().streamActiveOpportunities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.secondary));
                }

                final all = snapshot.data ?? [];

                // Filter by query and category
                final results = all.where((opp) {
                  final matchesQuery = _query.isEmpty ||
                      opp.title.toLowerCase().contains(_query) ||
                      opp.startupName.toLowerCase().contains(_query) ||
                      opp.requiredSkills.any((s) => s.toLowerCase().contains(_query));
                  final matchesCategory = _selectedCategory == 'All' ||
                      opp.category == _selectedCategory;
                  return matchesQuery && matchesCategory;
                }).toList();

                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off, color: AppColors.neutral, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _query.isEmpty
                              ? 'Start typing to search opportunities'
                              : 'No results for "$_query"',
                          style: const TextStyle(color: AppColors.neutral),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final opp = results[index];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OpportunityDetailScreen(opportunity: opp),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.rocket_launch,
                                  color: AppColors.secondary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(opp.startupName,
                                          style: const TextStyle(
                                              color: AppColors.neutral, fontSize: 12)),
                                      if (opp.isVerifiedVenture) ...[
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified,
                                            color: AppColors.secondary, size: 12),
                                      ],
                                    ],
                                  ),
                                  Text(opp.title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    children: opp.requiredSkills
                                        .take(2)
                                        .map((s) => Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.background,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(s,
                                                  style: const TextStyle(
                                                      color: AppColors.neutral,
                                                      fontSize: 10)),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.neutral),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}