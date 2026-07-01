import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({Key? key}) : super(key: key);

  @override
  _FilesScreenState createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'Document', 'Image', 'Présentation'];

  bool _isLoading = true;
  List<Map<String, dynamic>> _files = [];

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/files' : 'https://groupprojet-production.up.railway.app/api/files';
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
            _files = data.map((json) {
              String name = json['originalFileName'] ?? json['name'] ?? 'Fichier inconnu';
              String type = json['type'] ?? '';
              IconData icon = Icons.insert_drive_file;
              Color color = const Color(0xFF10B981);
              
              if (name.toLowerCase().endsWith('.pdf') || type.contains('pdf')) {
                icon = Icons.picture_as_pdf;
                color = const Color(0xFFEF4444);
              } else if (name.toLowerCase().endsWith('.fig')) {
                icon = Icons.design_services;
                color = const Color(0xFFF97316);
              } else if (name.toLowerCase().endsWith('.pptx') || name.toLowerCase().endsWith('.ppt') || type.contains('presentation')) {
                icon = Icons.slideshow;
                color = const Color(0xFFF97316);
              } else if (type.contains('image') || name.toLowerCase().endsWith('.png') || name.toLowerCase().endsWith('.jpg')) {
                icon = Icons.image;
                color = const Color(0xFF3B82F6);
              }
              
              return {
                "name": name,
                "meta": "${json['size'] != null ? (json['size'] / 1024 / 1024).toStringAsFixed(1) : '0'} MB - ${json['uploadDate'] != null ? json['uploadDate'].toString().substring(0, 10) : 'Récemment'}",
                "icon": icon,
                "color": color,
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
            SnackBar(content: Text('Erreur: ${response.statusCode} - Impossible de charger les fichiers')),
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

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredFiles = _files;
    if (_selectedFilter != 'Tous') {
      if (_selectedFilter == 'Document') {
        filteredFiles = _files.where((f) => f['name'].toString().toLowerCase().contains('.pdf') || f['name'].toString().toLowerCase().contains('.doc') || f['name'].toString().toLowerCase().contains('.txt')).toList();
      } else if (_selectedFilter == 'Image') {
        filteredFiles = _files.where((f) => f['name'].toString().toLowerCase().contains('.png') || f['name'].toString().toLowerCase().contains('.jpg') || f['name'].toString().toLowerCase().contains('.jpeg')).toList();
      } else if (_selectedFilter == 'Présentation') {
        filteredFiles = _files.where((f) => f['name'].toString().toLowerCase().contains('.ppt') || f['name'].toString().toLowerCase().contains('.pptx') || f['name'].toString().toLowerCase().contains('.fig')).toList();
      }
    }
    
    if (_searchController.text.isNotEmpty) {
       filteredFiles = filteredFiles.where((f) => f['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
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
          'Fichiers',
          style: TextStyle(
            color: Color(0xFF1E1B4B),
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4F46E5), width: 1.5),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (value) {
                         setState(() {}); // Trigger rebuild to filter dynamically
                      },
                      decoration: InputDecoration(
                        hintText: 'Rechercher un fichier...',
                        hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF4B5563),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // List
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                : filteredFiles.isEmpty 
                  ? const Center(child: Text('Aucun fichier trouvé.', style: TextStyle(color: Color(0xFF6B7280))))
                  : ListView.separated(
              padding: const EdgeInsets.all(20.0),
              itemCount: filteredFiles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final file = filteredFiles[index];
                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ouverture de ${file['name']}...')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: file['color'],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            file['icon'],
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E1B4B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                file['meta'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                      ],
                    ),
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
            showModalBottomSheet(
              context: context,
              backgroundColor: const Color(0xFF242C3F), // Dark background matching image
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
                      ListTile(
                        leading: const Icon(Icons.camera_alt, color: Color(0xFF10B981)),
                        title: const Text('Prendre une photo', style: TextStyle(color: Colors.white, fontSize: 16)),
                        onTap: () {
                          Navigator.pop(context);
                          _simulateUpload('Photo ajoutée avec succès');
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Ajouter un fichier',
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
}
