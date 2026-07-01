import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

class CreateMilestoneScreen extends StatefulWidget {
  final int? milestoneId;
  final int? projectId;
  final Map<String, dynamic>? milestoneToEdit;

  const CreateMilestoneScreen({Key? key, this.milestoneId, this.projectId, this.milestoneToEdit}) : super(key: key);

  @override
  _CreateMilestoneScreenState createState() => _CreateMilestoneScreenState();
}

class _CreateMilestoneScreenState extends State<CreateMilestoneScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.milestoneToEdit != null) {
      _nameController.text = widget.milestoneToEdit!['title'] ?? widget.milestoneToEdit!['milestoneName'] ?? '';
      _descController.text = widget.milestoneToEdit!['description'] ?? '';
      final date = widget.milestoneToEdit!['dueDate'] ?? widget.milestoneToEdit!['date'];
      if (date != null && date != 'Aucune date') {
        _dueDate = DateTime.tryParse(date.toString().substring(0, 10));
      }
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir le nom et la date')));
      return;
    }

    final bool isEdit = widget.milestoneId != null;
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/milestones' : 'https://groupprojet-production.up.railway.app/api/milestones';
    final String url = isEdit ? '$baseUrl/${widget.milestoneId}' : baseUrl;
    
    try {
      final token = await AuthService().getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = jsonEncode({
        'milestoneName': _nameController.text,
        'description': _descController.text,
        'dueDate': _dueDate!.toIso8601String().substring(0, 10),
        'projectId': widget.projectId ?? widget.milestoneToEdit?['projectId'] ?? 1,
        'status': widget.milestoneToEdit?['rawStatus'],
        'completionPercentage': widget.milestoneToEdit?['completionPercentage'],
      });

      final response = isEdit
          ? await http.put(Uri.parse(url), headers: headers, body: body).timeout(const Duration(seconds: 30))
          : await http.post(Uri.parse(url), headers: headers, body: body).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jalon créé avec succès!'), backgroundColor: Color(0xFF10B981)));
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${response.statusCode}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur réseau. Vérifiez votre connexion.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Nouveau Jalon', style: TextStyle(color: Color(0xFF1E1B4B), fontWeight: FontWeight.bold)),
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
                  const Text('Nom du jalon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 8),
                  _buildTextField(_nameController, 'Ex: Phase 5 - Lancement'),
                  const SizedBox(height: 24),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 8),
                  _buildTextField(_descController, 'Détails du jalon...', maxLines: 4),
                  const SizedBox(height: 24),
                  const Text('Date d\'échéance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => _dueDate = picked);
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
                            _dueDate == null ? 'Sélectionner une date' : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                            style: TextStyle(color: _dueDate == null ? Colors.black54 : Colors.black, fontSize: 16),
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
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: const Text('Créer le jalon', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
}
