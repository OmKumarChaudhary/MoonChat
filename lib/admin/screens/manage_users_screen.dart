import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final String _backendUrl = 'http://127.0.0.1:5000/api/admin';
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsersFromFirestore();
  }

  Future<void> _fetchUsersFromFirestore() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch users directly from Firestore (no backend needed for listing)
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _users = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'uid': doc.id,
            'email': data['email'] ?? 'N/A',
            'display_name': data['fullName'] ?? data['username'] ?? 'N/A',
            'disabled': data['disabled'] ?? false,
            'isAdmin': data['isAdmin'] ?? false,
            'photoUrl': data['photoUrl'] ?? '',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load users: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleUserStatus(String uid, bool isCurrentlyDisabled) async {
    final newStatus = !isCurrentlyDisabled;

    // Optimistically update the UI
    setState(() {
      final idx = _users.indexWhere((u) => u['uid'] == uid);
      if (idx != -1) _users[idx]['disabled'] = newStatus;
    });

    // Update Firestore
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'disabled': newStatus});

      // Also try hitting the backend to update Firebase Auth (optional, will silently fail if not configured)
      try {
        await http.post(
          Uri.parse('$_backendUrl/users/$uid/status'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'disabled': newStatus}),
        );
      } catch (_) {
        // Backend not available — only Firestore updated
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus ? 'User disabled' : 'User enabled'),
            backgroundColor: newStatus ? Colors.red : Colors.green,
          ),
        );
      }
    } catch (e) {
      // Revert UI on failure
      setState(() {
        final idx = _users.indexWhere((u) => u['uid'] == uid);
        if (idx != -1) _users[idx]['disabled'] = isCurrentlyDisabled;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteUser(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1D1D2C),
        title: const Text('Delete User', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this user? This cannot be undone.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      setState(() => _users.removeWhere((u) => u['uid'] == uid));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User removed from database'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Manage Users',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('${_users.length} total users',
                      style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70),
                tooltip: 'Refresh',
                onPressed: _fetchUsersFromFirestore,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.red)))
        else if (_errorMessage != null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchUsersFromFirestore,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (_users.isEmpty)
          const Expanded(
            child: Center(
              child: Text('No users found.', style: TextStyle(color: Colors.white54)),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final disabled = user['disabled'] == true;
                final isAdmin = user['isAdmin'] == true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D1D2C),
                    borderRadius: BorderRadius.circular(14),
                    border: isAdmin
                        ? Border.all(color: Colors.red.withOpacity(0.5), width: 1)
                        : null,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white10,
                        backgroundImage: (user['photoUrl'] as String).isNotEmpty
                            ? NetworkImage(user['photoUrl'])
                            : null,
                        child: (user['photoUrl'] as String).isEmpty
                            ? Text(
                                (user['display_name'] as String).isNotEmpty
                                    ? (user['display_name'] as String)[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(user['display_name'],
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                if (isAdmin) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('Admin', style: TextStyle(color: Colors.red, fontSize: 10)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(user['email'],
                                style: const TextStyle(color: Colors.white54, fontSize: 13)),
                          ],
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: disabled ? Colors.red.withOpacity(0.15) : Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          disabled ? 'Disabled' : 'Active',
                          style: TextStyle(
                              color: disabled ? Colors.red : Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Actions menu
                      PopupMenuButton<String>(
                        color: const Color(0xFF2A2A3C),
                        icon: const Icon(Icons.more_vert, color: Colors.white54),
                        onSelected: (val) {
                          if (val == 'toggle') _toggleUserStatus(user['uid'], disabled);
                          if (val == 'delete') _deleteUser(user['uid']);
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(disabled ? Icons.check_circle : Icons.block,
                                    color: disabled ? Colors.green : Colors.orange, size: 18),
                                const SizedBox(width: 8),
                                Text(disabled ? 'Enable User' : 'Disable User',
                                    style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text('Delete User', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
