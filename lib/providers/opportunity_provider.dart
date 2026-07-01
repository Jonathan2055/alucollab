import 'package:flutter/material.dart';
import '../data/repositories/opportunity_repository.dart';
import '../data/models/opportunity_model.dart';

class OpportunityProvider extends ChangeNotifier {
  final OpportunityRepository _repo = OpportunityRepository();

  List<OpportunityModel> _opportunities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OpportunityModel> get opportunities => _opportunities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Returns a live stream — used directly in StreamBuilder widgets.
  Stream<List<OpportunityModel>> streamActiveOpportunities() {
    return _repo.streamActiveOpportunities();
  }

  Stream<List<OpportunityModel>> streamStartupOpportunities(String startupId) {
    return _repo.streamStartupOpportunities(startupId);
  }

  Future<void> createOpportunity(OpportunityModel opportunity) async {
    _setLoading(true);
    try {
      await _repo.createOpportunity(opportunity);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteOpportunity(String opportunityId) async {
    try {
      await _repo.deleteOpportunity(opportunityId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
