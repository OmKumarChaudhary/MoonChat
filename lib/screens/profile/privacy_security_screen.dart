import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151522),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Privacy & Security',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildInfoItem(Icons.lock_outline, 'End-to-End Encryption', 'Your messages are secured with E2E encryption.'),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.visibility_off_outlined, 'Profile Visibility', 'Control who can see your profile information.'),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.block, 'Blocked Users', 'Manage the list of users you have blocked.'),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.fingerprint, 'Biometric Lock', 'Use fingerprint or Face ID to unlock the app.'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF222232),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF151522),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF7041EE), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: () {},
      ),
    );
  }
}
