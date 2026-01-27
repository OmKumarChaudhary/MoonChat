import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        if (doc.exists) {
          if (mounted) {
            setState(() {
              userData = doc.data() as Map<String, dynamic>?;
              isLoading = false;
            });
          }
        } else {
           if (mounted) setState(() => isLoading = false);
        }
      } catch (e) {
        debugPrint("Error fetching user data: $e");
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  Future<void> _updateProfileImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 70);
      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        String base64String = base64Encode(imageBytes);
        
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'profileImage': base64String,
        });

        // Refresh data
        _fetchUserData();
      }
    } catch (e) {
      debugPrint("Error updating image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating image: $e')),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      if (await GoogleSignIn().isSignedIn()) {
        await GoogleSignIn().signOut();
      }
      await FirebaseAuth.instance.signOut();
      
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      debugPrint("Logout Error: $e");
      if (context.mounted) {
        // Even if error, try to navigate to login to avoid stuck user
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  ImageProvider _getAvatarImage() {
    if (userData != null && userData!['profileImage'] != null && userData!['profileImage'].isNotEmpty) {
      try {
        return MemoryImage(base64Decode(userData!['profileImage']));
      } catch (e) {
        return const AssetImage('images/icon.png');
      }
    }
    return const AssetImage('images/icon.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151522),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes back arrow
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Avatar Profile
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white10, width: 2),
                           color: const Color(0xFF222232),
                           image: DecorationImage(
                             image: _getAvatarImage(),
                             fit: BoxFit.cover,
                           ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _updateProfileImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF7041EE),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userData?['fullName'] ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Mulish',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData != null ? '@${userData!['username']}' : 'No username',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontFamily: 'Mulish',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Account Section
                  _buildSectionHeader('ACCOUNT'),
                  _buildSettingsItem(
                    icon: Icons.person_outline, 
                    title: 'Account Settings',
                    onTap: () async {
                      await Navigator.pushNamed(context, '/account_settings');
                      _fetchUserData(); // Refresh data on return
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.shield_outlined, 
                    title: 'Privacy & Security',
                    onTap: () {},
                  ),
                  _buildSettingsItem(
                    icon: Icons.link, 
                    title: 'Linked Accounts',
                    onTap: () => Navigator.pushNamed(context, '/linked_accounts'),
                  ),

                  const SizedBox(height: 24),
                  // Preferences Section
                  _buildSectionHeader('PREFERENCES'),
                  _buildSettingsItem(icon: Icons.notifications_outlined, title: 'Notifications', onTap: () {}),
                  _buildSettingsItem(icon: Icons.visibility_outlined, title: 'Appearance', trailingText: 'System', onTap: () {}),
                  _buildSettingsItem(icon: Icons.chat_bubble_outline, title: 'Chat Settings', onTap: () {}),

                  const SizedBox(height: 24),
                  // Support & Legal Section
                  _buildSectionHeader('SUPPORT & LEGAL'),
                  _buildSettingsItem(icon: Icons.help_outline, title: 'Help Center', onTap: () {}),
                  _buildSettingsItem(icon: Icons.flag_outlined, title: 'Report a Problem', onTap: () {}),
                  _buildSettingsItem(icon: Icons.privacy_tip_outlined, title: 'Terms & Privacy', onTap: () {}),

                  const SizedBox(height: 40),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => _logout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B2025), // Dark reddish hue
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Color(0xFFFF4848), // Bright red text
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          child: Icon(icon, color: const Color(0xFF7041EE), size: 20), // Purple icons in dark boxes
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  trailingText,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
