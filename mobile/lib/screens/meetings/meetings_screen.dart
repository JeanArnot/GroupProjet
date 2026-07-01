import 'package:flutter/material.dart';
import 'package:mobile/screens/meetings/create_meeting_screen.dart';
import 'package:mobile/screens/meetings/meeting_details_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({Key? key}) : super(key: key);

  @override
  _MeetingsScreenState createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  String _selectedFilter = 'À venir';
  final List<String> _filters = ['À venir', 'Passées'];

  bool _isLoading = true;
  List<Map<String, dynamic>> _meetings = [];

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
  }

  Future<void> _fetchMeetings() async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/meetings' : 'https://groupprojet-production.up.railway.app/api/meetings';
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
            _meetings = data.map((json) {
              String status = json['status'] == 'COMPLETED' || json['status'] == 'CANCELED' ? 'Passées' : 'À venir';
              
              String dateStr = 'Date inconnue';
              if (json['meetingDate'] != null) {
                // "2025-04-18T14:00:00" -> "2025-04-18, 14:00"
                dateStr = json['meetingDate'].toString().substring(0, 16).replaceFirst('T', ', ');
              }

              return {
                "id": json['idMeeting'],
                "projectId": json['projectId'],
                "title": json['title'] ?? 'Réunion sans titre',
                "date": dateStr,
                "meetingDate": json['meetingDate'],
                "location": json['location'] ?? 'En ligne',
                "meetingLink": json['meetingLink'],
                "status": status,
                "description": json['description'],
                "duration": json['durationMinutes'],
                "icon": json['type'] == 'TEAM' ? Icons.groups : Icons.adjust,
                "color": json['type'] == 'TEAM' ? const Color(0xFF8B5CF6) : const Color(0xFF4F46E5),
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
            SnackBar(content: Text('Erreur: ${response.statusCode} - Impossible de charger les réunions')),
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
    List<Map<String, dynamic>> filteredMeetings = _meetings;
    if (_selectedFilter == 'À venir') {
      filteredMeetings = _meetings.where((m) => m['status'] == 'À venir').toList();
    } else if (_selectedFilter == 'Passées') {
      filteredMeetings = _meetings.where((m) => m['status'] == 'Passées').toList();
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
          'Réunions',
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
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          
          // List
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                : filteredMeetings.isEmpty 
                  ? const Center(child: Text('Aucune réunion trouvée.', style: TextStyle(color: Color(0xFF6B7280))))
                  : ListView.separated(
              padding: const EdgeInsets.all(20.0),
              itemCount: filteredMeetings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final meeting = filteredMeetings[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeetingDetailsScreen(meeting: meeting),
                      ),
                    ).then((_) => _fetchMeetings());
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
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: meeting['color'].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            meeting['icon'],
                            color: meeting['color'],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meeting['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E1B4B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                meeting['date'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                meeting['location'],
                                style: const TextStyle(
                                  fontSize: 12,
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateMeetingScreen()),
            ).then((_) {
              setState(() {
                _isLoading = true;
              });
              _fetchMeetings();
            });
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Planifier une réunion',
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
