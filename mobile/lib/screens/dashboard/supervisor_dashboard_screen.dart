import 'package:flutter/material.dart';
import 'package:mobile/widgets/app_drawer.dart';
import 'package:mobile/screens/settings/settings_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({Key? key}) : super(key: key);

  @override
  _SupervisorDashboardScreenState createState() => _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen> {
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
            SnackBar(content: Text('Erreur: ${response.statusCode} - Impossible de charger le dashboard encadreur')),
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

    final String supervisedOrganizations = _dashboardData['supervisedOrganizations']?.toString() ?? "0";
    final String followedProjects = _dashboardData['followedProjects']?.toString() ?? "0";
    final String pendingSubmissions = _dashboardData['pendingSubmissions']?.toString() ?? "0";
    final String upcomingMeetings = _dashboardData['upcomingMeetings']?.toString() ?? "0";
    final String evaluatedSubmissions = _dashboardData['evaluatedSubmissions']?.toString() ?? "0";

    final String overdueTasks = _dashboardData['overdueTasks']?.toString() ?? "0";
    final int completionRate = ((_dashboardData['completionRate'] as num?)?.toDouble() ?? 0.0).round();
    final List<dynamic> upcomingDeadlines = _dashboardData['upcomingDeadlines'] ?? [];
    final List<dynamic> recentActivities = _dashboardData['recentActivities'] ?? [];
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E1B4B)),
        title: const Text(
          'Dashboard Encadreur',
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
                'Vue d\'ensemble des Organizationes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Organizationes encadrés', supervisedOrganizations, Icons.group, Colors.blue.shade50, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Projets suivis', followedProjects, Icons.folder, Colors.green.shade50, Colors.green)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Soumissions en attente', pendingSubmissions, Icons.pending_actions, Colors.orange.shade50, Colors.orange)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Réunions prévues', upcomingMeetings, Icons.event, Colors.purple.shade50, Colors.purple)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Evaluees', evaluatedSubmissions, Icons.fact_check, Colors.teal.shade50, Colors.teal)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Retards', overdueTasks, Icons.warning_amber, Colors.red.shade50, Colors.red)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Completion', '$completionRate%', Icons.trending_up, Colors.green.shade50, Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Echeances', upcomingDeadlines.length.toString(), Icons.event_note, Colors.indigo.shade50, Colors.indigo)),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Activites recentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
              const SizedBox(height: 12),
              if (recentActivities.isEmpty)
                const Text('Aucune activite recente.', style: TextStyle(color: Color(0xFF6B7280)))
              else
                ...recentActivities.take(3).map((item) => ListTile(leading: const Icon(Icons.history, color: Colors.indigo), title: Text(item.toString()), subtitle: const Text('Recemment'), contentPadding: EdgeInsets.zero)).toList(),
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
}
