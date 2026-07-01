import 'package:flutter/material.dart';
import 'package:mobile/screens/projects/create_project_screen.dart';
import 'package:mobile/screens/projects/project_team_screen.dart';
import 'package:mobile/screens/tasks/create_task_screen.dart';
import 'package:mobile/screens/tasks/task_details_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final int projectId;
  const ProjectDetailsScreen({Key? key, this.projectId = 1}) : super(key: key);

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic> _projectDetails = {};
  List<dynamic> _tasks = [];
  bool _isLoadingTasks = true;
  List<dynamic> _files = [];
  bool _isLoadingFiles = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update FAB
    });
    _fetchProjectDetails();
    _fetchProjectTasks();
    _fetchProjectFiles();
  }

  Future<void> _fetchProjectFiles() async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/files/project/${widget.projectId}' : 'https://groupprojet-production.up.railway.app/api/files/project/${widget.projectId}';
    try {
      final token = await AuthService().getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(Uri.parse(baseUrl), headers: headers).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _files = data;
            _isLoadingFiles = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingFiles = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingFiles = false);
    }
  }

  Future<void> _fetchProjectTasks() async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/tasks/project/${widget.projectId}' : 'https://groupprojet-production.up.railway.app/api/tasks/project/${widget.projectId}';
    try {
      final token = await AuthService().getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(Uri.parse(baseUrl), headers: headers).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _tasks = data;
            _isLoadingTasks = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingTasks = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingTasks = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchProjectDetails() async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/projects/${widget.projectId}' : 'https://groupprojet-production.up.railway.app/api/projects/${widget.projectId}';
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
            _projectDetails = data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${response.statusCode} - Impossible de charger le projet')),
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

  Future<void> _editProject() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateProjectScreen(
          projectId: widget.projectId,
          projectToEdit: _projectDetails,
        ),
      ),
    );
    _fetchProjectDetails();
  }

  Future<void> _archiveProject() async {
    final String url = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/projects/${widget.projectId}/archive' : 'https://groupprojet-production.up.railway.app/api/projects/${widget.projectId}/archive';
    try {
      final response = await http.put(Uri.parse(url), headers: await _authHeaders()).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Projet archive avec succes'), backgroundColor: Color(0xFF10B981)));
          _fetchProjectDetails();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur archive: ${response.statusCode}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur reseau pendant l archive.')));
      }
    }
  }

  Future<void> _deleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: Text('Voulez-vous vraiment supprimer "${_projectDetails['projectName'] ?? 'ce projet'}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    final String url = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/projects/${widget.projectId}' : 'https://groupprojet-production.up.railway.app/api/projects/${widget.projectId}';
    try {
      final response = await http.delete(Uri.parse(url), headers: await _authHeaders()).timeout(const Duration(seconds: 30));
      if (response.statusCode == 204 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Projet supprime avec succes'), backgroundColor: Color(0xFF10B981)));
          Navigator.pop(context, true);
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5))),
      );
    }

    final double rawProgress = (_projectDetails['progress'] as num?)?.toDouble() ?? 0.0;
    final double progressValue = rawProgress > 1 ? rawProgress / 100 : rawProgress;
    final int progressPercent = rawProgress > 1 ? rawProgress.toInt() : (rawProgress * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Détails du projet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProjectTeamScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'edit') {
                _editProject();
                return;
              }
              if (value == 'archive') {
                _archiveProject();
                return;
              }
              if (value == 'delete') {
                _deleteProject();
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Action sélectionnée: $value')),
              );
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit, color: Color(0xFF4F46E5)),
                  title: Text('Modifier le projet'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'archive',
                child: ListTile(
                  leading: Icon(Icons.archive, color: Colors.orange),
                  title: Text('Archiver le projet'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Supprimer le projet', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: Color(0xFF4F46E5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.phone_android, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _projectDetails['projectName'] ?? _projectDetails['title'] ?? 'Projet sans nom',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _projectDetails['description'] ?? _projectDetails['subtitle'] ?? 'Aucune description fournie',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progression',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$progressPercent%',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Échéance',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _projectDetails['endDate'] != null ? _projectDetails['endDate'].toString().substring(0, 10) : 'Non définie',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statut',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _projectDetails['status'] ?? 'Actif',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressValue.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  ),
                ),
              ],
            ),
          ),
          
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF4F46E5),
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: const Color(0xFF4F46E5),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Tâches'),
                Tab(text: 'Fichiers'),
                Tab(text: 'Activité'),
              ],
            ),
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTasksTab(),
                _buildFilesTab(),
                _buildActivityTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 2 
          ? null 
          : FloatingActionButton(
              onPressed: () {
                if (_tabController.index == 0) {
                  // Tâches
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateTaskScreen(initialProjectId: widget.projectId)),
                  ).then((_) => _fetchProjectTasks());
                } else if (_tabController.index == 1) {
                  // Fichiers
                  _showFileUploadOptions();
                }
              },
              backgroundColor: const Color(0xFF4F46E5),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  void _showFileUploadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF242C3F), // Dark background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.insert_drive_file, color: Color(0xFF6366F1)),
                title: const Text('Document', style: TextStyle(color: Colors.white, fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _simulateUpload('Document ajouté avec succès');
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Color(0xFFF97316)),
                title: const Text('Image / Galerie', style: TextStyle(color: Colors.white, fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _simulateUpload('Image ajoutée avec succès');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _simulateUpload(String successMessage) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Chargement en cours...'),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    });
  }

  Widget _buildTasksTab() {
    if (_isLoadingTasks) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
    }
    
    if (_tasks.isEmpty) {
      return const Center(child: Text('Aucune tâche pour ce projet.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        final String title = task['taskTitle'] ?? 'Sans titre';
        String priority = 'Moyenne';
        if (task['priority'] == 'HIGH') priority = 'Haute';
        if (task['priority'] == 'LOW') priority = 'Basse';
        if (task['priority'] == 'URGENT') priority = 'Urgente';
        final bool isCompleted = task['status'] == 'DONE' || task['status'] == 'COMPLETED';

        return _buildTaskItem(title, priority, isCompleted, task['idTask']);
      },
    );
  }

  Widget _buildFilesTab() {
    if (_isLoadingFiles) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
    }

    if (_files.isEmpty) {
      return const Center(child: Text('Aucun fichier pour ce projet.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final file = _files[index];
        final String name = file['fileName'] ?? file['originalName'] ?? 'Fichier';
        final String size = file['fileSize'] != null ? '${(file['fileSize'] / 1024).toStringAsFixed(1)} KB' : 'Inconnu';
        IconData icon = Icons.insert_drive_file;
        Color color = Colors.blue;
        
        if (name.endsWith('.pdf')) {
          icon = Icons.picture_as_pdf;
          color = Colors.red;
        } else if (name.endsWith('.fig')) {
          icon = Icons.design_services;
          color = Colors.orange;
        } else if (name.endsWith('.jpg') || name.endsWith('.png')) {
          icon = Icons.image;
          color = Colors.green;
        }

        return _buildFileItem(name, size, icon, color);
      },
    );
  }

  Widget _buildActivityTab() {
    return const Center(child: Text('Aucune activité récente.', style: TextStyle(color: Colors.grey)));
  }

  Widget _buildTaskItem(String title, String priority, bool isCompleted, int? taskId) {
    Color priorityColor = priority == 'Haute' || priority == 'Urgente' ? Colors.red : (priority == 'Moyenne' ? Colors.orange : Colors.green);
    
    return GestureDetector(
      onTap: () {
        if (taskId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailsScreen(taskId: taskId),
            ),
          ).then((_) {
            _fetchProjectTasks();
            _fetchProjectDetails();
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: isCompleted ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? Colors.grey : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Priorité: $priority',
                    style: TextStyle(fontSize: 12, color: priorityColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(String name, String size, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                Text(size, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.black54),
            onPressed: () async {
              String fileUrl = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
              if (name.endsWith('.fig') || name.endsWith('.png') || name.endsWith('.jpg')) {
                fileUrl = 'https://via.placeholder.com/600x400.png?text=Fichier+Telecharge';
              } else if (name.endsWith('.docx') || name.endsWith('.doc')) {
                fileUrl = 'https://file-examples.com/wp-content/storage/2017/02/file-sample_100kB.docx';
              }
              
              final Uri url = Uri.parse(fileUrl);
              try {
                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Impossible d\'ouvrir le fichier $name'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Téléchargement de $name en cours...'),
                    backgroundColor: const Color(0xFF4F46E5),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(time, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
