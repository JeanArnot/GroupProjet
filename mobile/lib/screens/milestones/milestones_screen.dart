import 'package:flutter/material.dart';
import 'package:mobile/screens/milestones/create_milestone_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({Key? key}) : super(key: key);

  @override
  _MilestonesScreenState createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  String _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'À venir', 'En cours', 'Terminés'];

  bool _isLoading = true;
  List<Map<String, dynamic>> _milestones = [];

  @override
  void initState() {
    super.initState();
    _fetchMilestones();
  }

  Future<void> _fetchMilestones() async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/milestones' : 'https://groupprojet-production.up.railway.app/api/milestones';
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
            _milestones = data.map((json) {
              String status = json['status'] == 'COMPLETED' || json['status'] == 'DONE' 
                  ? 'Terminés' 
                  : (json['status'] == 'IN_PROGRESS' ? 'En cours' : 'À venir');
                  
              return {
                "id": json['idMilestone'],
                "projectId": json['projectId'],
                "description": json['description'] ?? '',
                "title": json['milestoneName'] ?? json['name'] ?? json['title'] ?? 'Jalon sans nom',
                "date": json['dueDate'] != null ? json['dueDate'].toString().substring(0, 10) : 'Aucune date',
                "dueDate": json['dueDate'],
                "status": status,
                "rawStatus": json['status'],
                "completionPercentage": json['completionPercentage'],
                "color": status == 'Terminés' ? const Color(0xFF10B981) : (status == 'En cours' ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF)),
                "icon": status == 'Terminés' ? Icons.check_circle : (status == 'En cours' ? Icons.adjust : Icons.radio_button_unchecked),
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
            SnackBar(content: Text('Erreur: ${response.statusCode} - Impossible de charger les jalons')),
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

  Future<void> _editMilestone(Map<String, dynamic> milestone) async {
    final id = milestone['id'];
    if (id == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMilestoneScreen(
          milestoneId: id,
          projectId: milestone['projectId'],
          milestoneToEdit: milestone,
        ),
      ),
    );
    setState(() => _isLoading = true);
    _fetchMilestones();
  }

  Future<void> _deleteMilestone(Map<String, dynamic> milestone) async {
    final id = milestone['id'];
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le jalon'),
        content: Text('Voulez-vous vraiment supprimer "${milestone['title']}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    final String url = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/milestones/$id' : 'https://groupprojet-production.up.railway.app/api/milestones/$id';
    try {
      final response = await http.delete(Uri.parse(url), headers: await _authHeaders()).timeout(const Duration(seconds: 30));
      if (response.statusCode == 204 || response.statusCode == 200) {
        if (mounted) {
          setState(() => _milestones.removeWhere((item) => item['id'] == id));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jalon supprime avec succes'), backgroundColor: Color(0xFF10B981)));
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
    List<Map<String, dynamic>> filteredMilestones = _milestones;
    if (_selectedFilter == 'À venir') {
      filteredMilestones = _milestones.where((m) => m['status'] == 'À venir').toList();
    } else if (_selectedFilter == 'Terminés') {
      filteredMilestones = _milestones.where((m) => m['status'] == 'Terminés').toList();
    } else if (_selectedFilter == 'En cours') {
      filteredMilestones = _milestones.where((m) => m['status'] == 'En cours').toList();
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
          'Jalons (Milestones)',
          style: TextStyle(
            color: Color(0xFF1E1B4B),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF4B5563),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Timeline List
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                : filteredMilestones.isEmpty 
                  ? const Center(child: Text('Aucun jalon trouvé.', style: TextStyle(color: Color(0xFF6B7280))))
                  : ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: filteredMilestones.length,
              itemBuilder: (context, index) {
                final milestone = filteredMilestones[index];
                final isLast = index == filteredMilestones.length - 1;
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator
                    Column(
                      children: [
                        Icon(
                          milestone['icon'],
                          color: milestone['color'],
                          size: 24,
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 60,
                            color: const Color(0xFFE5E7EB),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    milestone['title'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E1B4B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    milestone['date'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              milestone['status'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: milestone['color'],
                              ),
                            ),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.more_vert, color: Color(0xFF9CA3AF)),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editMilestone(milestone);
                                } else if (value == 'delete') {
                                  _deleteMilestone(milestone);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'edit', child: Text('Modifier')),
                                PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateMilestoneScreen()),
            ).then((_) {
              setState(() {
                _isLoading = true;
              });
              _fetchMilestones();
            });
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Nouveau Jalon',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
