import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
// Note: imports for screens are omitted for brevity, keeping existing routing logic 
import 'package:mobile/screens/admin/users_screen.dart';
import 'package:mobile/screens/analytics/analytics_screen.dart';
import 'package:mobile/screens/announcements/announcements_screen.dart';
import 'package:mobile/screens/calendar/calendar_screen.dart';
import 'package:mobile/screens/dashboard/admin_dashboard_screen.dart';
import 'package:mobile/screens/dashboard/dashboard_screen.dart';
import 'package:mobile/screens/dashboard/pm_dashboard_screen.dart';
import 'package:mobile/screens/dashboard/supervisor_dashboard_screen.dart';
import 'package:mobile/screens/files/files_screen.dart';
import 'package:mobile/screens/grades/notes_grades_screen.dart';
import 'package:mobile/screens/meetings/meetings_screen.dart';
import 'package:mobile/screens/milestones/milestones_screen.dart';
import 'package:mobile/screens/projects/project_team_screen.dart';
import 'package:mobile/screens/projects/projects_screen.dart';
import 'package:mobile/screens/settings/settings_screen.dart';
import 'package:mobile/screens/submissions/submissions_screen.dart';
import 'package:mobile/screens/tasks/tasks_screen.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({Key? key, required this.currentRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Current role logic mapping to the 4 strict roles
    final role = (AuthService().currentUser?.role ?? 'MEMBRE').toUpperCase();
    
    final isAdminOrg = role == 'ADMIN';
    final isChefProjet = role == 'CHEF_PROJET';
    final isEncadreur = role == 'ENCADREUR';
    final isMembre = !isAdminOrg && !isChefProjet && !isEncadreur;

    List<_DrawerItem> items = [];

    // --- ADMIN ORGANISATION MENU ---
    if (isAdminOrg) {
      items = [
        _DrawerItem('Dashboard', Icons.dashboard, '/dashboard', const AdminDashboardScreen()),
        _DrawerItem('Utilisateurs', Icons.people, '/admin/users', const UsersScreen()),
        _DrawerItem('Invitations', Icons.mail, '/admin/invitations', const UsersScreen()), // placeholder
        _DrawerItem('Tous les projets', Icons.folder, '/projects', const ProjectsScreen()),
        _DrawerItem('Encadreurs', Icons.school, '/admin/encadreurs', const UsersScreen()), // placeholder
        _DrawerItem('Annonces', Icons.announcement, '/announcements', const AnnouncementsScreen()),
        _DrawerItem('Rapports', Icons.analytics, '/analytics', const AnalyticsScreen()),
        _DrawerItem('Parametres', Icons.settings, '/settings', const SettingsScreen()),
      ];
    }
    // --- CHEF DE PROJET MENU ---
    else if (isChefProjet) {
      items = [
        _DrawerItem('Dashboard', Icons.dashboard, '/dashboard', const PmDashboardScreen()),
        _DrawerItem('Mon Projet', Icons.folder_special, '/projects', const ProjectsScreen()),
        _DrawerItem('Membres', Icons.group, '/team', const ProjectTeamScreen()),
        _DrawerItem('Taches', Icons.check_circle, '/tasks', const TasksScreen()),
        _DrawerItem('Jalons', Icons.flag, '/milestones', const MilestonesScreen()),
        _DrawerItem('Documents', Icons.insert_drive_file, '/files', const FilesScreen()),
        _DrawerItem('Soumissions', Icons.upload_file, '/submissions', const SubmissionsScreen()),
        _DrawerItem('Calendrier', Icons.calendar_today, '/calendar', const CalendarScreen()),
        _DrawerItem('Reunions', Icons.video_call, '/meetings', const MeetingsScreen()),
        _DrawerItem('Organisation', Icons.apartment, '/organization', const ProjectsScreen()),
        _DrawerItem('Rapports', Icons.analytics, '/analytics', const AnalyticsScreen()),
      ];
    }
    // --- ENCADREUR MENU ---
    else if (isEncadreur) {
      items = [
        _DrawerItem('Dashboard', Icons.dashboard, '/dashboard', const SupervisorDashboardScreen()),
        _DrawerItem('Projets encadres', Icons.folder, '/projects', const ProjectsScreen()),
        _DrawerItem('Etudiants', Icons.school, '/team', const ProjectTeamScreen()),
        _DrawerItem('Soumissions', Icons.file_download, '/submissions', const SubmissionsScreen()),
        _DrawerItem('Evaluations', Icons.star, '/grades', const NotesGradesScreen()),
        _DrawerItem('Commentaires', Icons.comment, '/comments', const NotesGradesScreen()), // placeholder
        _DrawerItem('Reunions', Icons.video_call, '/meetings', const MeetingsScreen()),
        _DrawerItem('Rapports', Icons.analytics, '/analytics', const AnalyticsScreen()),
      ];
    }
    // --- MEMBRE MENU ---
    else {
      items = [
        _DrawerItem('Accueil', Icons.home, '/dashboard', const DashboardScreen()),
        _DrawerItem('Mes taches', Icons.task, '/tasks', const TasksScreen()),
        _DrawerItem('Mes projets', Icons.folder, '/projects', const ProjectsScreen()),
        _DrawerItem('Documents', Icons.insert_drive_file, '/files', const FilesScreen()),
        _DrawerItem('Soumissions', Icons.upload_file, '/submissions', const SubmissionsScreen()),
        _DrawerItem('Calendrier', Icons.calendar_today, '/calendar', const CalendarScreen()),
        _DrawerItem('Reunions', Icons.video_call, '/meetings', const MeetingsScreen()),
        _DrawerItem('Organisation', Icons.apartment, '/organization', const ProjectsScreen()),
        _DrawerItem('Mon profil', Icons.person, '/settings', const SettingsScreen()),
      ];
    }

    return Drawer(
      child: Container(
        color: const Color(0xFF1E1B4B),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF4F46E5), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.apartment, color: Colors.white, size: 24), // building icon
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GroupProjet', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_roleLabel(role), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _buildMenuItem(context, items[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'ADMIN': return 'Admin Organisation';
      case 'ENCADREUR': return 'Encadreur';
      case 'CHEF_PROJET': return 'Chef de Projet';
      default: return 'Membre';
    }
  }

  Widget _buildMenuItem(BuildContext context, _DrawerItem item) {
    final isSelected = currentRoute == item.route;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(item.icon, color: Colors.white70, size: 20),
        title: Text(item.title, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
        onTap: () {
          Navigator.pop(context);
          if (!isSelected) Navigator.push(context, MaterialPageRoute(builder: (context) => item.screen));
        },
      ),
    );
  }
}

class _DrawerItem {
  final String title;
  final IconData icon;
  final String route;
  final Widget screen;

  const _DrawerItem(this.title, this.icon, this.route, this.screen);
}
