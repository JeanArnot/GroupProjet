import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

class KanbanWebScreen extends StatefulWidget {
  const KanbanWebScreen({Key? key}) : super(key: key);

  @override
  _KanbanWebScreenState createState() => _KanbanWebScreenState();
}

class _KanbanWebScreenState extends State<KanbanWebScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _todo = [];
  List<Map<String, dynamic>> _inProgress = [];
  List<Map<String, dynamic>> _done = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/tasks' : 'https://groupprojet-production.up.railway.app/api/tasks';
    try {
      final token = await AuthService().getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.get(Uri.parse(baseUrl), headers: headers).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _todo = [];
            _inProgress = [];
            _done = [];
            
            for (var json in data) {
              String status = json['status'] ?? 'TODO';
              var task = {
                "title": json['taskTitle'] ?? json['title'] ?? 'Tâche',
                "project": json['projectName'] ?? 'Projet',
                "priority": json['priority'] == 'HIGH' ? 'Haute' : (json['priority'] == 'LOW' ? 'Basse' : 'Moyenne'),
                "color": json['priority'] == 'HIGH' ? const Color(0xFFEF4444) : (json['priority'] == 'LOW' ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
              };
              
              if (status == 'COMPLETED' || status == 'DONE') {
                _done.add(task);
              } else if (status == 'IN_PROGRESS') {
                _inProgress.add(task);
              } else {
                _todo.add(task);
              }
            }
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
                _buildSidebarItem('Projets', Icons.folder_outlined, false),
                _buildSidebarItem('Tâches', Icons.task_alt, true),
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
                        'Kanban - Tâches',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
                      ),
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
                          const CircleAvatar(radius: 16, backgroundColor: Color(0xFFEEF2FF), child: Icon(Icons.person, color: Color(0xFF4F46E5))),
                        ],
                      )
                    ],
                  ),
                ),
                
                // Kanban Board
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator()) 
                    : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildKanbanColumn('À faire (${_todo.length})', _todo),
                        _buildKanbanColumn('En cours (${_inProgress.length})', _inProgress),
                        _buildKanbanColumn('Terminées (${_done.length})', _done),
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

  Widget _buildKanbanColumn(String title, List<Map<String, dynamic>> tasks) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), // Column background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                const Icon(Icons.more_horiz, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ...tasks.map((t) => _buildKanbanCard(t['title'], t['project'], t['priority'], t['color'])).toList(),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Color(0xFF6B7280)),
                  label: const Text('Ajouter une tâche', style: TextStyle(color: Color(0xFF6B7280))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanCard(String title, String project, String priority, Color priorityColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 12, height: 12, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(color: const Color(0xFF4F46E5), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E1B4B))),
                    const SizedBox(height: 4),
                    Text(project, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: priorityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(priority, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: priorityColor)),
          ),
        ],
      ),
    );
  }
}
