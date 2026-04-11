import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrivacyPolicyManager extends StatefulWidget {
  const PrivacyPolicyManager({super.key});

  @override
  State<PrivacyPolicyManager> createState() => _PrivacyPolicyManagerState();
}

class _PrivacyPolicyManagerState extends State<PrivacyPolicyManager>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          color: const Color(0xFF1D1D2C),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Legal Documents',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage Privacy Policy & Terms of Service shown to users',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.red,
                labelColor: Colors.red,
                unselectedLabelColor: Colors.white54,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.privacy_tip_outlined, size: 18),
                    text: 'Privacy Policy',
                  ),
                  Tab(
                    icon: Icon(Icons.gavel_rounded, size: 18),
                    text: 'Terms of Service',
                  ),
                ],
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _DocumentEditor(docKey: 'privacy_policy', label: 'Privacy Policy'),
              _DocumentEditor(docKey: 'terms_of_service', label: 'Terms of Service'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Document Editor — handles a single policy document
// ─────────────────────────────────────────────────────────
class _DocumentEditor extends StatefulWidget {
  final String docKey;
  final String label;
  const _DocumentEditor({required this.docKey, required this.label});

  @override
  State<_DocumentEditor> createState() => _DocumentEditorState();
}

class _DocumentEditorState extends State<_DocumentEditor> {
  List<Map<String, dynamic>> _sections = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _previewMode = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Firestore helpers ──────────────────────────────────

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc(widget.docKey)
          .get();
      if (doc.exists) {
        final raw = doc.data()?['sections'];
        if (raw is List) {
          _sections = List<Map<String, dynamic>>.from(
              raw.map((e) => Map<String, dynamic>.from(e as Map)));
        }
      }
    } catch (e) {
      _snack('Failed to load: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('app_settings')
          .doc(widget.docKey)
          .set({
        'sections': _sections,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _snack('${widget.label} saved successfully!');
    } catch (e) {
      _snack('Failed to save: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  // ── Section CRUD ───────────────────────────────────────

  void _addSection() {
    _showSectionDialog();
  }

  void _editSection(int index) {
    _showSectionDialog(index: index, existing: _sections[index]);
  }

  void _deleteSection(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1D1D2C),
        title: const Text('Delete Section',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${_sections[index]['title']}"?',
          style: const TextStyle(color: Colors.white70),
        ),
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
      setState(() => _sections.removeAt(index));
    }
  }

  void _reorderSection(int oldIdx, int newIdx) {
    setState(() {
      if (newIdx > oldIdx) newIdx--;
      final item = _sections.removeAt(oldIdx);
      _sections.insert(newIdx, item);
    });
  }

  void _showSectionDialog({int? index, Map<String, dynamic>? existing}) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final bodyCtrl = TextEditingController(text: existing?['body'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1D1D2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          index == null ? 'Add Section' : 'Edit Section',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Section Title',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                _dialogField(titleCtrl, 'e.g. Data Collection', maxLines: 1),
                const SizedBox(height: 16),
                const Text('Content',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                _dialogField(bodyCtrl, 'Enter section content...', maxLines: 8),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final title = titleCtrl.text.trim();
              final body = bodyCtrl.text.trim();
              if (title.isEmpty || body.isEmpty) return;
              setState(() {
                final section = {'title': title, 'body': body};
                if (index == null) {
                  _sections.add(section);
                } else {
                  _sections[index] = section;
                }
              });
              Navigator.pop(context);
            },
            child: Text(index == null ? 'Add' : 'Save',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    return Column(
      children: [
        // Toolbar
        Container(
          color: const Color(0xFF151522),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _toolBtn(
                icon: _previewMode ? Icons.edit : Icons.preview_rounded,
                label: _previewMode ? 'Edit Mode' : 'Preview',
                onTap: () => setState(() => _previewMode = !_previewMode),
                color: Colors.white70,
              ),
              const Spacer(),
              if (!_previewMode)
                _toolBtn(
                  icon: Icons.add_circle_outline,
                  label: 'Add Section',
                  onTap: _addSection,
                  color: Colors.blue,
                ),
              const SizedBox(width: 8),
              _toolBtn(
                icon: Icons.save_rounded,
                label: _isSaving ? 'Saving…' : 'Save',
                onTap: _isSaving ? null : _save,
                color: Colors.red,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.white10),
        // Body
        Expanded(
          child: _previewMode ? _buildPreview() : _buildEditor(),
        ),
      ],
    );
  }

  Widget _toolBtn({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ── Editor (drag-to-reorder) ───────────────────────────

  Widget _buildEditor() {
    if (_sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            const Text('No sections yet.',
                style: TextStyle(color: Colors.white38, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Tap "Add Section" to get started.',
                style: TextStyle(color: Colors.white24, fontSize: 13)),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      onReorder: _reorderSection,
      itemCount: _sections.length,
      itemBuilder: (context, i) {
        final section = _sections[i];
        return _SectionCard(
          key: ValueKey('$i-${section['title']}'),
          index: i,
          title: section['title'] ?? '',
          body: section['body'] ?? '',
          onEdit: () => _editSection(i),
          onDelete: () => _deleteSection(i),
        );
      },
    );
  }

  // ── Preview ────────────────────────────────────────────

  Widget _buildPreview() {
    if (_sections.isEmpty) {
      return const Center(
        child: Text('Nothing to preview yet.',
            style: TextStyle(color: Colors.white38)),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          widget.label,
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('Last updated by admin',
            style: TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 20),
        ..._sections.map((s) => _PreviewSection(
              title: s['title'] ?? '',
              body: s['body'] ?? '',
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Section Card widget
// ─────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final int index;
  final String title;
  final String body;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SectionCard({
    super.key,
    required this.index,
    required this.title,
    required this.body,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D2C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            decoration: const BoxDecoration(
              color: Color(0xFF252535),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                // drag handle + actions
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: Colors.white54, size: 18),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 18),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.drag_handle, color: Colors.white24, size: 20),
              ],
            ),
          ),
          // Body preview
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Text(
              body,
              style: const TextStyle(
                  color: Colors.white60, fontSize: 13, height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Preview section widget
// ─────────────────────────────────────────────────────────
class _PreviewSection extends StatelessWidget {
  final String title;
  final String body;
  const _PreviewSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D2C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style:
                const TextStyle(color: Colors.white70, fontSize: 14, height: 1.7),
          ),
        ],
      ),
    );
  }
}
