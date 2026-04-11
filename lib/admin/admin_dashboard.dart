import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moonchat/admin/screens/admin_overview_screen.dart';
import 'package:moonchat/admin/screens/manage_users_screen.dart';
import 'package:moonchat/admin/screens/privacy_policy_manager.dart';
import 'package:moonchat/admin/screens/push_notification_sender.dart';
import 'package:moonchat/admin/screens/newsletter_screen.dart';
import 'package:moonchat/admin/screens/admin_reports_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isAdmin = false;
  bool _isLoading = true;

  static final List<Widget> _pages = [
    const AdminOverviewScreen(),
    const ManageUsersScreen(),
    const AdminReportsScreen(),
    const PrivacyPolicyManager(),
    const PushNotificationSender(),
    const NewsletterScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Overview'),
    _NavItem(icon: Icons.people_rounded, label: 'Users'),
    _NavItem(icon: Icons.flag_rounded, label: 'Reports'),
    _NavItem(icon: Icons.privacy_tip_rounded, label: 'Privacy Policy'),
    _NavItem(icon: Icons.notifications_rounded, label: 'Notifications'),
    _NavItem(icon: Icons.mail_rounded, label: 'Newsletter'),
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

      if (doc.exists && doc.data()?['isAdmin'] == true) {
        setState(() {
          _isAdmin = true;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Access Denied. You are not an admin.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF151522),
        body: Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    if (!_isAdmin) {
      return const Scaffold(
        backgroundColor: Color(0xFF151522),
        body: Center(
          child: Text('Access Denied', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final bool isWide = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      backgroundColor: const Color(0xFF151522),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'MoonChat Admin',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1D1D2C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            tooltip: 'Sign Out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      // Side nav for wide screens (web/tablet)
      body: isWide
          ? Row(
              children: [
                _buildSideNav(),
                const VerticalDivider(width: 1, color: Colors.white10),
                Expanded(child: _pages[_selectedIndex]),
              ],
            )
          : _pages[_selectedIndex],
      // Bottom nav for narrow screens (mobile)
      bottomNavigationBar: isWide
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              backgroundColor: const Color(0xFF1D1D2C),
              selectedItemColor: Colors.red,
              unselectedItemColor: Colors.white38,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              items: _navItems
                  .map((n) => BottomNavigationBarItem(
                        icon: Icon(n.icon),
                        label: n.label,
                      ))
                  .toList(),
            ),
    );
  }

  Widget _buildSideNav() {
    return Container(
      width: 220,
      color: const Color(0xFF1D1D2C),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ..._navItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final selected = _selectedIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? Colors.red.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: selected
                      ? Border.all(color: Colors.red.withOpacity(0.3))
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(item.icon,
                        color: selected ? Colors.red : Colors.white38,
                        size: 20),
                    const SizedBox(width: 12),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: selected ? Colors.red : Colors.white54,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          const Divider(color: Colors.white10),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              FirebaseAuth.instance.currentUser?.email ?? '',
              style: const TextStyle(color: Colors.white24, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
