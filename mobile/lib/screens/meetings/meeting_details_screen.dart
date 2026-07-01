import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> meeting;

  const MeetingDetailsScreen({Key? key, required this.meeting}) : super(key: key);

  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService().getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<void> _joinMeeting(BuildContext context) async {
    final link = meeting['meetingLink'] ?? meeting['location'];
    if (link == null || !link.toString().startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lien de reunion indisponible.')));
      return;
    }

    final url = Uri.parse(link.toString());
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d ouvrir le lien.')));
    }
  }

  Future<void> _deleteMeeting(BuildContext context) async {
    final id = meeting['id'];
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la reunion'),
        content: Text('Voulez-vous vraiment supprimer "${meeting['title'] ?? 'cette reunion'}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    final String url = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/meetings/$id' : 'https://groupprojet-production.up.railway.app/api/meetings/$id';
    try {
      final response = await http.delete(Uri.parse(url), headers: await _authHeaders()).timeout(const Duration(seconds: 30));
      if (response.statusCode == 204 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reunion supprimee avec succes'), backgroundColor: Color(0xFF10B981)));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur suppression: ${response.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur reseau pendant la suppression.')));
    }
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
          'Détail de la réunion',
          style: TextStyle(
            color: Color(0xFF1E1B4B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _deleteMeeting(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: (meeting['color'] as Color?)?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    meeting['icon'] as IconData? ?? Icons.groups,
                    color: meeting['color'] as Color? ?? Colors.blue,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meeting['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1B4B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: meeting['status'] == 'À venir' ? const Color(0xFFEEF2FF) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          meeting['status'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: meeting['status'] == 'À venir' ? const Color(0xFF4F46E5) : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            _buildDetailRow(Icons.calendar_today, 'Date et Heure', meeting['date'] ?? 'Non défini'),
            const SizedBox(height: 24),
            
            _buildDetailRow(Icons.location_on_outlined, 'Lieu / Lien', meeting['location'] ?? 'En ligne'),
            const SizedBox(height: 24),
            
            _buildDetailRow(Icons.timer_outlined, 'Durée', '${meeting['duration'] ?? 60} minutes'),
            const SizedBox(height: 32),

            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              meeting['description'] ?? 'Aucune description fournie pour cette réunion.',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF4B5563),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: meeting['status'] == 'À venir'
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  _joinMeeting(context);
                  return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rejoindre la réunion (Simulation)')),
                  );
                },
                icon: const Icon(Icons.video_camera_front, color: Colors.white),
                label: const Text(
                  'Rejoindre la réunion',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF6B7280), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
            ],
          ),
        ),
      ],
    );
  }
}
