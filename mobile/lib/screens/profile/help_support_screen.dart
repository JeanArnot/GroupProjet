import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Aide & Support',
          style: TextStyle(
            color: Color(0xFF1E1B4B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32.0),
              decoration: const BoxDecoration(
                color: Color(0xFF4F46E5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.support_agent, color: Colors.white, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Comment pouvons-nous vous aider ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Search Bar inside Header
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF4F46E5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher un article, un guide...',
                        hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF4F46E5)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FAQ Section
                  _buildSectionTitle('Foire Aux Questions (FAQ)'),
                  Container(
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
                      children: [
                        _buildFAQItem(
                          'Comment réinitialiser mon mot de passe ?',
                          'Allez dans "Profil > Sécurité", saisissez votre ancien mot de passe, puis le nouveau. Vous pouvez aussi utiliser l\'option "Mot de passe oublié" sur l\'écran de connexion.',
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB), indent: 16, endIndent: 16),
                        _buildFAQItem(
                          'Comment soumettre un projet ?',
                          'Rendez-vous dans les détails de votre projet, cliquez sur l\'onglet "Soumissions", puis sur le bouton "+ Nouvelle soumission". Vous pourrez y joindre vos fichiers.',
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB), indent: 16, endIndent: 16),
                        _buildFAQItem(
                          'Comment inviter des membres ?',
                          'Dans les détails de votre projet, allez dans l\'onglet "Équipe" et cliquez sur le bouton bleu "+ Ajouter membre" en bas de l\'écran.',
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB), indent: 16, endIndent: 16),
                        _buildFAQItem(
                          'Où trouver mes notes ?',
                          'Toutes vos notes se trouvent dans la section "Notes & Grades" accessible depuis le menu principal.',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Contact Section
                  _buildSectionTitle('Contactez-nous'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactCard(
                          context,
                          'Chat en direct',
                          'Réponse en < 5 min',
                          Icons.chat_bubble_outline,
                          const Color(0xFF10B981),
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ouverture du chat en direct...')));
                          }
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildContactCard(
                          context,
                          'Envoyer un Email',
                          'support@univ.edu',
                          Icons.email_outlined,
                          const Color(0xFFF59E0B),
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ouverture du client mail...')));
                          }
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Report a bug button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Formulaire de signalement de bug...')));
                      },
                      icon: const Icon(Icons.bug_report_outlined, color: Color(0xFFEF4444)),
                      label: const Text(
                        'Signaler un problème',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFFCA5A5), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
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

  Widget _buildFAQItem(String question, String answer) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        iconColor: const Color(0xFF4F46E5),
        collapsedIconColor: const Color(0xFF9CA3AF),
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1E1B4B),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
