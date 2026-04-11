import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _filter = 'all'; // all | pending | reviewed | resolved

  Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
        return Colors.green;
      case 'reviewed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'resolved':
        return Icons.check_circle_rounded;
      case 'reviewed':
        return Icons.visibility_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  Future<void> _updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(docId)
        .update({'status': newStatus});
  }

  Future<void> _deleteReport(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1D1D2C),
        title: const Text('Delete Report', style: TextStyle(color: Colors.white)),
        content: const Text('Remove this report? This cannot be undone.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('reports').doc(docId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('reports')
        .orderBy('createdAt', descending: true);

    if (_filter != 'all') {
      query = query.where('status', isEqualTo: _filter);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              const Expanded(
                child: Text('User Reports',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['all', 'pending', 'reviewed', 'resolved']
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f[0].toUpperCase() + f.substring(1)),
                          selected: _filter == f,
                          onSelected: (_) => setState(() => _filter = f),
                          selectedColor: Colors.red,
                          backgroundColor: const Color(0xFF1D1D2C),
                          labelStyle: TextStyle(
                              color:
                                  _filter == f ? Colors.white : Colors.white54),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),

        // Reports list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.red));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded,
                          color: Colors.white24, size: 64),
                      const SizedBox(height: 12),
                      Text('No $_filter reports found.',
                          style: const TextStyle(color: Colors.white38)),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'pending';
                  final ts = data['createdAt'];
                  String dateStr = '';
                  if (ts != null && ts is Timestamp) {
                    final dt = ts.toDate().toLocal();
                    dateStr =
                        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D1D2C),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _statusColor(status).withOpacity(0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User info row
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white12,
                                backgroundImage:
                                    (data['userPhotoUrl'] ?? '').isNotEmpty
                                        ? NetworkImage(data['userPhotoUrl'])
                                        : null,
                                child: (data['userPhotoUrl'] ?? '').isEmpty
                                    ? Text(
                                        (data['userName'] ?? '?')
                                            .toString()
                                            .isNotEmpty
                                            ? (data['userName'] as String)[0]
                                                .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['userName'] ?? 'Unknown',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    Text(data['userEmail'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_statusIcon(status),
                                        color: _statusColor(status), size: 13),
                                    const SizedBox(width: 4),
                                    Text(
                                      status[0].toUpperCase() +
                                          status.substring(1),
                                      style: TextStyle(
                                          color: _statusColor(status),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Category + Message
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              data['category'] ?? 'Other',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 11),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                          child: Text(
                            data['message'] ?? '',
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.5),
                          ),
                        ),

                        // Date + Actions
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 6, 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(dateStr,
                                    style: const TextStyle(
                                        color: Colors.white24, fontSize: 11)),
                              ),
                              // Status update menu
                              PopupMenuButton<String>(
                                color: const Color(0xFF2A2A3C),
                                icon: const Icon(Icons.more_vert,
                                    color: Colors.white38, size: 20),
                                onSelected: (val) {
                                  if (val == 'delete') {
                                    _deleteReport(doc.id);
                                  } else {
                                    _updateStatus(doc.id, val);
                                  }
                                },
                                itemBuilder: (_) => [
                                  if (status != 'reviewed')
                                    const PopupMenuItem(
                                      value: 'reviewed',
                                      child: Row(children: [
                                        Icon(Icons.visibility,
                                            color: Colors.blue, size: 16),
                                        SizedBox(width: 8),
                                        Text('Mark Reviewed',
                                            style: TextStyle(
                                                color: Colors.white)),
                                      ]),
                                    ),
                                  if (status != 'resolved')
                                    const PopupMenuItem(
                                      value: 'resolved',
                                      child: Row(children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.green, size: 16),
                                        SizedBox(width: 8),
                                        Text('Mark Resolved',
                                            style: TextStyle(
                                                color: Colors.white)),
                                      ]),
                                    ),
                                  if (status != 'pending')
                                    const PopupMenuItem(
                                      value: 'pending',
                                      child: Row(children: [
                                        Icon(Icons.hourglass_top,
                                            color: Colors.orange, size: 16),
                                        SizedBox(width: 8),
                                        Text('Reopen',
                                            style: TextStyle(
                                                color: Colors.white)),
                                      ]),
                                    ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(children: [
                                      Icon(Icons.delete_outline,
                                          color: Colors.red, size: 16),
                                      SizedBox(width: 8),
                                      Text('Delete',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
