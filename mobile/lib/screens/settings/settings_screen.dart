import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/locale_provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/screens/notifications/notifications_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock data mirroring the user_settings table
  bool _notifEmail = true;
  bool _notifPush = true;
  bool _notifTaskAssigned = true;
  bool _notifTaskDue = true;
  bool _notifMeeting = true;
  bool _notifSubmission = true;
  
  String _theme = 'SYSTEM'; // DARK, LIGHT, SYSTEM
  String _language = 'Français';
  String _taskView = 'KANBAN'; // KANBAN, LIST, CALENDAR
  
  String _profileVisibility = 'MEMBERS'; // PUBLIC, MEMBERS, PRIVATE
  bool _showOnlineStatus = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1B4B)),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          AppLocalizations.of(context)?.settings ?? 'Paramètres',
          style: const TextStyle(
            color: Color(0xFF1E1B4B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Interface & Affichage'),
            _buildCardOrganization(
              children: [
                _buildDropdownTile(
                  title: 'Thème',
                  subtitle: 'Mode sombre, clair ou système',
                  icon: Icons.palette_outlined,
                  iconColor: const Color(0xFF8B5CF6),
                  currentValue: _theme,
                  options: ['LIGHT', 'DARK', 'SYSTEM'],
                  onChanged: (val) => setState(() => _theme = val!),
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFF3F4F6)),
                _buildDropdownTile(
                  title: AppLocalizations.of(context)?.language ?? 'Langue',
                  subtitle: 'Langue de l\'application',
                  icon: Icons.language_outlined,
                  iconColor: const Color(0xFF3B82F6),
                  currentValue: _language,
                  options: ['Français', 'English', 'Malagasy'],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _language = val);
                      String code = 'fr';
                      if (val == 'English') code = 'en';
                      if (val == 'Malagasy') code = 'mg';
                      Provider.of<LocaleProvider>(context, listen: false).setLocale(Locale(code));
                    }
                  },
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFF3F4F6)),
                _buildDropdownTile(
                  title: 'Vue des tâches',
                  subtitle: 'Affichage par défaut',
                  icon: Icons.view_kanban_outlined,
                  iconColor: const Color(0xFF10B981),
                  currentValue: _taskView,
                  options: ['KANBAN', 'LIST', 'CALENDAR'],
                  onChanged: (val) => setState(() => _taskView = val!),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Notifications'),
            _buildCardOrganization(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_active_outlined, color: Color(0xFF4F46E5), size: 22),
                  ),
                  title: const Text(
                    'Mes Notifications',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  subtitle: const Text(
                    'Voir toutes les notifications',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                    );
                  },
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFF3F4F6)),
                _buildSwitchTile(
                  title: 'Notifications Push',
                  subtitle: 'Alertes sur cet appareil',
                  icon: Icons.phone_android_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  value: _notifPush,
                  onChanged: (val) => setState(() => _notifPush = val),
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFF3F4F6)),
                _buildSwitchTile(
                  title: 'Notifications par Email',
                  subtitle: 'Résumés et alertes par mail',
                  icon: Icons.email_outlined,
                  iconColor: const Color(0xFFEF4444),
                  value: _notifEmail,
                  onChanged: (val) => setState(() => _notifEmail = val),
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFF3F4F6)),
                _buildSwitchTile(
                  title: 'Tâches assignées',
                  subtitle: 'Alerte lors d\'une assignation',
                  icon: Icons.assignment_ind_outlined,
                  iconColor: const Color(0xFF4F46E5),
                  value: _notifTaskAssigned,
                  onChanged: (val) => setState(() => _notifTaskAssigned = val),
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFF3F4F6)),
                _buildSwitchTile(
                  title: 'Échéances proches',
                  subtitle: 'Rappels pour les jalons',
                  icon: Icons.timer_outlined,
                  iconColor: const Color(0xFFF43F5E),
                  value: _notifTaskDue,
                  onChanged: (val) => setState(() => _notifTaskDue = val),
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFF3F4F6)),
                _buildSwitchTile(
                  title: 'Réunions',
                  subtitle: 'Rappels avant une réunion',
                  icon: Icons.groups_outlined,
                  iconColor: const Color(0xFF0EA5E9),
                  value: _notifMeeting,
                  onChanged: (val) => setState(() => _notifMeeting = val),
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFF3F4F6)),
                _buildSwitchTile(
                  title: 'Soumissions & Évaluations',
                  subtitle: 'Alerte de nouvelles notes',
                  icon: Icons.school_outlined,
                  iconColor: const Color(0xFF8B5CF6),
                  value: _notifSubmission,
                  onChanged: (val) => setState(() => _notifSubmission = val),
                ),
              ],
            ),
            const SizedBox(height: 32),

            _buildSectionTitle('Confidentialité & Sécurité'),
            _buildCardOrganization(
              children: [
                _buildDropdownTile(
                  title: 'Visibilité du profil',
                  subtitle: 'Qui peut voir vos informations',
                  icon: Icons.visibility_outlined,
                  iconColor: const Color(0xFF6366F1),
                  currentValue: _profileVisibility,
                  options: ['PUBLIC', 'MEMBERS', 'PRIVATE'],
                  onChanged: (val) => setState(() => _profileVisibility = val!),
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFF3F4F6)),
                _buildSwitchTile(
                  title: 'Statut en ligne',
                  subtitle: 'Afficher quand vous êtes actif',
                  icon: Icons.wifi_tethering,
                  iconColor: const Color(0xFF10B981),
                  value: _showOnlineStatus,
                  onChanged: (val) => setState(() => _showOnlineStatus = val),
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Paramètres sauvegardés avec succès !'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF4F46E5).withOpacity(0.4),
                ),
                child: const Text(
                  'Enregistrer les modifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
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

  Widget _buildCardOrganization({required List<Widget> children}) {
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

  Widget _buildSwitchTile({required String title, required String subtitle, required IconData icon, required Color iconColor, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1B4B),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
        value: value,
        activeColor: Colors.white,
        activeTrackColor: const Color(0xFF4F46E5),
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: const Color(0xFFE5E7EB),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile({required String title, required String subtitle, required IconData icon, required Color iconColor, required String currentValue, required List<String> options, required ValueChanged<String?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1B4B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentValue,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F46E5),
                ),
                items: options.map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
