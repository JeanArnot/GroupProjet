import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/screens/profile/profile_screen.dart';

class ProjectTeamScreen extends StatefulWidget {
  const ProjectTeamScreen({Key? key}) : super(key: key);

  @override
  _ProjectTeamScreenState createState() => _ProjectTeamScreenState();
}

class _ProjectTeamScreenState extends State<ProjectTeamScreen> {
  bool _isLoading = true;
  List<Map<String, String>> _members = [];

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/users' : 'https://groupprojet-production.up.railway.app/api/users';
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
            _members = data.map((json) {
              String role = 'Membre';
              if (json['role'] == 'STUDENT') role = 'Étudiant';
              if (json['role'] == 'TEACHER') role = 'Professeur';
              if (json['role'] == 'ADMIN') role = 'Administrateur';
              
              String name = "${json['firstName'] ?? ''} ${json['lastName'] ?? ''}".trim();
              if (name.isEmpty) {
                name = json['username'] ?? 'Utilisateur Inconnu';
              }
              
              return {
                "name": name,
                "role": role,
                "email": json['email']?.toString() ?? '',
                "phone": json['phone']?.toString() ?? '',
                "university": json['university']?.toString() ?? '',
                "speciality": json['speciality']?.toString() ?? '',
                "status": json['status']?.toString() ?? '',
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
            SnackBar(content: Text('Erreur: ${response.statusCode} - Impossible de charger l\'équipe')),
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

  void _addMember(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une adresse e-mail valide.')),
      );
      return;
    }

    // Indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
      },
    );

    // Simulation d'une requête réseau (ex: API pour inviter un membre)
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    Navigator.pop(context); // fermer le chargement

    setState(() {
      _members.insert(0, { // Ajouter au début de la liste
        "name": email,
        "role": "Invité (En attente)",
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation envoyée à $email avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFD1D5DB)), // Light gray icon
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.white), // White text
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Équipe du projet',
          style: TextStyle(
            color: Color(0xFF1E1B4B),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              'Membres (${_members.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
          ),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                : _members.isEmpty
                  ? const Center(child: Text('Aucun membre trouvé.', style: TextStyle(color: Color(0xFF6B7280))))
                  : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: _members.length,
              separatorBuilder: (context, index) => const Divider(color: Color(0xFFF3F4F6), height: 32),
              itemBuilder: (context, index) {
                final member = _members[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E2136), // Ensure background is explicitly dark matching the app's dark style
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          padding: EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: 24,
                            bottom: MediaQuery.of(context).padding.bottom + 24,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Color(0xFF374151), // Darker avatar bg
                                  child: Icon(Icons.person, size: 40, color: Color(0xFFD1D5DB)), // Lighter icon
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  member['name'] ?? 'Utilisateur Inconnu',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  member['role'] ?? 'Membre',
                                  style: const TextStyle(fontSize: 16, color: Color(0xFF9CA3AF)), // Light gray
                                ),
                                const SizedBox(height: 16),
                              if ((member['email'] ?? '').isNotEmpty)
                                _buildInfoRow(Icons.email_outlined, member['email']!),
                              if ((member['phone'] ?? '').isNotEmpty)
                                _buildInfoRow(Icons.phone_outlined, member['phone']!),
                              if ((member['university'] ?? '').isNotEmpty)
                                _buildInfoRow(Icons.school_outlined, member['university']!),
                              if ((member['speciality'] ?? '').isNotEmpty)
                                _buildInfoRow(Icons.work_outline, member['speciality']!),
                              if ((member['status'] ?? '').isNotEmpty)
                                _buildInfoRow(Icons.info_outline, member['status']!),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Fermer', style: TextStyle(color: Colors.white, fontSize: 16)),
                              )
                            ],
                          ),
                        ),
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFE5E7EB),
                        child: Icon(Icons.person, color: Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member['name']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              member['role']!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                    ],
                  ),
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
            String email = '';
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  backgroundColor: const Color(0xFF1E2136),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Ajouter un membre',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  content: TextField(
                    onChanged: (value) => email = value,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Adresse e-mail du membre',
                      hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    TextButton(
                      child: const Text('Annuler', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Ajouter', style: TextStyle(color: Colors.white, fontSize: 14)),
                      onPressed: () {
                        if (email.isNotEmpty && email.contains('@')) {
                          Navigator.pop(dialogContext);
                          _addMember(email.trim());
                        } else {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Veuillez entrer une adresse e-mail valide.')),
                           );
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Ajouter membre',
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
