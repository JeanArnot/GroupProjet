import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

class ProjectsWebScreen extends StatefulWidget {
  const ProjectsWebScreen({Key? key}) : super(key: key);

  @override
  _ProjectsWebScreenState createState() => _ProjectsWebScreenState();
}

class _ProjectsWebScreenState extends State<ProjectsWebScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _projects = [];

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/projects' : 'https://groupprojet-production.up.railway.app/api/projects';
    try {
      final token = await AuthService().getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.get(Uri.parse(baseUrl), headers: headers).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _projects = data.map((json) => {
              "id": json['idProject'] ?? json['id'] ?? 0,
              "title": json['projectName'] ?? json['name'] ?? json['title'] ?? 'Projet sans nom',
              "course": "Cours", // Backend doesn't have course directly on project yet
              "supervisor": "Encadrant", // Backend doesn't return supervisor explicitly yet
              "progress": (json['progress'] ?? 0.0).toDouble(),
              "status": json['status'] ?? 'ACTIVE',
              "endDate": json['endDate'] != null ? json['endDate'].toString().substring(0, 10) : 'Non défini',
              "color": const Color(0xFF4F46E5), 
              "icon": Icons.folder,
            }).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() { _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _buildSidebarItem('Tableau de bord', Icons.dashboard_outlined, false),
                _buildSidebarItem('Projets', Icons.folder_outlined, true),
                _buildSidebarItem('Tâches', Icons.task_alt, false),
                _buildSidebarItem('Jalons', Icons.flag_outlined, false),
                _buildSidebarItem('Soumissions', Icons.file_upload_outlined, false),
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
                        'Gestion des projets',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
                      ),
                      const CircleAvatar(radius: 16, backgroundColor: Color(0xFFEEF2FF), child: Icon(Icons.person, color: Color(0xFF4F46E5))),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          // Table Header/Toolbar
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
                                  child: const Text('Tous les statuts...', style: TextStyle(color: Color(0xFF6B7280))),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add, color: Colors.white),
                                  label: const Text('Nouveau projet', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          
                          // Table
                          SizedBox(
                            width: double.infinity,
                            child: _projects.isEmpty 
                              ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text("Aucun projet trouvé.")))
                              : DataTable(
                              horizontalMargin: 24,
                              columnSpacing: 24,
                              columns: const [
                                DataColumn(label: Text('Projet', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                                DataColumn(label: Text('Cours', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                                DataColumn(label: Text('Encadrant', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                                DataColumn(label: Text('Échéance', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                                DataColumn(label: Text('Progression', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                                DataColumn(label: Text('Statut', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                              ],
                              rows: _projects.map((p) => _buildDataRow(
                                p['title'], 
                                p['icon'], 
                                p['color'], 
                                p['course'], 
                                p['supervisor'], 
                                p['endDate'], 
                                p['progress'], 
                                p['status'], 
                                p['status'] == 'ACTIVE' ? const Color(0xFF10B981) : const Color(0xFFF59E0B)
                              )).toList(),
                            ),
                          ),
                        ],
                      ),
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

  DataRow _buildDataRow(String title, IconData icon, Color color, String cours, String encadrant, String date, double progress, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
          ],
        )),
        DataCell(Text(cours, style: const TextStyle(color: Color(0xFF4B5563)))),
        DataCell(Text(encadrant, style: const TextStyle(color: Color(0xFF4B5563)))),
        DataCell(Text(date, style: const TextStyle(color: Color(0xFF4B5563)))),
        DataCell(Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Color(0xFF4B5563), fontSize: 12)),
          ],
        )),
        DataCell(Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold))),
      ],
    );
  }
}
