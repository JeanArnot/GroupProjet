import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Sécurité',
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Changer le mot de passe'),
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
                  _buildPasswordField('Ancien mot de passe', _obscureOld, (val) => setState(() => _obscureOld = val)),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  _buildPasswordField('Nouveau mot de passe', _obscureNew, (val) => setState(() => _obscureNew = val)),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  _buildPasswordField('Confirmer le mot de passe', _obscureConfirm, (val) => setState(() => _obscureConfirm = val)),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mot de passe mis à jour avec succès !'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Mettre à jour le mot de passe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            _buildSectionTitle('Authentification et Accès'),
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
                  SwitchListTile(
                    title: const Text('Authentification à 2 facteurs (2FA)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E1B4B))),
                    subtitle: const Text('Sécurisez votre compte avec un code SMS', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    value: _twoFactorEnabled,
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() => _twoFactorEnabled = val),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.phonelink_lock, color: Color(0xFF10B981), size: 20),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB), indent: 64),
                  SwitchListTile(
                    title: const Text('Connexion Biométrique', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E1B4B))),
                    subtitle: const Text('Face ID / Touch ID pour vous connecter', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    value: _biometricEnabled,
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFF4F46E5),
                    onChanged: (val) => setState(() => _biometricEnabled = val),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF4F46E5).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.fingerprint, color: Color(0xFF4F46E5), size: 20),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            _buildSectionTitle('Appareils connectés (Sessions)'),
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
                  _buildSessionItem(
                    'iPhone 13 Pro',
                    'Application Mobile • Actif maintenant',
                    'Antananarivo, MG',
                    Icons.phone_iphone,
                    isActive: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  _buildSessionItem(
                    'MacBook Air M1',
                    'Navigateur Chrome • Il y a 2 heures',
                    'Antananarivo, MG',
                    Icons.laptop_mac,
                    isActive: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Déconnexion de tous les autres appareils...')));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Se déconnecter de tous les appareils', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
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

  Widget _buildPasswordField(String label, bool isObscure, Function(bool) toggleObscure) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        obscureText: isObscure,
        style: const TextStyle(fontSize: 15, color: Color(0xFF1E1B4B)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          icon: const Icon(Icons.lock_outline, color: Color(0xFF4F46E5), size: 22),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2.0),
          ),
          suffixIcon: IconButton(
            icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF4F46E5), size: 20),
            onPressed: () => toggleObscure(!isObscure),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionItem(String device, String details, String location, IconData icon, {bool isActive = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEEF2FF) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF6B7280), size: 24),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(device, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B), fontSize: 15)),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(12)),
              child: const Text('Cet appareil', style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(details, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 2),
          Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}
