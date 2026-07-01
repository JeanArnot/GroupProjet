import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EvaluationDetailsScreen extends StatefulWidget {
  final int submissionId;
  const EvaluationDetailsScreen({Key? key, this.submissionId = 1}) : super(key: key);

  @override
  _EvaluationDetailsScreenState createState() => _EvaluationDetailsScreenState();
}

class _EvaluationDetailsScreenState extends State<EvaluationDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _evalData = {};

  @override
  void initState() {
    super.initState();
    _fetchEvaluationDetails();
  }

  Future<void> _fetchEvaluationDetails() async {
    final String baseUrl = kIsWeb 
        ? 'https://groupprojet-production.up.railway.app/api/submissions/${widget.submissionId}' 
        : 'https://groupprojet-production.up.railway.app/api/submissions/${widget.submissionId}';
        
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
            _evalData = data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${response.statusCode} - Impossible de charger les détails')),
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5))),
      );
    }

    final String project = _evalData['projectName'] ?? 'Projet Inconnu';
    final String title = _evalData['submissionNote'] ?? _evalData['title'] ?? 'Soumission';
    final String grade = _evalData['grade']?.toString() ?? '-';
    final String feedback = _evalData['feedback'] ?? 'Aucun feedback pour le moment.';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Détail d\'Évaluation',
          style: TextStyle(
            color: Color(0xFF1E1B4B),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1E1B4B)),
            onSelected: (value) async {
              if (value == 'download') {
                final Uri url = Uri.parse('https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf');
                if (!await launchUrl(url)) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Impossible d\'ouvrir le fichier')),
                    );
                  }
                }
              } else if (value == 'contact') {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'professeur@univ.com',
                  query: 'subject=Question sur la note de ${_evalData['projectName'] ?? 'projet'}',
                );
                if (!await launchUrl(emailLaunchUri)) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Impossible d\'ouvrir l\'application mail')),
                    );
                  }
                }
              } else if (value == 'share') {
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Partager'),
                      content: Text('Ma note pour le projet "${_evalData['projectName']}" est de ${_evalData['grade']?.toString() ?? '-'} / 20 !'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(Icons.download, color: Color(0xFF4B5563), size: 20),
                      SizedBox(width: 8),
                      Text('Télécharger le bulletin PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'contact',
                  child: Row(
                    children: [
                      Icon(Icons.mail_outline, color: Color(0xFF4B5563), size: 20),
                      SizedBox(width: 8),
                      Text('Contacter le professeur'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: Color(0xFF4B5563), size: 20),
                      SizedBox(width: 8),
                      Text('Partager les résultats'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF818CF8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.folder, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1B4B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Note finale
            const Text(
              'Note attribuée',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        grade,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E1B4B),
                        ),
                      ),
                      const Text(
                        ' / 20',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.star, color: Color(0xFFF59E0B), size: 48),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Feedback général
            const Text(
              'Feedback / Retour',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                feedback,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF4B5563),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
