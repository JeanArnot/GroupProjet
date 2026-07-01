import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

class CreateTaskScreen extends StatefulWidget {
  final Map<String, dynamic>? taskToEdit;
  final int? taskId;
  final int? initialProjectId;

  const CreateTaskScreen({Key? key, this.taskToEdit, this.taskId, this.initialProjectId}) : super(key: key);

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  Map<String, dynamic>? _selectedProject;
  Map<String, dynamic>? _selectedAssignee;
  String? _selectedPriority = 'Moyenne';
  String? _selectedStatus = 'À faire';
  DateTime? _deadline;

  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _assignees = [];
  final List<String> _priorities = ['Basse', 'Moyenne', 'Haute', 'Urgente'];
  final List<String> _statuses = ['À faire', 'En cours', 'Terminées'];

  @override
  void initState() {
    super.initState();
    _fetchFormData().then((_) {
      if (widget.taskToEdit != null) {
        _populateFieldsForEdit();
      }
    });
  }

  void _populateFieldsForEdit() {
    setState(() {
      _titleController.text = widget.taskToEdit!['title'] ?? '';
      _descController.text = widget.taskToEdit!['description'] ?? '';
      
      String priority = widget.taskToEdit!['priority'] ?? 'Moyenne';
      if (_priorities.contains(priority)) {
        _selectedPriority = priority;
      }
      
      String status = widget.taskToEdit!['status'] ?? 'À faire';
      if (_statuses.contains(status)) {
        _selectedStatus = status;
      }
      
      int? projId = widget.taskToEdit!['projectId'];
      if (projId != null) {
        try {
          _selectedProject = _projects.firstWhere((p) => p['id'] == projId);
        } catch (e) {}
      }

      int? assignedId = widget.taskToEdit!['assignedToId'];
      if (assignedId != null) {
        try {
          _selectedAssignee = _assignees.firstWhere((a) => a['id'] == assignedId);
        } catch (e) {}
      }

      String dateStr = widget.taskToEdit!['dueDate'] ?? '';
      if (dateStr != 'Non défini' && dateStr.isNotEmpty) {
        try {
          _deadline = DateTime.parse(dateStr);
        } catch (e) {}
      }
    });
  }

  Future<void> _fetchFormData() async {
    final String projectsUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/projects' : 'https://groupprojet-production.up.railway.app/api/projects';
    final String usersUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/users' : 'https://groupprojet-production.up.railway.app/api/users';

    try {
      final token = await AuthService().getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final pResponse = await http.get(Uri.parse(projectsUrl), headers: headers).timeout(const Duration(seconds: 30));
      final uResponse = await http.get(Uri.parse(usersUrl), headers: headers).timeout(const Duration(seconds: 30));

      if (pResponse.statusCode == 200 && uResponse.statusCode == 200) {
        final List<dynamic> pData = jsonDecode(pResponse.body);
        final List<dynamic> uData = jsonDecode(uResponse.body);

        if (mounted) {
          setState(() {
            _projects = pData.map((e) => {
              "id": e['idProject'],
              "name": e['projectName'] ?? e['name'] ?? e['title'] ?? 'Projet',
            }).toList();
            if (_projects.isNotEmpty && widget.taskToEdit == null) {
              if (widget.initialProjectId != null) {
                _selectedProject = _projects.firstWhere(
                  (p) => p['id'] == widget.initialProjectId,
                  orElse: () => _projects.first,
                );
              } else {
                _selectedProject = _projects.first;
              }
            }

            _assignees = uData.map((e) => {
              "id": e['idUser'],
              "name": "${e['firstName'] ?? ''} ${e['lastName'] ?? ''}".trim()
            }).where((e) => e["name"]!.isNotEmpty).toList();
            if (_assignees.isNotEmpty && widget.taskToEdit == null) _selectedAssignee = _assignees.first;
          });
        }
      }
    } catch (e) {
      // Handle silently
    }
  }

