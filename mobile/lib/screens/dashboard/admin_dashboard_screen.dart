import 'package:flutter/material.dart';
import 'package:mobile/widgets/app_drawer.dart';
import 'package:mobile/screens/settings/settings_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/dashboard' : 'https://groupprojet-production.up.railway.app/api/dashboard';
    
    try {
      final token = await AuthService().getToken();
      final headers = {
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(Uri.parse(baseUrl), headers: headers).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _dashboardData = data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${response.statusCode} - Impossible de charger le dashboard admin')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur réseau. Vérifiez votre connexion.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5))),
      );
    }

    final String totalUsers = _dashboardData['totalUsers']?.toString() ?? "0";
    final String totalProjects = _dashboardData['totalProjects']?.toString() ?? "0";
    final String activeUsers = _dashboardData['activeUsers']?.toString() ?? totalUsers;
    final String totalSubmissions = _dashboardData['totalSubmissions']?.toString() ?? "0";
    final String activeProjects = _dashboardData['activeProjects']?.toString() ?? totalProjects;
    final String totalMeetings = _dashboardData['totalMeetings']?.toString() ?? "0";
    final String pendingSubmissions = _dashboardData['pendingSubmissionsCount']?.toString() ?? totalSubmissions;
    final List<dynamic> recentActivities = _dashboardData['recentActivities'] ?? [];
    final String overdueTasks = _dashboardData['overdueTasks']?.toString() ?? "0";
    final int completionRate = ((_dashboardData['completionRate'] as num?)?.toDouble() ?? 0.0).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E1B4B)),
        title: const Text(
          'Dashboard Admin',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF1E1B4B)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vue Globale du Système',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Utilisateurs actifs', activeUsers, Icons.people, Colors.blue.shade50, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Projets actifs', activeProjects, Icons.folder, Colors.green.shade50, Colors.green)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('En attente', pendingSubmissions, Icons.file_upload, Colors.purple.shade50, Colors.purple)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Réunions', totalMeetings, Icons.videocam, Colors.orange.shade50, Colors.orange)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Retards', overdueTasks, Icons.warning_amber, Colors.red.shade50, Colors.red)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Completion', '$completionRate%', Icons.trending_up, Colors.teal.shade50, Colors.teal)),
                ],
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 32),
              const Text(
                'Activités Récentes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
              ),
              const SizedBox(height: 16),
              if (recentActivities.isEmpty)
                const Text('Aucune activité récente.', style: TextStyle(color: Color(0xFF6B7280)))
              else
                ...recentActivities.map((activity) => _buildActivityItem(activity.toString(), 'Récemment', Icons.notifications, Colors.indigo)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: iconColor)),
              Icon(icon, color: iconColor, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text, String time, IconData icon, Color iconColor) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1B4B))),
      subtitle: Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      contentPadding: EdgeInsets.zero,
    );
  }
}
