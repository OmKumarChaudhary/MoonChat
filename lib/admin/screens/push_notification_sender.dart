import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PushNotificationSender extends StatefulWidget {
  const PushNotificationSender({super.key});

  @override
  State<PushNotificationSender> createState() => _PushNotificationSenderState();
}

class _PushNotificationSenderState extends State<PushNotificationSender> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _topicController = TextEditingController(text: 'all');
  
  bool _isSending = false;
  final String _baseUrl = 'http://127.0.0.1:5000/api/admin'; // Update this to backend URL in production

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/push'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': _titleController.text,
          'body': _bodyController.text,
          'topic': _topicController.text.isEmpty ? 'all' : _topicController.text,
        }),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification Dispatched Successfully!')),
          );
          _titleController.clear();
          _bodyController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.statusCode} - ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send Push Notification',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Broadcast a notification to all users or specific topics using Firebase Cloud Messaging.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1D1D2C),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_titleController, 'Notification Title', 'e.g., New Feature Update!', true),
                  const SizedBox(height: 20),
                  _buildTextField(_bodyController, 'Notification Body', 'Message contents...', true, maxLines: 4),
                  const SizedBox(height: 20),
                  _buildTextField(_topicController, 'Topic', 'all (default)', false),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendNotification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSending 
                         ? const CircularProgressIndicator(color: Colors.white)
                         : const Text('Send Notification', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, bool isRequired, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF151522),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: isRequired ? (value) {
            if (value == null || value.trim().isEmpty) return 'This field is required';
            return null;
          } : null,
        ),
      ],
    );
  }
}
