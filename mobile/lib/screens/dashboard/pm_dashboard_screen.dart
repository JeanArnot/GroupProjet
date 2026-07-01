import 'package:flutter/material.dart';
import 'package:mobile/widgets/app_drawer.dart';
import 'package:mobile/screens/settings/settings_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

class PmDashboardScreen extends StatefulWidget {
  const PmDashboardScreen({Key? key}) : super(key: key);

  @override
  _PmDashboardScreenState createState() => _PmDashboardScreenState();
}

class _PmDashboardScreenState extends State<PmDashboardScreen> {
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
            SnackBar(content: Text('Erreur: ${response.statusCode} - Impossible de charger le dashboard PM')),
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

    final String totalMembers = _dashboardData['totalMembers']?.toString() ?? "0";
    final String assignedTasks = _dashboardData['assignedTasks']?.toString() ?? "0";
    final double progress = (_dashboardData['progress'] as num?)?.toDouble() ?? 0.0;
    final int progressPercent = (progress * 100).toInt();
    final String totalMilestones = _dashboardData['totalMilestones']?.toString() ?? "0";
    final String overdueTasks = _dashboardData['overdueTasks']?.toString() ?? "0";
    final String activeProjects = _dashboardData['activeProjects']?.toString() ?? "0";
    final String delayedTaskAlert = _dashboardData['delayedTaskAlert'] ?? 'Aucun retard détecté';
    final List<dynamic> upcomingDeadlines = _dashboardData['upcomingDeadlines'] ?? [];
    final List<dynamic> recentActivities = _dashboardData['recentActivities'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E1B4B)),
        title: const Text(
          'Dashboard Chef de Projet',
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
                'Pilotage de l\'équipe',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Membres', totalMembers, Icons.group, Colors.blue.shade50, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Tâches assignées', assignedTasks, Icons.task, Colors.orange.shade50, Colors.orange)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Progression globale', '$progressPercent%', Icons.trending_up, Colors.green.shade50, Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Projets actifs', activeProjects, Icons.flag, Colors.purple.shade50, Colors.purple)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Jalons', totalMilestones, Icons.flag, Colors.purple.shade50, Colors.purple)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Retards', overdueTasks, Icons.warning_amber, Colors.red.shade50, Colors.red)),
                ],
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 32),
              const Text(
                'Alertes & Retards',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
              ),
              const SizedBox(height: 16),
              if (delayedTaskAlert == 'Aucun retard détecté')
                _buildActivityItem('Tout est à jour', 'Aucun problème', Icons.check_circle, Colors.green)
              else
                _buildActivityItem(delayedTaskAlert, 'Attention requise', Icons.warning, Colors.red),
              const SizedBox(height: 24),
              const Text('Echeances proches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
              const SizedBox(height: 12),
              if (upcomingDeadlines.isEmpty)
                _buildActivityItem('Aucune echeance proche', 'Tout est a jour', Icons.check_circle, Colors.green)
              else
                ...upcomingDeadlines.take(3).map((item) => _buildActivityItem(item.toString(), 'Echeance planifiee', Icons.event_note, Colors.orange)).toList(),
              const SizedBox(height: 24),
              const Text('Activites recentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
              const SizedBox(height: 12),
              if (recentActivities.isEmpty)
                _buildActivityItem('Aucune activite recente', 'Recemment', Icons.history, Colors.indigo)
              else
                ...recentActivities.take(3).map((item) => _buildActivityItem(item.toString(), 'Recemment', Icons.history, Colors.indigo)).toList(),
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

  Widget _buildActivityItem(String text, String subtitle, IconData icon, Color iconColor) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1B4B))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      contentPadding: EdgeInsets.zero,
    );
  }
}
