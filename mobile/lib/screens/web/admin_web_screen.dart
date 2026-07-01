import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

class AdminWebScreen extends StatefulWidget {
  const AdminWebScreen({Key? key}) : super(key: key);

  @override
  _AdminWebScreenState createState() => _AdminWebScreenState();
}

class _AdminWebScreenState extends State<AdminWebScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/users' : 'https://groupprojet-production.up.railway.app/api/users';
    try {
      final token = await AuthService().getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.get(Uri.parse(baseUrl), headers: headers).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _users = data.map((json) {
              String name = "${json['firstName'] ?? ''} ${json['lastName'] ?? ''}".trim();
              if (name.isEmpty) name = json['username'] ?? 'Utilisateur Inconnu';
              return {
                "name": name,
                "email": json['email'] ?? '',
                "role": json['role'] ?? 'USER',
                "status": json['status'] ?? 'Actif',
              };
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
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text('Administration', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                _buildSidebarItem('Utilisateurs', Icons.people_outline, true),
                _buildSidebarItem('Rôles & Permissions', Icons.shield_outlined, false),
                _buildSidebarItem('Configuration', Icons.settings_outlined, false),
                _buildSidebarItem('Logs Système', Icons.list_alt_outlined, false),
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
                        'Gestion des utilisateurs',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
                      ),
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                          const CircleAvatar(radius: 16, backgroundColor: Color(0xFFEEF2FF), child: Icon(Icons.person, color: Color(0xFF4F46E5))),
                        ],
                      )
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
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
                                      child: const Text('Filtrer par rôle...', style: TextStyle(color: Color(0xFF6B7280))),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
                                      child: const Text('Filtrer par statut...', style: TextStyle(color: Color(0xFF6B7280))),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add, color: Colors.white),
                                  label: const Text('Nouvel utilisateur', style: TextStyle(color: Colors.white)),
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
                            child: _users.isEmpty 
                              ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text("Aucun utilisateur.")))
                              : DataTable(
                              horizontalMargin: 24,
                              columnSpacing: 24,
                              columns: const [
                                DataColumn(label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                                DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                                DataColumn(label: Text('Rôle', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                                DataColumn(label: Text('Statut', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                              ],
                              rows: _users.map((u) => _buildDataRow(
                                u['name'], 
                                u['email'], 
                                u['role'], 
                                u['status'] == 'Actif' ? const Color(0xFF10B981) : const Color(0xFFEF4444)
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

  DataRow _buildDataRow(String name, String email, String role, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            const CircleAvatar(radius: 16, backgroundColor: Color(0xFFE5E7EB), child: Icon(Icons.person, size: 16, color: Color(0xFF9CA3AF))),
            const SizedBox(width: 12),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
          ],
        )),
        DataCell(Text(email, style: const TextStyle(color: Color(0xFF4B5563)))),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(20)),
          child: Text(role, style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 12)),
        )),
        DataCell(Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text('Actif', style: const TextStyle(color: Color(0xFF4B5563))),
          ],
        )),
        DataCell(Row(
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, color: Color(0xFF6B7280), size: 20), onPressed: () {}),
            IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20), onPressed: () {}),
          ],
        )),
      ],
    );
  }
}
