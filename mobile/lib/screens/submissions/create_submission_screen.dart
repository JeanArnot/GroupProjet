import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:file_picker/file_picker.dart';

class CreateSubmissionScreen extends StatefulWidget {
  final int? initialProjectId;
  final Map<String, dynamic>? submissionToEdit;

  const CreateSubmissionScreen({Key? key, this.initialProjectId, this.submissionToEdit}) : super(key: key);

  @override
  _CreateSubmissionScreenState createState() => _CreateSubmissionScreenState();
}

class _CreateSubmissionScreenState extends State<CreateSubmissionScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<Map<String, dynamic>> _projects = [];
  Map<String, dynamic>? _selectedProject;
  bool _isLoadingProjects = true;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    if (widget.submissionToEdit != null) {
      _titleController.text = widget.submissionToEdit!['title'] ?? '';
      _descriptionController.text = widget.submissionToEdit!['submissionNote'] ?? ''; // assuming we pass the note
    }
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    final String projectsUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/projects' : 'https://groupprojet-production.up.railway.app/api/projects';
    try {
      final token = await AuthService().getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.get(Uri.parse(projectsUrl), headers: headers).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _projects = data.map((e) => {
              "id": e['idProject'],
              "name": e['projectName'] ?? 'Projet',
            }).toList();
            if (_projects.isNotEmpty) {
              if (widget.initialProjectId != null) {
                try {
                  _selectedProject = _projects.firstWhere((p) => p['id'] == widget.initialProjectId);
                } catch (e) {
                  _selectedProject = _projects.first;
                }
              } else {
                _selectedProject = _projects.first;
              }
            }
            _isLoadingProjects = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingProjects = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProjects = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showFileUploadOptions() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fichier ajouté avec succès !')),
        );
      }
    }
  }

  void _simulateUpload(String fileName) {
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
        setState(() {
          _selectedFileName = fileName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fichier ajouté avec succès !')),
        );
      }
    });
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir le titre et sélectionner un projet')));
      return;
    }

    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/submissions' : 'https://groupprojet-production.up.railway.app/api/submissions';

    try {
      final token = await AuthService().getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final bodyData = jsonEncode({
        'submissionTitle': _titleController.text,
        'submissionNote': _descriptionController.text,
        'projectId': _selectedProject!['id'],
        if (_selectedFileName != null) 'fileUrls': [_selectedFileName],
      });

      final bool isEdit = widget.submissionToEdit != null;
      final String url = isEdit ? '$baseUrl/${widget.submissionToEdit!['id']}' : baseUrl;

      final response = isEdit 
        ? await http.put(Uri.parse(url), headers: headers, body: bodyData).timeout(const Duration(seconds: 30))
        : await http.post(Uri.parse(url), headers: headers, body: bodyData).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Soumission modifiée avec succès!' : 'Soumission ajoutée avec succès!'), backgroundColor: const Color(0xFF10B981)));
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${response.statusCode} - Impossible de soumettre')));
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
    final bool isEdit = widget.submissionToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Modifier la soumission' : 'Nouvelle soumission',
          style: const TextStyle(
            color: Color(0xFF1E1B4B),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final bool confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmer la suppression'),
                        content: const Text('Voulez-vous vraiment supprimer cette soumission ?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ) ??
                    false;

                if (confirm && mounted) {
                  try {
                    final token = await AuthService().getToken();
                    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/submissions' : 'https://groupprojet-production.up.railway.app/api/submissions';
                    final response = await http.delete(
                      Uri.parse('$baseUrl/${widget.submissionToEdit!['id']}'),
                      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
                    ).timeout(const Duration(seconds: 30));

                    if (response.statusCode == 200 || response.statusCode == 204) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Soumission supprimée avec succès!')));
                        Navigator.pop(context);
                      }
                    } else {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${response.statusCode}')));
                    }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur réseau')));
                  }
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Projet',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _isLoadingProjects 
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedProject,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.0)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    hint: const Text('Sélectionner un projet', style: TextStyle(color: Colors.black54)),
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4F46E5)),
                    items: _projects.map((item) => DropdownMenuItem(value: item, child: Text(item['name']))).toList(),
                    onChanged: (val) {
                      setState(() { _selectedProject = val; });
                    },
                  ),
            const SizedBox(height: 24),
            const Text(
              'Titre',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Titre de la soumission',
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Détails de la soumission...',
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // File upload area
            GestureDetector(
              onTap: () {
                _showFileUploadOptions();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD1D5DB), width: 1.0, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFileName != null ? Icons.check_circle_outline : Icons.cloud_upload_outlined,
                      size: 48,
                      color: _selectedFileName != null ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFileName ?? 'Cliquez ou glissez un fichier ici',
                      style: TextStyle(color: _selectedFileName != null ? Colors.black : const Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEdit ? 'Enregistrer les modifications' : 'Soumettre',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
