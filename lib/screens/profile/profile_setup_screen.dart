import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;
  Uint8List? _imageBytes;
  String? _base64Image;

  // Username validation
  String? _usernameError;
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onUsernameChanged);
    _nameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    setState(() {
      _usernameError = null;
      _isUsernameAvailable = null;
      _isCheckingUsername = true;
    });

    if (_usernameController.text.trim().isEmpty) {
      setState(() {
         _isCheckingUsername = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _checkUsernameAvailability(_usernameController.text.trim());
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.length < 3) {
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
          _usernameError = "Username must be at least 3 chars";
          _isUsernameAvailable = false;
        });
      }
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
            _usernameError = "Username unavailable";
            _isUsernameAvailable = false;
          } else {
            _usernameError = null;
            _isUsernameAvailable = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
          _isUsernameAvailable = null;
        });
      }
    }
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, 
        maxWidth: 512, 
        maxHeight: 512, 
        imageQuality: 70,
      );
      
      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        final String base64String = base64Encode(bytes);
        
        setState(() {
          _imageBytes = bytes;
          _base64Image = base64String;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7041EE),
              onPrimary: Colors.white,
              surface: Color(0xFF222232),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF151522),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty || 
        _usernameController.text.isEmpty || 
        _dobController.text.isEmpty || 
        _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    
    if (_isUsernameAvailable != true) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a valid username')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fullName': _nameController.text.trim(),
          'username': _usernameController.text.trim(),
          'dob': _dobController.text.trim(),
          'gender': _selectedGender,
          'email': user.email,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'profileSetupCompleted': true,
          'profileImage': _base64Image,
        }, SetOptions(merge: true));

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _usernameSuffix() {
    if (_isCheckingUsername) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 20, 
          height: 20, 
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      );
    }
    if (_usernameController.text.isNotEmpty) {
       if (_isUsernameAvailable == true) {
         return const Icon(Icons.check_circle_outline, color: Colors.green);
       } else if (_isUsernameAvailable == false) {
         return const Icon(Icons.cancel_outlined, color: Colors.red);
       }
    }
    return const SizedBox.shrink();
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
            child: const Icon(Icons.arrow_back, color: Colors.white)),
        title: const Text(
          'Personal Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Your Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Mulish',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This information helps others find you on MoonChat.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontFamily: 'Mulish',
                ),
              ),
              const SizedBox(height: 30),

              Center(
               child: Stack(
                 children: [
                   GestureDetector(
                     onTap: _pickImage,
                     child: Container(
                       width: 100,
                       height: 100,
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                        color: const Color(0xFF222232),
                         border: Border.all(color: Colors.white24),
                         image: _imageBytes != null 
                             ? DecorationImage(
                                 image: MemoryImage(_imageBytes!),
                                 fit: BoxFit.cover,
                               )
                             : null,
                       ),
                       child: _imageBytes == null
                           ? const Icon(Icons.camera_alt, color: Colors.white54, size: 40)
                           : null,
                     ),
                   ),
                   if (_imageBytes != null)
                   Positioned(
                     bottom: 0,
                     right: 0,
                     child: Container(
                       padding: const EdgeInsets.all(4),
                       decoration: const BoxDecoration(
                         color: Color(0xFF7041EE),
                         shape: BoxShape.circle,
                       ),
                       child: const Icon(Icons.edit, color: Colors.white, size: 14),
                     ),
                   ),
                 ],
               ),
             ),
             const SizedBox(height: 30),

              // Full Name
              const Text(
                'Full Name',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Mulish',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF222232),
                  hintText: 'Enter your full name',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),

              // Username
              const Text(
                'Username',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Mulish',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF222232),
                  hintText: 'Enter a unique username',
                  hintStyle: const TextStyle(color: Colors.grey),
                  suffixIcon: _usernameSuffix(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),

              // Date of Birth
              const Text(
                'Date of Birth',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Mulish',
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dobController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF222232),
                      hintText: 'Select your birth date',
                      hintStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Gender
              const Text(
                'Gender',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Mulish',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                   Expanded(child: _buildGenderButton('Male')),
                   const SizedBox(width: 12),
                   Expanded(child: _buildGenderButton('Female')),
                ],
              ),
               const SizedBox(height: 12),
               Row(
                children: [
                   Expanded(child: _buildGenderButton('Other')),
                   const SizedBox(width: 12),
                   Expanded(child: _buildGenderButton('Prefer not to say')),
                ],
              ),

              const SizedBox(height: 40),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isUsernameAvailable != true) ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7041EE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: const Color(0xFF222232).withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton(String gender) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7041EE) : const Color(0xFF222232),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF7041EE) : Colors.transparent, 
            width: 1
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          gender,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

