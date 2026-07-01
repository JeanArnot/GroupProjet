import 'package:flutter/material.dart';
import 'package:mobile/models/user_model.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/screens/admin/users_screen.dart';
import 'package:mobile/screens/analytics/analytics_screen.dart';
import 'package:mobile/screens/calendar/calendar_screen.dart';
import 'package:mobile/screens/dashboard/admin_dashboard_screen.dart';
import 'package:mobile/screens/dashboard/dashboard_screen.dart';
import 'package:mobile/screens/dashboard/pm_dashboard_screen.dart';
import 'package:mobile/screens/dashboard/supervisor_dashboard_screen.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/screens/projects/project_team_screen.dart';
import 'package:mobile/screens/projects/projects_screen.dart';
import 'package:mobile/screens/submissions/submissions_screen.dart';
import 'package:mobile/screens/tasks/tasks_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  List<Widget> _screens = [];
  List<BottomNavigationBarItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _setupScreensBasedOnRole();
  }

  void _setupScreensBasedOnRole() {
    UserModel? user = AuthService().currentUser;
    final role = (user?.role ?? 'MEMBER').toUpperCase();

    if (role == 'ADMIN') {
      _screens = const [
        AdminDashboardScreen(),
        UsersScreen(),
        ProjectsScreen(),
        AnalyticsScreen(),
        ProfileScreen(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), activeIcon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Users'),
        BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: 'Projets'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Stats'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
      ];
    } else if (role == 'SUPERVISOR' || role == 'ENCADREUR') {
      _screens = const [
        SupervisorDashboardScreen(),
        ProjectsScreen(),
        SubmissionsScreen(),
        CalendarScreen(),
        ProfileScreen(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.supervisor_account_outlined), activeIcon: Icon(Icons.supervisor_account), label: 'Suivi'),
        BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: 'Projets'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Rendus'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Agenda'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
      ];
    } else if (role == 'LEADER' || role == 'CHEF_PROJET' || role == 'PM') {
      _screens = const [
        PmDashboardScreen(),
        TasksScreen(),
        ProjectsScreen(),
        ProjectTeamScreen(),
        ProfileScreen(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Pilotage'),
        BottomNavigationBarItem(icon: Icon(Icons.task_alt_outlined), activeIcon: Icon(Icons.task_alt), label: 'Taches'),
        BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: 'Projets'),
        BottomNavigationBarItem(icon: Icon(Icons.group_outlined), activeIcon: Icon(Icons.group), label: 'Equipe'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
      ];
    } else {
      _screens = const [
        DashboardScreen(),
        ProjectsScreen(),
        TasksScreen(),
        CalendarScreen(),
        ProfileScreen(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: 'Projets'),
        BottomNavigationBarItem(icon: Icon(Icons.task_alt_outlined), activeIcon: Icon(Icons.task_alt), label: 'Taches'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Agenda'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4F46E5),
          unselectedItemColor: const Color(0xFF9CA3AF),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          items: _navItems,
        ),
      ),
    );
  }
}
