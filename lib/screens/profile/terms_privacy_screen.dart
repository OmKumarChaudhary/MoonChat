import 'package:flutter/material.dart';
import 'package:moonchat/screens/profile/legal_document_screen.dart';

/// Hub screen — lets user choose Privacy Policy or Terms of Service.
/// Both documents are fetched live from Firestore (managed by admin CRUD panel).
class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151522),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1D2C),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        ),
        title: const Text(
          'Terms & Privacy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D1D2C), Color(0xFF252540)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.shield_outlined, color: Color(0xFF7041EE), size: 32),
                SizedBox(height: 12),
                Text(
                  'Your Rights & Our Policies',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'Read our legal documents to understand how we handle your data and what you agree to when using MoonChat.',
                  style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.6),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'LEGAL DOCUMENTS',
            style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4),
          ),
          const SizedBox(height: 12),

          // Privacy Policy card
          _buildDocCard(
            context,
            icon: Icons.privacy_tip_rounded,
            iconColor: const Color(0xFF7041EE),
            title: 'Privacy Policy',
            subtitle: 'How we collect, use, and protect your personal data.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalDocumentScreen(
                  docKey: 'privacy_policy',
                  title: 'Privacy Policy',
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Terms of Service card
          _buildDocCard(
            context,
            icon: Icons.gavel_rounded,
            iconColor: const Color(0xFF7041EE),
            title: 'Terms of Service',
            subtitle: 'Rules and guidelines for using MoonChat responsibly.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalDocumentScreen(
                  docKey: 'terms_of_service',
                  title: 'Terms of Service',
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Contact note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1D1D2C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: const [
                Icon(Icons.mail_outline, color: Color(0xFF7041EE), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Questions about our policies? Contact us at support@moonchat.app',
                    style: TextStyle(
                        color: Colors.white54, fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D2C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }
}
