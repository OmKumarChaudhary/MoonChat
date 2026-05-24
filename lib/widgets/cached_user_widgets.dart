import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moonchat/models/user_model.dart';
import 'package:moonchat/services/chat_service.dart';

/// A high-performance StreamBuilder wrapper that:
/// 1. Reuses the exact same real-time stream subscription for a given user across the app.
/// 2. Caches resolved user profiles to immediately render them without blinking or layout jumps.
class CachedUserStreamBuilder extends StatefulWidget {
  final String userId;
  final Widget Function(BuildContext context, UserModel user) builder;
  final Widget fallback;

  const CachedUserStreamBuilder({
    super.key,
    required this.userId,
    required this.builder,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  State<CachedUserStreamBuilder> createState() => _CachedUserStreamBuilderState();
}

class _CachedUserStreamBuilderState extends State<CachedUserStreamBuilder> {
  static final Map<String, Stream<DocumentSnapshot>> _streamCache = {};
  static final Map<String, UserModel> _userCache = {};

  @override
  Widget build(BuildContext context) {
    // Reuse the exact same stream object to prevent multiple real-time listeners for the same user
    final stream = _streamCache.putIfAbsent(
      widget.userId,
      () => FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
    );

    return StreamBuilder<DocumentSnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            final user = UserModel.fromMap(data);
            _userCache[widget.userId] = user;
            return widget.builder(context, user);
          }
        }

        // If the stream is waiting or disconnected but we have cached user data, render immediately
        if (_userCache.containsKey(widget.userId)) {
          return widget.builder(context, _userCache[widget.userId]!);
        }

        return widget.fallback;
      },
    );
  }
}

/// A high-performance FutureBuilder wrapper that:
/// 1. De-duplicates identical asynchronous profile fetches (only executes one Future at a time).
/// 2. Cache-resolves user profiles in memory to render cached copies instantly on subsequent builds.
class CachedUserProfileWidget extends StatefulWidget {
  final String userId;
  final ChatService chatService;
  final Widget Function(BuildContext context, UserModel? user) builder;

  const CachedUserProfileWidget({
    super.key,
    required this.userId,
    required this.chatService,
    required this.builder,
  });

  @override
  State<CachedUserProfileWidget> createState() => _CachedUserProfileWidgetState();
}

class _CachedUserProfileWidgetState extends State<CachedUserProfileWidget> {
  static final Map<String, UserModel> _userProfileCache = {};
  static final Map<String, Future<UserModel?>> _pendingFutures = {};

  @override
  Widget build(BuildContext context) {
    // If user profile is already cached in memory, return it instantly
    if (_userProfileCache.containsKey(widget.userId)) {
      return widget.builder(context, _userProfileCache[widget.userId]);
    }

    // De-duplicate concurrent Futures for the same userId
    final future = _pendingFutures.putIfAbsent(
      widget.userId,
      () => widget.chatService.getUserProfile(widget.userId),
    );

    return FutureBuilder<UserModel?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            _userProfileCache[widget.userId] = snapshot.data!;
          }
          // Clean up the future cache once done so future loads get fresh data if needed
          _pendingFutures.remove(widget.userId);
        }

        final displayUser = snapshot.data ?? _userProfileCache[widget.userId];
        return widget.builder(context, displayUser);
      },
    );
  }
}
