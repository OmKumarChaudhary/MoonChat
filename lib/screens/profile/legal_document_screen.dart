import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Displays a legal document (Privacy Policy or Terms of Service)
/// streamed LIVE from Firestore — any admin update reflects instantly.
class LegalDocumentScreen extends StatelessWidget {
  final String docKey;   // 'privacy_policy' or 'terms_of_service'
  final String title;

  const LegalDocumentScreen({
    Key? key,
    required this.docKey,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151522),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1D2C),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      // ── StreamBuilder keeps user page in sync with admin changes ──
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('app_settings')
            .doc(docKey)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7041EE)),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 52),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load content.\nPlease try again later.',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Parse sections
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final rawSections = data?['sections'];
          final List<Map<String, dynamic>> sections = rawSections is List
              ? List<Map<String, dynamic>>.from(
                  rawSections.map((e) => Map<String, dynamic>.from(e as Map)))
              : [];

          // Parse timestamp
          String? updatedAt;
          final ts = data?['updatedAt'];
          if (ts is Timestamp) {
            updatedAt = DateFormat('MMMM d, yyyy').format(ts.toDate());
          }

          // Empty
          if (sections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    docKey == 'privacy_policy'
                        ? Icons.privacy_tip_outlined
                        : Icons.gavel_rounded,
                    color: Colors.white24,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$title not available yet.',
                    style: const TextStyle(color: Colors.white38, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check back soon.',
                    style: TextStyle(color: Colors.white24, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7041EE), Color(0xFF9B59B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      docKey == 'privacy_policy'
                          ? Icons.privacy_tip_rounded
                          : Icons.gavel_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          if (updatedAt != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Last updated: $updatedAt',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sections
              ...sections.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                return _buildSection(
                  context,
                  number: i + 1,
                  title: s['title'] ?? '',
                  body: s['body'] ?? '',
                  isFirst: i == 0,
                );
              }),

              const SizedBox(height: 20),
              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1D2C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.white38, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'By using MoonChat, you agree to all terms listed above. Contact support for any questions.',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 12, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required int number,
    required String title,
    required String body,
    bool isFirst = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D2C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isFirst,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF7041EE).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                  color: Color(0xFF7041EE),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15),
          ),
          iconColor: Colors.white54,
          collapsedIconColor: Colors.white38,
          children: [
            Text(
              body,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14, height: 1.8),
            ),
          ],
        ),
      ),
    );
  }
}
