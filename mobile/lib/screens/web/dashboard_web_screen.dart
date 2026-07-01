import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

class DashboardWebScreen extends StatefulWidget {
  const DashboardWebScreen({Key? key}) : super(key: key);

  @override
  _DashboardWebScreenState createState() => _DashboardWebScreenState();
}

class _DashboardWebScreenState extends State<DashboardWebScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/dashboard' : 'https://groupprojet-production.up.railway.app/api/dashboard';
    try {
      final token = await AuthService().getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.get(Uri.parse(baseUrl), headers: headers).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _dashboardData = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final double progress = (_dashboardData['progress'] as num?)?.toDouble() ?? 0.0;
    final int progressPercent = (progress * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: const Color(0xFF1E1B4B),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFF4F46E5), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.group, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text('GroupProjet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                _buildSidebarItem('Tableau de bord', Icons.dashboard_outlined, true),
                _buildSidebarItem('Projets', Icons.folder_outlined, false),
                _buildSidebarItem('Tâches', Icons.task_alt, false),
                _buildSidebarItem('Jalons', Icons.flag_outlined, false),
                _buildSidebarItem('Soumissions', Icons.file_upload_outlined, false),
                _buildSidebarItem('Notes & Grades', Icons.grade_outlined, false),
                _buildSidebarItem('Réunions', Icons.groups_outlined, false),
                _buildSidebarItem('Calendrier', Icons.calendar_today_outlined, false),
                _buildSidebarItem('Fichiers', Icons.insert_drive_file_outlined, false),
                _buildSidebarItem('Annonces', Icons.announcement_outlined, false),
                const Spacer(),
                _buildSidebarItem('Paramètres', Icons.settings_outlined, false),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24.0),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dashboard',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: const [
                                Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                                SizedBox(width: 8),
                                Text('Tous les cours', style: TextStyle(color: Color(0xFF6B7280))),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
                          const CircleAvatar(radius: 16, backgroundColor: Color(0xFFEEF2FF), child: Icon(Icons.person, color: Color(0xFF4F46E5))),
                        ],
                      )
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Stats Row
                        Row(
                          children: [
                            Expanded(child: _buildStatCard('Projets', _dashboardData['totalProjects']?.toString() ?? '0', Icons.folder, const Color(0xFF4F46E5))),
                            const SizedBox(width: 24),
                            Expanded(child: _buildStatCard('Tâches', _dashboardData['totalTasks']?.toString() ?? '0', Icons.task_alt, const Color(0xFFEF4444))),
                            const SizedBox(width: 24),
                            Expanded(child: _buildStatCard('Jalons', _dashboardData['totalMilestones']?.toString() ?? '0', Icons.flag, const Color(0xFF10B981))),
                            const SizedBox(width: 24),
                            Expanded(child: _buildStatCard('Soumissions', _dashboardData['totalSubmissions']?.toString() ?? '0', Icons.file_upload, const Color(0xFF0EA5E9))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Charts Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Progression globale', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 24),
                                    Text('$progressPercent%', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
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
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Répartition des tâches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF4F46E5), width: 16)),
                                        ),
                                        const SizedBox(width: 24),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildLegend('À faire', const Color(0xFF3B82F6)),
                                            const SizedBox(height: 8),
                                            _buildLegend('En cours', const Color(0xFF10B981)),
                                            const SizedBox(height: 8),
                                            _buildLegend('Terminées', const Color(0xFFF59E0B)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Activité récente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 24),
                                    _buildActivityItem('Tableau synchronisé', 'Avec succès', 'À l\'instant', const Color(0xFF10B981)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String title, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70, size: 20),
        title: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 14)),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Icon(icon, color: color.withOpacity(0.5), size: 32),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14)),
      ],
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String date, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.info_outline, size: 14, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B), fontSize: 14)),
              Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
            ],
          ),
        ),
        Text(date, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
      ],
    );
  }
}
