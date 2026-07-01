import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/screens/tasks/create_task_screen.dart';
import 'package:mobile/screens/meetings/create_meeting_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  bool _isLoading = true;

  // Mock events structured by date string 'yyyy-MM-dd'
  Map<String, List<Map<String, dynamic>>> _eventsByDate = {};

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/events' : 'https://groupprojet-production.up.railway.app/api/events';
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
        Map<String, List<Map<String, dynamic>>> newEvents = {};
        
        for (var json in data) {
          if (json['startDatetime'] != null) {
            DateTime startTime = DateTime.parse(json['startDatetime']);
            String dateStr = DateFormat('yyyy-MM-dd').format(startTime);
            String timeStr = DateFormat('HH:mm').format(startTime);
            
            if (!newEvents.containsKey(dateStr)) {
              newEvents[dateStr] = [];
            }
            
            Color eventColor = const Color(0xFF4F46E5); // Default blue
            if (json['color'] != null) {
              try {
                // If backend provides a hex string like #F59E0B or F59E0B
                String hexColor = json['color'].toString().replaceAll('#', '');
                if (hexColor.length == 6) {
                  hexColor = 'FF$hexColor';
                }
                eventColor = Color(int.parse(hexColor, radix: 16));
              } catch (e) {
                // Ignore and use default
              }
            } else if (json['eventType'] == 'ACADEMIC') {
              eventColor = const Color(0xFF10B981);
            } else if (json['eventType'] == 'MEETING') {
              eventColor = const Color(0xFFF59E0B);
            }
            
            newEvents[dateStr]!.add({
              "time": timeStr,
              "title": json['title'] ?? 'Événement',
              "location": json['location'] ?? 'En ligne',
              "color": eventColor,
            });
          }
        }
        
        if (mounted) {
          setState(() {
            _eventsByDate = newEvents;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${response.statusCode} - Impossible de charger le calendrier')),
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

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  int get _daysInMonth {
    return DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
  }

  int get _firstWeekdayOfMonth {
    // 1 = Monday, 7 = Sunday
    return DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime date) {
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    return _eventsByDate[dateStr] ?? [];
  }

  String _getMonthName() {
    // Basic French month names
    const monthNames = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return "${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}";
  }

  String _getFormattedSelectedDate() {
    const monthNames = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    // Check if it's today
    DateTime now = DateTime.now();
    bool isToday = _selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day == now.day;
    String prefix = isToday ? "Aujourd'hui - " : "";
    return "$prefix${_selectedDate.day} ${monthNames[_selectedDate.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> currentEvents = _getEventsForDay(_selectedDate);

    // Calculate grid items
    int daysInMonth = _daysInMonth;
    int firstWeekday = _firstWeekdayOfMonth;
    int totalGridItems = daysInMonth + firstWeekday - 1;

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
          'Calendrier',
          style: TextStyle(
            color: Color(0xFF1E1B4B),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Color(0xFF1E1B4B)),
                  onPressed: _previousMonth,
                ),
                Text(
                  _getMonthName(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Color(0xFF1E1B4B)),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Days Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('L', style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold)),
                Text('M', style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold)),
                Text('M', style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold)),
                Text('J', style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold)),
                Text('V', style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold)),
                Text('S', style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold)),
                Text('D', style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalGridItems,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                // Empty slots before the first day of the month
                if (index < firstWeekday - 1) {
                  return const SizedBox.shrink();
                }
                
                int day = index - (firstWeekday - 1) + 1;
                DateTime thisDate = DateTime(_currentMonth.year, _currentMonth.month, day);
                
                bool isSelected = _selectedDate.year == thisDate.year && 
                                  _selectedDate.month == thisDate.month && 
                                  _selectedDate.day == thisDate.day;
                                  
                bool hasEvents = _getEventsForDay(thisDate).isNotEmpty;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = thisDate;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                      shape: BoxShape.circle,
                      border: hasEvents && !isSelected ? Border.all(color: const Color(0xFFE5E7EB), width: 1.5) : null,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF1E1B4B),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (hasEvents && !isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4F46E5),
                              shape: BoxShape.circle,
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            
            // Today's events header
            Text(
              _getFormattedSelectedDate(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 16),
            
            // Events list
            _isLoading 
              ? const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5))))
              : currentEvents.isEmpty 
              ? const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      "Aucun événement pour cette date.",
                      style: TextStyle(color: Color(0xFF9CA3AF), fontStyle: FontStyle.italic),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentEvents.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final event = currentEvents[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: event['color'], width: 4),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 60,
                            child: Text(
                              event['time'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E1B4B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  event['location'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Color(0xFF9CA3AF), size: 18),
                        ],
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'calendarFAB',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ajouter un élément',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle_outline, color: Color(0xFF8B5CF6)),
                    ),
                    title: const Text('Nouvelle tâche'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTaskScreen())).then((_) => _fetchEvents());
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.groups, color: Color(0xFFF59E0B)),
                    ),
                    title: const Text('Planifier une réunion'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateMeetingScreen())).then((_) => _fetchEvents());
                    },
                  ),
                ],
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF4F46E5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
