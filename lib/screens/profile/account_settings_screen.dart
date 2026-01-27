import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  bool isSaving = false;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  String? _selectedGender;
  String? _originalUsername;

  // Username validation
  Timer? _debounce;
  String? _usernameError;
  bool _isCheckingUsername = false;
  bool _isUsernameAvailable = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _dobController = TextEditingController();
    
    _usernameController.addListener(_onUsernameChanged);
    _fetchUserData();
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onUsernameChanged);
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (_usernameController.text.trim() == _originalUsername) {
      setState(() {
        _usernameError = null;
        _isUsernameAvailable = true;
      });
      return;
    }

    setState(() {
       _usernameError = null;
       _isCheckingUsername = true;
    });

    if (_usernameController.text.trim().isEmpty) {
        setState(() => _isCheckingUsername = false);
        return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _checkUsernameAvailability(_usernameController.text.trim());
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.length < 3) {
      if (mounted) setState(() {
         _isCheckingUsername = false;
         _usernameError = "Too short";
         _isUsernameAvailable = false;
      });
      return;
    }

    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
          if (result.docs.isNotEmpty) {
             _usernameError = "Unavailable";
             _isUsernameAvailable = false;
          } else {
             _usernameError = null;
             _isUsernameAvailable = true;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isCheckingUsername = false);
    }
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = data['fullName'] ?? '';
            _originalUsername = data['username'] ?? '';
            _usernameController.text = _originalUsername ?? '';
            _emailController.text = data['email'] ?? user?.email ?? '';
            _dobController.text = data['dob'] ?? '';
            _selectedGender = data['gender'];
            isLoading = false;
          });
        } else {
           setState(() => isLoading = false);
        }
      } catch (e) {
        debugPrint("Error fetching user data: $e");
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      if (!_isUsernameAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username unavailable')));
        return;
      }

      setState(() => isSaving = true);

      try {
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'fullName': _nameController.text.trim(),
          'username': _usernameController.text.trim(),
          'dob': _dobController.text.trim(),
          'gender': _selectedGender,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
        }
      } finally {
        if (mounted) setState(() => isSaving = false);
      }
    }
  }

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
          'Account Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (!isLoading)
            TextButton(
              onPressed: isSaving ? null : _saveChanges,
              child: isSaving 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text("Save", style: TextStyle(color: Color(0xFF7041EE), fontWeight: FontWeight.bold)),
            )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                     _buildTextField("Full Name", _nameController),
                     const SizedBox(height: 20),
                     _buildTextField(
                       "Username", 
                       _usernameController, 
                       suffix: _isCheckingUsername 
                           ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                           : (_usernameError != null ? const Icon(Icons.error, color: Colors.red) : null),
                       errorText: _usernameError
                     ),
                     const SizedBox(height: 20),
                     _buildTextField("Email", _emailController, readOnly: true), // Email usually not editable here
                     const SizedBox(height: 20),
                     _buildDateField("Date of Birth", _dobController),
                     const SizedBox(height: 20),
                     _buildGenderDropdown(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, Widget? suffix, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          style: const TextStyle(color: Colors.white),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF222232),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: suffix,
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF222232),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Gender", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          dropdownColor: const Color(0xFF222232),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF222232),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: ['Male', 'Female', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => _selectedGender = val),
        ),
      ],
    );
  }
}
