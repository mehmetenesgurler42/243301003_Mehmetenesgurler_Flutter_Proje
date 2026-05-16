import 'package:flutter/material.dart';
import '../models/blood_request_model.dart';
import '../services/database_service.dart';

class BloodRequestProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  List<BloodRequest> _requests = [];
  List<BloodRequest> _filteredRequests = [];
  bool _isLoading = false;
  String? _selectedBloodType;
  String _searchQuery = '';

  List<BloodRequest> get requests => _filteredRequests;
  bool get isLoading => _isLoading;
  String? get selectedBloodType => _selectedBloodType;

  void setFilter(String? bloodType) {
    _selectedBloodType = bloodType;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredRequests = _requests.where((req) {
      final matchesBlood = _selectedBloodType == null || req.bloodType == _selectedBloodType;
      final matchesSearch = req.patientName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            req.city.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesBlood && matchesSearch;
    }).toList();
    notifyListeners();
  }

  Future<void> fetchRequests() async {
    _isLoading = true;
    notifyListeners();
    try {
      // İlk çalıştırmada örnek veri ekle
      await _dbService.seedSampleRequests();
      _requests = await _dbService.getBloodRequests();
      _applyFilters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRequest(BloodRequest request) async {
    await _dbService.createBloodRequest(request);
    await fetchRequests();
  }

  Future<void> updateRequest(String id, Map<String, dynamic> data) async {
    await _dbService.updateBloodRequest(id, data);
    await fetchRequests();
  }

  Future<void> deleteRequest(String id) async {
    await _dbService.deleteBloodRequest(id);
    await fetchRequests();
  }
}
