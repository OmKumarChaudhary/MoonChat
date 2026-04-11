import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  int _userCount = 0;
  int _adminCount = 0;
  int _disabledCount = 0;
  int _newsletterCount = 0;
  int _pendingReports = 0;
  DateTime? _privacyLastUpdate;
  DateTime? _termsLastUpdate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('users').get(),
        FirebaseFirestore.instance.collection('newsletter_history').get(),
        FirebaseFirestore.instance
            .collection('reports')
            .where('status', isEqualTo: 'pending')
            .get(),
      ]);

      final usersSnap = results[0];
      final newsletterSnap = results[1];
      final reportsSnap = results[2];

      int admins = 0;
      int disabled = 0;
      for (final doc in usersSnap.docs) {
        final data = doc.data();
        if (data['isAdmin'] == true) admins++;
        if (data['disabled'] == true) disabled++;
      }

      setState(() {
        _userCount = usersSnap.docs.length;
        _adminCount = admins;
        _disabledCount = disabled;
        _newsletterCount = newsletterSnap.docs.length;
        _pendingReports = reportsSnap.docs.length;
      });

      // Fetch Legal stats separately
      final privacyDoc = await FirebaseFirestore.instance.collection('app_settings').doc('privacy_policy').get();
      final termsDoc = await FirebaseFirestore.instance.collection('app_settings').doc('terms_of_service').get();

      if (mounted) {
        setState(() {
          if (privacyDoc.exists) _privacyLastUpdate = (privacyDoc.data()?['updatedAt'] as Timestamp?)?.toDate();
          if (termsDoc.exists) _termsLastUpdate = (termsDoc.data()?['updatedAt'] as Timestamp?)?.toDate();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminEmail =
        FirebaseAuth.instance.currentUser?.email ?? 'Admin';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD32F2F), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back,',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  adminEmail,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'MoonChat Admin Dashboard',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('Quick Stats',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),

          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.red))
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard('Total Users', '$_userCount', Icons.people,
                    Colors.blue),
                _buildStatCard('Admins', '$_adminCount', Icons.admin_panel_settings,
                    Colors.red),
                _buildStatCard('Disabled Users', '$_disabledCount',
                    Icons.block, Colors.orange),
                _buildStatCard('Newsletters Sent', '$_newsletterCount',
                    Icons.mail, Colors.green),
                _buildStatCard(
                  'Pending Reports',
                  '$_pendingReports',
                  Icons.flag_rounded,
                  _pendingReports > 0 ? Colors.red : Colors.white38,
                ),
                _buildStatCard(
                  'Legal Docs Status',
                  _privacyLastUpdate != null && _termsLastUpdate != null ? 'Updated' : 'Pending',
                  Icons.gavel_rounded,
                  Colors.purple,
                ),
              ],
            ),

          const SizedBox(height: 28),
          const Text('Recent Users',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.red));
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Text('No users yet.',
                    style: TextStyle(color: Colors.white38));
              }
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name =
                      data['fullName'] ?? data['username'] ?? 'Unknown';
                  final email = data['email'] ?? '';
                  final photo = data['photoUrl'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D1D2C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white12,
                          backgroundImage:
                              photo.isNotEmpty ? NetworkImage(photo) : null,
                          child: photo.isEmpty
                              ? Text(
                                  name.isNotEmpty
                                      ? name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                              Text(email,
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (data['isAdmin'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Admin',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 11)),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D2C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              Text(title,
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}
