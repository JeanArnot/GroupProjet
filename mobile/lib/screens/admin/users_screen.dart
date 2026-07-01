import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/services/auth_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _query = '';
  String _roleFilter = 'ALL';
  List<Map<String, dynamic>> _users = [];

  String get _baseUrl => kIsWeb ? 'https://groupprojet-production.up.railway.app/api/users' : 'https://groupprojet-production.up.railway.app/api/users';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: await _headers()).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          _users = data.map((item) => Map<String, dynamic>.from(item)).toList();
          _isLoading = false;
        });
      } else {
        _showError('Impossible de charger les utilisateurs (${response.statusCode})');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      _showError('Erreur reseau pendant le chargement des utilisateurs.');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      final role = (user['role'] ?? '').toString();
      if (_roleFilter != 'ALL' && role != _roleFilter) return false;
      if (_query.isEmpty) return true;
      final text = [
        user['firstName'],
        user['lastName'],
        user['username'],
        user['email'],
        user['role'],
      ].where((value) => value != null).join(' ').toLowerCase();
      return text.contains(_query.toLowerCase());
    }).toList();
  }

  Map<String, int> get _stats {
    return {
      'total': _users.length,
      'admins': _users.where((user) => user['role'] == 'ADMIN').length,
      'supervisors': _users.where((user) => user['role'] == 'SUPERVISOR').length,
      'members': _users.where((user) => user['role'] == 'MEMBER').length,
      'blocked': _users.where((user) => user['status'] == 'BLOCKED').length,
    };
  }

  Future<void> _openUserDialog({Map<String, dynamic>? user}) async {
    final isEdit = user != null;
    final firstNameController = TextEditingController(text: user?['firstName'] ?? '');
    final lastNameController = TextEditingController(text: user?['lastName'] ?? '');
    final usernameController = TextEditingController(text: user?['username'] ?? '');
    final emailController = TextEditingController(text: user?['email'] ?? '');
    final phoneController = TextEditingController(text: user?['phone'] ?? '');
    final passwordController = TextEditingController();
    String role = (user?['role'] ?? 'MEMBER').toString();
    String status = (user?['status'] ?? 'ACTIVE').toString();
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Modifier utilisateur' : 'Nouvel utilisateur',
            style: const TextStyle(color: Color(0xFF1E1B4B), fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(firstNameController, 'Prenom'),
                  _field(lastNameController, 'Nom'),
                  _field(usernameController, 'Username'),
                  _field(emailController, 'Email', keyboardType: TextInputType.emailAddress),
                  _field(phoneController, 'Telephone', required: false),
                  _field(passwordController, isEdit ? 'Nouveau mot de passe (optionnel)' : 'Mot de passe', obscure: true, required: !isEdit),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DropdownButtonFormField<String>(
                      value: role,
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Color(0xFF1E1B4B)),
                      decoration: InputDecoration(
                        labelText: 'Role',
                        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ADMIN', child: Text('Administrateur')),
                        DropdownMenuItem(value: 'SUPERVISOR', child: Text('Encadreur / Superviseur')),
                        DropdownMenuItem(value: 'LEADER', child: Text('Chef de projet')),
                        DropdownMenuItem(value: 'MEMBER', child: Text('Etudiant / Membre')),
                      ],
                      onChanged: (value) => setDialogState(() => role = value ?? role),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DropdownButtonFormField<String>(
                      value: status,
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Color(0xFF1E1B4B)),
                      decoration: InputDecoration(
                        labelText: 'Statut',
                        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ACTIVE', child: Text('Actif')),
                        DropdownMenuItem(value: 'INACTIVE', child: Text('Inactif')),
                        DropdownMenuItem(value: 'BLOCKED', child: Text('Bloque')),
                      ],
                      onChanged: (value) => setDialogState(() => status = value ?? status),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context), 
              child: const Text('Annuler', style: TextStyle(color: Color(0xFF6B7280)))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
              onPressed: isSaving ? null : () async {
                if (firstNameController.text.trim().isEmpty || lastNameController.text.trim().isEmpty || emailController.text.trim().isEmpty) {
                  _showError('Prenom, nom et email sont obligatoires.');
                  return;
                }
                if (!isEdit && passwordController.text.trim().isEmpty) {
                  _showError('Mot de passe obligatoire pour creer un utilisateur.');
                  return;
                }

                setDialogState(() => isSaving = true);

                final body = {
                  'firstName': firstNameController.text.trim(),
                  'lastName': lastNameController.text.trim(),
                  'username': usernameController.text.trim().isEmpty ? emailController.text.trim().split('@').first : usernameController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'role': role,
                  'status': status,
                };
                if (passwordController.text.trim().isNotEmpty) body['password'] = passwordController.text.trim();

                try {
                  final uri = isEdit ? Uri.parse('$_baseUrl/${user['idUser']}') : Uri.parse(_baseUrl);
                  final response = isEdit
                      ? await http.put(uri, headers: await _headers(), body: jsonEncode(body)).timeout(const Duration(seconds: 30))
                      : await http.post(uri, headers: await _headers(), body: jsonEncode(body)).timeout(const Duration(seconds: 30));
                  
                  if (response.statusCode == 200 || response.statusCode == 201) {
                    Navigator.pop(context); // Close dialog on success
                    _showSuccess(isEdit ? 'Utilisateur modifie.' : 'Utilisateur cree.');
                    _fetchUsers();
                  } else {
                    _showError('Operation impossible (${response.statusCode}).');
                    setDialogState(() => isSaving = false);
                  }
                } catch (_) {
                  _showError('Erreur reseau pendant l\'operation.');
                  setDialogState(() => isSaving = false);
                }
              }, 
              child: isSaving 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Enregistrer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {bool obscure = false, bool required = true, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Color(0xFF1E1B4B)),
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4F46E5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4F46E5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer utilisateur'),
        content: Text('Supprimer ${_nameOf(user)} ? Cette action est definitive.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final response = await http.delete(Uri.parse('$_baseUrl/${user['idUser']}'), headers: await _headers()).timeout(const Duration(seconds: 30));
      if (response.statusCode == 204 || response.statusCode == 200) {
        _showSuccess('Utilisateur supprime.');
        _fetchUsers();
      } else {
        _showError('Suppression impossible (${response.statusCode}).');
      }
    } catch (_) {
      _showError('Erreur reseau pendant la suppression.');
    }
  }

  String _nameOf(Map<String, dynamic> user) {
    final name = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
    return name.isEmpty ? (user['username'] ?? 'Utilisateur').toString() : name;
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'ADMIN': return Colors.red;
      case 'SUPERVISOR': return Colors.indigo;
      case 'LEADER': return Colors.orange;
      default: return Colors.green;
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: const Color(0xFF10B981)));
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    final users = _filteredUsers;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs', style: TextStyle(color: Color(0xFF1E1B4B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1B4B),
        iconTheme: const IconThemeData(color: Color(0xFF1E1B4B)),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchUsers),
          IconButton(icon: const Icon(Icons.add), onPressed: () => _openUserDialog()),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _stat('Total', stats['total'].toString(), Icons.people, Colors.blue)),
                    const SizedBox(width: 10),
                    Expanded(child: _stat('Admins', stats['admins'].toString(), Icons.admin_panel_settings, Colors.red)),
                    const SizedBox(width: 10),
                    Expanded(child: _stat('Superviseurs', stats['supervisors'].toString(), Icons.supervisor_account, Colors.indigo)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _stat('Membres', stats['members'].toString(), Icons.person, Colors.green)),
                    const SizedBox(width: 10),
                    Expanded(child: _stat('Bloqués', stats['blocked'].toString(), Icons.block, Colors.orange)),
                    const SizedBox(width: 10),
                    Expanded(child: _stat('Actifs', (stats['total']! - stats['blocked']!).toString(), Icons.check_circle, Colors.teal)),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  style: const TextStyle(color: Color(0xFF1E1B4B)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                    hintText: 'Rechercher nom, email, role...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['ALL', 'ADMIN', 'SUPERVISOR', 'LEADER', 'MEMBER'].map((role) {
                      final selected = _roleFilter == role;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            role == 'ALL' ? 'Tous' : role,
                            style: TextStyle(
                              color: selected ? Colors.white : const Color(0xFF1E1B4B),
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: selected,
                          selectedColor: const Color(0xFF4F46E5), // Blue when selected
                          backgroundColor: Colors.white, // White when unselected
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: selected ? const Color(0xFF4F46E5) : const Color(0xFFD1D5DB),
                            ),
                          ),
                          onSelected: (_) => setState(() => _roleFilter = role),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                : users.isEmpty
                    ? const Center(child: Text('Aucun utilisateur trouve.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final role = (user['role'] ?? 'MEMBER').toString();
                          final status = (user['status'] ?? 'ACTIVE').toString();
                          return Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _roleColor(role).withOpacity(0.12),
                                child: Text(_nameOf(user).substring(0, 1).toUpperCase(), style: TextStyle(color: _roleColor(role), fontWeight: FontWeight.bold)),
                              ),
                              title: Text(_nameOf(user), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                              subtitle: Text('${user['email'] ?? ''}\n$role • $status', style: const TextStyle(color: Color(0xFF6B7280))),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') _openUserDialog(user: user);
                                  if (value == 'delete') _deleteUser(user);
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(value: 'edit', child: Text('Modifier')),
                                  PopupMenuItem(value: 'delete', child: Text('Supprimer', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}
