import 'package:flutter/material.dart';
import 'package:mobile/screens/settings/settings_screen.dart';
import 'package:mobile/screens/projects/projects_screen.dart';
import 'package:mobile/screens/productivity/productivity_screen.dart';
import 'package:mobile/screens/notifications/notifications_screen.dart';
import 'package:mobile/screens/profile/personal_info_screen.dart';
import 'package:mobile/screens/profile/security_screen.dart';
import 'package:mobile/screens/profile/help_support_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/services/auth_service.dart';

import 'package:mobile/screens/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    String name = "Utilisateur Inconnu";
    String roleLabel = "Invité";

    if (user != null) {
      name = "${user.firstName ?? ''} ${user.lastName ?? ''}".trim();
      if (name.isEmpty) name = user.username ?? "Utilisateur";
      
      switch (user.role) {
        case 'STUDENT':
          roleLabel = "Étudiant";
          break;
        case 'ADMIN':
          roleLabel = "Administrateur";
          break;
        case 'ENCADREUR':
          roleLabel = "Encadreur / Professeur";
          break;
        case 'CHEF_PROJET':
          roleLabel = "Chef de Projet";
          break;
        default:
          roleLabel = user.role ?? "Utilisateur";
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: CustomScrollView(
        slivers: [
          // Premium Gradient Header
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF4F46E5),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF312E81)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 50, color: Color(0xFF4F46E5)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          roleLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Menu Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Général'),
                  _buildMenuCard([
                    _buildMenuItem(context, 'Informations personnelles', Icons.person_outline, const Color(0xFF3B82F6), const PersonalInfoScreen()),
                    _buildMenuItem(context, 'Mes projets', Icons.folder_outlined, const Color(0xFFF59E0B), const ProjectsScreen()),
                    _buildMenuItem(context, 'Productivité', Icons.show_chart, const Color(0xFF10B981), const ProductivityScreen()),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Préférences & Sécurité'),
                  _buildMenuCard([
                    _buildMenuItem(context, 'Notifications', Icons.notifications_outlined, const Color(0xFFEC4899), const NotificationsScreen()),
                    _buildMenuItem(context, AppLocalizations.of(context)?.settings ?? 'Paramètres', Icons.settings_outlined, const Color(0xFF6B7280), const SettingsScreen()),
                    _buildMenuItem(context, 'Sécurité', Icons.lock_outline, const Color(0xFFEF4444), const SecurityScreen()),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Assistance'),
                  _buildMenuCard([
                    _buildMenuItem(context, 'Aide & Support', Icons.help_outline, const Color(0xFF0EA5E9), const HelpSupportScreen()),
                  ]),
                  
                  const SizedBox(height: 32),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Déconnexion', style: TextStyle(color: Color(0xFF1E1B4B), fontWeight: FontWeight.bold)),
                            content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?', style: TextStyle(color: Color(0xFF374151))),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext, false),
                                child: const Text('Annuler', style: TextStyle(color: Color(0xFF6B7280))),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF4444), // Red for logout
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => Navigator.pop(dialogContext, true),
                                child: const Text('Se déconnecter', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirmed == true) {
                          await AuthService().logout();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                      label: const Text(
                        'Se déconnecter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFFCA5A5), width: 1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6B7280),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Color iconColor, Widget destination) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
            ],
          ),
        ),
      ),
    );
  }
}
