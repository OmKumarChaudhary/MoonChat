import 'package:flutter/material.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({Key? key}) : super(key: key);

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
          'Terms & Privacy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeading('Terms of Service'),
            const SizedBox(height: 12),
            _buildText(
              'By using MoonChat, you agree to these terms. Please read them carefully. You must follow any policies made available to you within the Services. Do not misuse our Services. For example, do not interfere with our Services or try to access them using a method other than the interface and the instructions that we provide.',
            ),
            const SizedBox(height: 24),
            _buildHeading('Privacy Policy'),
            const SizedBox(height: 12),
            _buildText(
              'Your privacy is important to us. We only collect the information you choose to give us, and we process it with your consent, or on another legal basis; we only require the minimum amount of personal information that is necessary to fulfill the purpose of your interaction with us; we don\'t sell it to third parties.',
            ),
            const SizedBox(height: 24),
            _buildHeading('Data Collection'),
            const SizedBox(height: 12),
            _buildText(
              'We may collect data such as your username, email, and messages in order to provide basic functionalities. This information is stored securely and processed in accordance with industry standards.',
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeading(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 15,
        height: 1.6,
      ),
    );
  }
}
