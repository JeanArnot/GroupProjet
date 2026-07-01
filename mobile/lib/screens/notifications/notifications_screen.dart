import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'Tout';
  final List<String> _filters = ['Tout', 'Non lues'];

  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/notifications' : 'https://groupprojet-production.up.railway.app/api/notifications';
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
            _notifications = data.map((json) {
              String type = json['type'] ?? 'INFO';
              bool isRead = json['isRead'] ?? false;
              
              IconData icon = Icons.info_outline;
              Color color = const Color(0xFF4F46E5); // Default blue

              if (type == 'URGENT' || type == 'IMPORTANT') {
                icon = Icons.warning_amber_rounded;
                color = const Color(0xFFEF4444);
              } else if (type == 'MEETING') {
                icon = Icons.event;
                color = const Color(0xFF10B981);
              } else if (type == 'TASK') {
                icon = Icons.adjust;
                color = const Color(0xFFF59E0B);
              } else if (type == 'MILESTONE') {
                icon = Icons.flag;
                color = const Color(0xFF8B5CF6);
              }

              String timeStr = 'Récemment';
              if (json['createdAt'] != null) {
                 try {
                   DateTime dt = DateTime.parse(json['createdAt']);
                   timeStr = DateFormat('dd/MM/yyyy HH:mm').format(dt);
                 } catch (e) {
                   timeStr = json['createdAt'].toString().substring(0, 10);
                 }
              }

              return {
                "id": json['idNotification'],
                "title": json['title'] ?? 'Nouvelle notification',
                "subtitle": json['message'] ?? '',
                "time": timeStr,
                "icon": icon,
                "color": color,
                "read": isRead,
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
            SnackBar(content: Text('Erreur: ${response.statusCode} - Impossible de charger les notifications')),
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

  Future<void> _markAllAsRead() async {
    // Ideally call a backend endpoint to mark all as read
    // For now we simulate it on the UI side
    setState(() {
      for (var n in _notifications) {
        n['read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Toutes les notifications ont été marquées comme lues')),
    );
  }

  Future<void> _markAsRead(int id, int index) async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/notifications/$id/read' : 'https://groupprojet-production.up.railway.app/api/notifications/$id/read';
    try {
      final token = await AuthService().getToken();
      final headers = {
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.put(Uri.parse(baseUrl), headers: headers).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        setState(() {
          _notifications[index]['read'] = true;
        });
      }
    } catch (e) {
       // Silent failure or show minimal warning
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredNotifications = _notifications;
    if (_selectedFilter == 'Non lues') {
      filteredNotifications = _notifications.where((n) => !(n['read'] as bool)).toList();
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
          'Notifications',
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
                      margin: const EdgeInsets.only(right: 12),
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
                : filteredNotifications.isEmpty 
                  ? const Center(child: Text('Aucune notification trouvée.', style: TextStyle(color: Color(0xFF6B7280))))
                  : ListView.separated(
              padding: const EdgeInsets.all(20.0),
              itemCount: filteredNotifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final notification = filteredNotifications[index];
                final bool isRead = notification['read'] as bool;
                
                return GestureDetector(
                  onTap: () {
                    if (!isRead && notification['id'] != null) {
                       _markAsRead(notification['id'], index);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.white : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: isRead ? const Color(0xFFF3F4F6) : const Color(0xFFC7D2FE)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: notification['color'], width: 2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                color: notification['color'],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(notification['icon'], size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E1B4B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification['subtitle'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              notification['time'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4F46E5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
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
        child: ElevatedButton(
          onPressed: _markAllAsRead,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Tout marquer comme lu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