  Future<void> _submitTask() async {
    if (_titleController.text.isEmpty || _selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir les champs obligatoires.')));
      return;
    }

    final bool isEdit = widget.taskId != null;
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/tasks' : 'https://groupprojet-production.up.railway.app/api/tasks';
    final String url = isEdit ? '$baseUrl/${widget.taskId}' : baseUrl;

    try {
      final token = await AuthService().getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      // Mapping Priority to DB Enum Equivalent
      String prio = 'MEDIUM';
      if (_selectedPriority == 'Basse') prio = 'LOW';
      if (_selectedPriority == 'Haute') prio = 'HIGH';
      if (_selectedPriority == 'Urgente') prio = 'URGENT';

      String status = 'TODO';
      if (_selectedStatus == 'En cours') status = 'IN_PROGRESS';
      if (_selectedStatus == 'Terminées') status = 'COMPLETED';

      final bodyData = jsonEncode({
        "taskTitle": _titleController.text,
        "description": _descController.text,
        "projectId": _selectedProject!['id'],
        "assignedToId": _selectedAssignee?['id'],
        "priority": prio,
        "status": status,
        "deadline": _deadline?.toIso8601String()
      });

      final response = isEdit 
        ? await http.put(Uri.parse(url), headers: headers, body: bodyData).timeout(const Duration(seconds: 30))
        : await http.post(Uri.parse(url), headers: headers, body: bodyData).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEdit ? 'Tâche modifiée avec succès!' : 'Tâche ajoutée avec succès!'),
          backgroundColor: const Color(0xFF10B981),
        ));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${response.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur réseau.')));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.taskId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier la tâche' : 'Nouvelle tâche', style: const TextStyle(color: Color(0xFF1E1B4B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Titre de la tâche', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 8),
                  _buildTextField(_titleController, 'Ex: Conception UI/UX'),
                  const SizedBox(height: 24),
                  
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 8),
                  _buildTextField(_descController, 'Détails de la tâche...', maxLines: 4),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Projet associé', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 8),
                  _buildProjectDropdown(),
                  const SizedBox(height: 24),
                  
                  const Text('Assigné à', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 8),
                  _buildAssigneeDropdown(),
                  const SizedBox(height: 24),

                  const Text('Priorité', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 8),
                  _buildDropdown(_priorities, 'Priorité', _selectedPriority, (val) {
                    setState(() => _selectedPriority = val);
                  }),
                  const SizedBox(height: 24),
                  
                  if (isEdit) ...[
                    const Text('Statut', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                    const SizedBox(height: 8),
                    _buildDropdown(_statuses, 'Statut', _selectedStatus, (val) {
                      setState(() => _selectedStatus = val);
                    }),
                    const SizedBox(height: 24),
                  ],
                  
                  const Text('Date d\'échéance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF4F46E5), // header background color
                                onPrimary: Colors.white, // header text color
                                onSurface: Colors.black, // body text color
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF4F46E5), // button text color
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => _deadline = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4F46E5), width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _deadline == null ? 'Sélectionner une date' : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                            style: TextStyle(color: _deadline == null ? Colors.black54 : Colors.black, fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today, color: Color(0xFF4F46E5), size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: Text(isEdit ? 'Enregistrer les modifications' : 'Créer la tâche', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2.0)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String hint, String? value, ValueChanged<String?> onChanged) {
    if (!items.contains(value)) value = items.isNotEmpty ? items.first : null;
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2.0)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      hint: Text(hint, style: const TextStyle(color: Colors.black54)),
      style: const TextStyle(color: Colors.black, fontSize: 16),
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4F46E5)),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildProjectDropdown() {
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: _selectedProject,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2.0)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      hint: const Text('Sélectionner un projet', style: TextStyle(color: Colors.black54)),
      style: const TextStyle(color: Colors.black, fontSize: 16),
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4F46E5)),
      items: _projects.map((item) => DropdownMenuItem(value: item, child: Text(item['name']))).toList(),
      onChanged: (val) {
        setState(() { _selectedProject = val; });
      },
    );
  }

  Widget _buildAssigneeDropdown() {
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: _selectedAssignee,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2.0)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      hint: const Text('Sélectionner un membre', style: TextStyle(color: Colors.black54)),
      style: const TextStyle(color: Colors.black, fontSize: 16),
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4F46E5)),
      items: _assignees.map((item) => DropdownMenuItem(value: item, child: Text(item['name']))).toList(),
      onChanged: (val) {
        setState(() { _selectedAssignee = val; });
      },
    );
  }
}
