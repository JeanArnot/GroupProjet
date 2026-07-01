import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';

class ProjectProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<ProjectModel> _projects = [];
  bool _isLoading = false;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;

  Future<void> fetchProjects(int organizationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/projects/Organization/$organizationId');
      final List<dynamic> data = response.data;
      _projects = data.map((json) => ProjectModel.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Error fetching projects: ${e.message}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
