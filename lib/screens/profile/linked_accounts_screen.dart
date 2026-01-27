import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LinkedAccountsScreen extends StatelessWidget {
  const LinkedAccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final providerData = user?.providerData ?? [];
    
    // Check linked providers
    bool isGoogleLinked = providerData.any((info) => info.providerId == 'google.com');
    // Email is usually just 'password' provider or emailLink, but we can check if email exists.
    bool hasEmail = user?.email != null;

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
          'Linked Accounts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
             if (isGoogleLinked)
               _buildLinkedAccountItem(
                 icon: Icons.g_mobiledata, // Or use a proper Google Asset
                 title: "Google",
                 subtitle: user?.email ?? "Connected",
                 isConnected: true,
               ),
             if (!isGoogleLinked)
               _buildLinkedAccountItem(
                 icon: Icons.g_mobiledata,
                 title: "Google",
                 subtitle: "Not connected",
                 isConnected: false,
               ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkedAccountItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isConnected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222232),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (isConnected)
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
               decoration: BoxDecoration(
                 color: const Color(0xFF7041EE).withOpacity(0.2),
                 borderRadius: BorderRadius.circular(20),
                 border: Border.all(color: const Color(0xFF7041EE)),
               ),
               child: const Text(
                 "Connected",
                 style: TextStyle(
                   color: Color(0xFF7041EE),
                   fontSize: 12,
                   fontWeight: FontWeight.bold,
                 ),
               ),
             ),
        ],
      ),
    );
  }
}
