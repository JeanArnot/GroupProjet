import 'package:flutter/material.dart';
import 'package:mobile/screens/tasks/task_details_screen.dart';
import 'package:mobile/screens/tasks/create_task_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _selectedFilter = 'Tout';
  final List<String> _filters = ['Tout', 'À faire', 'En cours', 'Terminées'];

  bool _isLoading = true;
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/tasks' : 'https://groupprojet-production.up.railway.app/api/tasks';
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
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _tasks = data.map((json) {
              String status = json['status'] == 'COMPLETED' || json['status'] == 'DONE' 
                  ? 'Terminées' 
                  : (json['status'] == 'IN_PROGRESS' ? 'En cours' : 'À faire');
              bool completed = json['status'] == 'COMPLETED' || json['status'] == 'DONE';
              
              return {
                "id": json['idTask'] ?? json['id'],
                "description": json['description'] ?? '',
                "projectId": json['projectId'],
                "title": json['taskTitle'] ?? json['title'] ?? 'Tâche sans nom',
                "project": json['projectName'] ?? 'Projet par défaut',
                "priority": json['priority'] == 'HIGH' ? 'Haute' : (json['priority'] == 'LOW' ? 'Basse' : 'Moyenne'),
                "priorityColor": json['priority'] == 'HIGH' ? const Color(0xFFEF4444) : (json['priority'] == 'LOW' ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                "date": json['deadline'] != null ? json['deadline'].toString().substring(5, 10) : 'Aucune date',
                "dueDate": json['deadline'] != null ? json['deadline'].toString().substring(0, 10) : 'Non defini',
                "iconColor": completed ? const Color(0xFF10B981) : const Color(0xFF4F46E5),
                "status": status,
                "completed": completed,
                "assignedToId": json['assignedToId'],
                "assigneeName": json['assigneeName'],
              };
            }).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${response.statusCode} - Impossible de charger les tâches')),
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

  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService().getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  void _sortTasks(String result) {
    setState(() {
      if (result == 'date') {
        _tasks.sort((a, b) => (a['dueDate'] ?? '').toString().compareTo((b['dueDate'] ?? '').toString()));
      } else {
        const weights = {'Haute': 0, 'Moyenne': 1, 'Basse': 2};
        _tasks.sort((a, b) => (weights[a['priority']] ?? 3).compareTo(weights[b['priority']] ?? 3));
      }
    });
  }

  Future<void> _editTask(Map<String, dynamic> task) async {
    final id = task['id'];
    if (id == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTaskScreen(taskToEdit: task, taskId: id)),
    );
    setState(() => _isLoading = true);
    _fetchTasks();
  }

  Future<void> _deleteTask(Map<String, dynamic> task) async {
    final id = task['id'];
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la tache'),
        content: Text('Voulez-vous vraiment supprimer "${task['title']}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    final String url = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/tasks/$id' : 'https://groupprojet-production.up.railway.app/api/tasks/$id';
    try {
      final response = await http.delete(Uri.parse(url), headers: await _authHeaders()).timeout(const Duration(seconds: 30));
      if (response.statusCode == 204 || response.statusCode == 200) {
        if (mounted) {
          setState(() => _tasks.removeWhere((item) => item['id'] == id));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tache supprimee avec succes'), backgroundColor: Color(0xFF10B981)));
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur suppression: ${response.statusCode}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur reseau pendant la suppression.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTasks = _tasks;
    if (_selectedFilter != 'Tout') {
      filteredTasks = _tasks.where((t) => t['status'] == _selectedFilter).toList();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Tâches',
          style: TextStyle(
            color: Color(0xFF1E1B4B),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Color(0xFF1E1B4B), size: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            offset: const Offset(0, 50),
            onSelected: (String result) {
              _sortTasks(result);
              return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Trié par $result')));
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'date',
                child: Text('Trier par date'),
              ),
              const PopupMenuItem<String>(
                value: 'priorité',
                child: Text('Trier par priorité'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF4B5563),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // List
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                : filteredTasks.isEmpty 
                  ? const Center(child: Text('Aucune tâche trouvée.', style: TextStyle(color: Color(0xFF6B7280))))
                  : ListView.separated(
              padding: const EdgeInsets.all(20.0),
              itemCount: filteredTasks.length,
              separatorBuilder: (context, index) => const Divider(color: Color(0xFFF3F4F6), height: 32),
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return GestureDetector(
                  onTap: () {
                    final id = task['id'];
                    if (id == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TaskDetailsScreen(taskId: id)),
                    ).then((_) => _fetchTasks());
                  },
                  child: Container(
                    color: Colors.transparent, // make full row clickable
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Icon
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: task['iconColor'].withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        task['completed'] ? Icons.check_circle : Icons.circle,
                        color: task['iconColor'],
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1B4B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task['project'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task['priority'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: task['priorityColor'],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_vert, color: Color(0xFF9CA3AF)),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editTask(task);
                              return;
                            }
                            if (value == 'delete') {
                              _deleteTask(task);
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action: $value')));
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (task['completed'])
                          const Text(
                            'Terminée',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          )
                        else
                          Text(
                            task['date'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'taskFAB',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
          ).then((_) {
            setState(() {
              _isLoading = true;
            });
            _fetchTasks();
          });
        },
        backgroundColor: const Color(0xFF4F46E5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
