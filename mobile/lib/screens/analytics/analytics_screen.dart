import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTimeRange? _selectedDateRange;
  bool _isLoading = true;
  Map<String, dynamic> _analyticsData = {};

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    final String baseDashboardUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/dashboard/stats' : 'https://groupprojet-production.up.railway.app/api/dashboard/stats';
    final String baseGradesUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/grades' : 'https://groupprojet-production.up.railway.app/api/grades';
    
    try {
      final token = await AuthService().getToken();
      final headers = {
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final dashboardResponse = await http.get(Uri.parse(baseDashboardUrl), headers: headers).timeout(const Duration(seconds: 30));
      final gradesResponse = await http.get(Uri.parse(baseGradesUrl), headers: headers).timeout(const Duration(seconds: 30));

      if (dashboardResponse.statusCode == 200) {
        final dashboardData = jsonDecode(dashboardResponse.body);
        
        String averageGrade = "-";
        if (gradesResponse.statusCode == 200) {
          final gradesData = jsonDecode(gradesResponse.body);
          if (gradesData['finalGrade'] != null && gradesData['finalGrade'] != "-") {
            averageGrade = gradesData['finalGrade'].toString();
          }
        }

        if (mounted) {
          setState(() {
            _analyticsData = {
              "globalProgress": (dashboardData['progress'] as num?)?.toDouble() ?? 0.0,
              "completedTasks": dashboardData['tasksDone'] ?? 0,
              "totalTasks": dashboardData['totalTasks'] ?? 0,
              "pendingSubmissions": dashboardData['totalSubmissions'] ?? 0, // Using total submissions as a metric
              "averageGrade": averageGrade,
            };
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${dashboardResponse.statusCode} - Impossible de charger l\'analyse')),
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

  String _getFormattedDateRange() {
    if (_selectedDateRange == null) {
      // By default, let's show the current month
      DateTime now = DateTime.now();
      DateTime start = DateTime(now.year, now.month, 1);
      DateTime end = DateTime(now.year, now.month + 1, 0);
      final formatter = DateFormat('dd/MM/yyyy');
      return '${formatter.format(start)} - ${formatter.format(end)}';
    }
    final formatter = DateFormat('dd/MM/yyyy');
    return '${formatter.format(_selectedDateRange!.start)} - ${formatter.format(_selectedDateRange!.end)}';
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4F46E5), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      // In a real app, we would re-fetch data based on dates here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filtre de date appliqué')),
      );
    }
  }

  void _exportReport() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: Color(0xFF4F46E5)),
              SizedBox(width: 20),
              Text('Génération du rapport...'),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rapport exporté avec succès (PDF)')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Safely extract data
    final double globalProgress = _analyticsData['globalProgress'] ?? 0.0;
    final int completedTasks = _analyticsData['completedTasks'] ?? 0;
    final int totalTasks = _analyticsData['totalTasks'] ?? 0;
    final int pendingSubmissions = _analyticsData['pendingSubmissions'] ?? 0;
    final String averageGrade = _analyticsData['averageGrade']?.toString() ?? "-";
    
    final int progressPercent = (globalProgress * 100).toInt();
    final double taskCompletionRatio = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Row(
          children: [
            const Text(
              'Rapports & Analyses',
              style: TextStyle(
                color: Color(0xFF1E1B4B),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.dashboard_customize_outlined, color: Color(0xFF1E1B4B), size: 20),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF1E1B4B)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ouverture des paramètres du rapport...')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker & Export
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDateRange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Color(0xFF9CA3AF), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getFormattedDateRange(),
                              style: const TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.calendar_month, color: Color(0xFF9CA3AF), size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _exportReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5), // Purple-blue
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Exporter',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Top Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                _buildMetricCard(
                  title: 'Progression globale',
                  value: '$progressPercent%',
                  progress: globalProgress,
                  progressColor: const Color(0xFF10B981), // Green
                ),
                _buildMetricCard(
                  title: 'Tâches terminées',
                  value: '$completedTasks/$totalTasks',
                  progress: taskCompletionRatio,
                  progressColor: const Color(0xFF4F46E5), // Blue
                ),
                _buildMetricCard(
                  title: 'Soumissions totales',
                  value: pendingSubmissions.toString(),
                  progress: pendingSubmissions > 0 ? 1.0 : 0.0,
                  progressColor: const Color(0xFFEF4444), // Red
                ),
                _buildMetricCard(
                  title: 'Moyenne des notes',
                  value: averageGrade == "-" ? "-" : '$averageGrade / 20',
                  progress: averageGrade == "-" ? 0.0 : (double.tryParse(averageGrade) ?? 0.0) / 20.0,
                  progressColor: const Color(0xFFF59E0B), // Orange
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Charts Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bar Chart Placeholder
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Évolution de la progression',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBarChartColumn('Lun', 20),
                              _buildBarChartColumn('Mar', 40),
                              _buildBarChartColumn('Mer', 35),
                              _buildBarChartColumn('Jeu', 80),
                              _buildBarChartColumn('Ven', progressPercent.toDouble()),
                              _buildBarChartColumn('Sam', 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Donut Chart Placeholder
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Répartition des tâches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      // Donut
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF4F46E5), width: 16),
                        ),
                      ),
                      const SizedBox(width: 40),
                      // Legend
                      Expanded(
                        child: Column(
                          children: [
                            _buildLegendItem('Terminées', '$completedTasks', const Color(0xFF4F46E5)), // Blue
                            const SizedBox(height: 12),
                            _buildLegendItem('En cours', '${totalTasks - completedTasks}', const Color(0xFFF59E0B)), // Orange
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({required String title, required String value, required double progress, required Color progressColor}) {
    // Ensure progress is within 0.0 to 1.0 bounds
    double safeProgress = progress;
    if (safeProgress.isNaN || safeProgress.isInfinite) safeProgress = 0.0;
    if (safeProgress > 1.0) safeProgress = 1.0;
    if (safeProgress < 0.0) safeProgress = 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1B4B),
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: safeProgress,
              minHeight: 4,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartColumn(String label, double heightPercentage) {
    if (heightPercentage.isNaN || heightPercentage.isInfinite) heightPercentage = 0;
    if (heightPercentage > 100) heightPercentage = 100;
    if (heightPercentage < 0) heightPercentage = 0;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: 100 * (heightPercentage / 100),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
      ],
    );
  }
}
