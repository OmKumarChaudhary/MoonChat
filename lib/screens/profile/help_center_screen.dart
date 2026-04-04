import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

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
          'Help Center',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildFaqItem('How do I reset my password?', 'You can reset your password from the Account Settings screen by clicking "Change Password" and following the instructions sent to your email.'),
          const SizedBox(height: 12),
          _buildFaqItem('How do I change my profile picture?', 'Go to your Profile tab and tap the edit icon next to your avatar to choose a new picture from your gallery.'),
          const SizedBox(height: 12),
          _buildFaqItem('Can I delete a message?', 'Currently, messages are permanent once sent. We are working on adding a delete feature in future updates.'),
          const SizedBox(height: 12),
          _buildFaqItem('How do I report a user?', 'You can go to the user\'s profile and select "Report" or use the "Report a Problem" section in the settings menu.'),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF222232),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent, colorScheme: const ColorScheme.dark(primary: Color(0xFF7041EE))),
        child: ExpansionTile(
          title: Text(question, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          iconColor: const Color(0xFF7041EE),
          collapsedIconColor: Colors.grey,
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: [
            Text(answer, style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
