import 'package:flutter/material.dart';
import 'package:mobile/widgets/app_drawer.dart';
import 'package:mobile/screens/settings/settings_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
            SnackBar(content: Text('Erreur de chargement des données: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur réseau: impossible de se connecter au serveur.')),
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

    final String userName = _dashboardData['userName']?.toString() ?? "Utilisateur";
    final String totalProjects = _dashboardData['totalProjects']?.toString() ?? "0";
    final String totalTasks = _dashboardData['totalTasks']?.toString() ?? "0";
    final String totalMilestones = _dashboardData['totalMilestones']?.toString() ?? "0";
    final String totalSubmissions = _dashboardData['totalSubmissions']?.toString() ?? "0";
    final String activeProjects = _dashboardData['activeProjects']?.toString() ?? totalProjects;
    final String overdueTasks = _dashboardData['overdueTasks']?.toString() ?? "0";
    final String pendingSubmissions = _dashboardData['pendingSubmissionsCount']?.toString() ?? totalSubmissions;
    final double progress = ((_dashboardData['progress'] as num?)?.toDouble() ?? 0.0).clamp(0.0, 1.0);
    final String tasksTodo = _dashboardData['tasksTodo']?.toString() ?? "0";
    final String tasksInProgress = _dashboardData['tasksInProgress']?.toString() ?? "0";
    final String tasksDone = _dashboardData['tasksDone']?.toString() ?? "0";
    final List<dynamic> upcomingDeadlines = _dashboardData['upcomingDeadlines'] ?? [];
    final List<dynamic> recentActivities = _dashboardData['recentActivities'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E1B4B)),
        title: const Text(
          'Tableau de bord',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_center_focus, color: Color(0xFF1E1B4B)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ouverture du Scanner QR Code...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF1E1B4B)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
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
              // Welcome Message
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1B4B),
                  ),
                  children: [
                    const TextSpan(text: 'Bonjour, '),
                    TextSpan(
                      text: userName,
                      style: const TextStyle(color: Color(0xFFF59E0B)),
                    ),
                    const TextSpan(text: ' 👋'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Voici ce qui se passe aujourd\'hui',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              
              // 4 Stat Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Projets actifs',
                      activeProjects,
                      Icons.folder_outlined,
                      const Color(0xFFEEF2FF),
                      const Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Tâches',
                      totalTasks,
                      Icons.task_alt,
                      const Color(0xFFFEF2F2),
                      const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Jalons',
                      totalMilestones,
                      Icons.flag_outlined,
                      const Color(0xFFECFDF5),
                      const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'En attente',
                      pendingSubmissions,
                      Icons.file_upload_outlined,
                      const Color(0xFFF5F3FF),
                      const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTaskStatusCard('En retard', overdueTasks, const Color(0xFFFFF7ED), const Color(0xFFF97316)),
              const SizedBox(height: 32),
              
              // Progression globale
              const Text(
                'Progression globale',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1B4B),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              backgroundColor: const Color(0xFFEEF2FF),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: const Color(0xFFEEF2FF),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                          ),
                          Center(
                            child: Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Tâches status
              const Text(
                'Tâches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1B4B),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTaskStatusCard('À faire', tasksTodo.toString(), const Color(0xFFFEF2F2), const Color(0xFFEF4444)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTaskStatusCard('En cours', tasksInProgress.toString(), const Color(0xFFECFDF5), const Color(0xFF10B981)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTaskStatusCard('Terminées', tasksDone.toString(), const Color(0xFFF0FDF4), const Color(0xFF059669)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Prochaine échéance
              const Text(
                'Prochaine échéance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1B4B),
                ),
              ),
              const SizedBox(height: 16),
              _buildDeadlineItem(
                upcomingDeadlines.isEmpty ? 'Aucune echeance proche' : upcomingDeadlines.first.toString(),
                upcomingDeadlines.isEmpty ? 'Ajouter une nouvelle echeance' : 'Echeance planifiee',
                Icons.event_note,
                const Color(0xFFFFF7ED),
                const Color(0xFFF59E0B),
                onTap: () => _showAddDeadlineDialog(context),
              ),
              const SizedBox(height: 12),
              _buildDeadlineItem(
                recentActivities.isEmpty ? 'Aucune activite recente' : recentActivities.first.toString(),
                recentActivities.isEmpty ? 'Créer une nouvelle activité' : 'Récemment',
                Icons.people_outline,
                const Color(0xFFEEF2FF),
                const Color(0xFF4F46E5),
                onTap: () => _showAddActivityDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStatusCard(String title, String count, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1B4B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineItem(String title, String subtitle, IconData icon, Color iconBgColor, Color iconColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  void _showAddDeadlineDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.event_note, color: Color(0xFFF59E0B)),
              SizedBox(width: 10),
              Text('Nouvelle échéance'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de l\'échéance',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (JJ/MM/AAAA)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty && dateController.text.trim().isNotEmpty) {
                  setState(() {
                    if (_dashboardData['upcomingDeadlines'] == null) {
                       _dashboardData['upcomingDeadlines'] = [];
                    }
                    _dashboardData['upcomingDeadlines'].insert(0, '${titleController.text} - ${dateController.text}');
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Échéance ajoutée avec succès')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir tous les champs')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _showAddActivityDialog(BuildContext context) {
    final TextEditingController descController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.people_outline, color: Color(0xFF4F46E5)),
              SizedBox(width: 10),
              Text('Nouvelle activité'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description de l\'activité',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (descController.text.trim().isNotEmpty) {
                  setState(() {
                    if (_dashboardData['recentActivities'] == null) {
                       _dashboardData['recentActivities'] = [];
                    }
                    _dashboardData['recentActivities'].insert(0, descController.text);
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Activité enregistrée avec succès')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez entrer une description')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }
}
