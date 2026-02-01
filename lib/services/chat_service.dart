import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moonchat/models/message_model.dart';
import 'package:moonchat/models/user_model.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Update user status
  Future<void> updateUserStatus(bool isOnline) async {
    if (currentUserId.isEmpty) return;
    await _firestore.collection('users').doc(currentUserId).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // Search users by username
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    
    final result = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    return result.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where((user) => user.uid != currentUserId)
        .toList();
  }

  // Get or Create Chat Room ID for 1v1
  String getChatRoomId(String user1, String user2) {
    List<String> ids = [user1, user2];
    ids.sort();
    return ids.join('_');
  }

  // Send Message with unread count support
  Future<void> sendMessage(String chatRoomId, String text, {String? imageUrl, bool isGroup = false, String? receiverId}) async {
    final String senderId = _auth.currentUser?.uid ?? '';
    if (senderId.isEmpty) return;
    
    final Timestamp timestamp = Timestamp.now();

    MessageModel newMessage = MessageModel(
      senderId: senderId,
      text: text,
      imageUrl: imageUrl,
      type: imageUrl != null ? MessageType.image : MessageType.text,
      timestamp: timestamp,
    );

    String collectionPath = isGroup ? 'groups' : 'chat_rooms';

    await _firestore
        .collection(collectionPath)
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    // Update last message and unread count
    Map<String, dynamic> updateData = {
      'lastMessage': text,
      'lastMessageTime': timestamp,
      'lastSenderId': senderId,
    };

    if (!isGroup) {
      updateData['users'] = FieldValue.arrayUnion([senderId, receiverId]);
      // Increment unread count for the receiver
      updateData['unreadCount_$receiverId'] = FieldValue.increment(1);
    }

    await _firestore.collection(collectionPath).doc(chatRoomId).set(updateData, SetOptions(merge: true));
  }

  // Update specific message status
  Future<void> updateMessageStatus(String chatRoomId, String messageId, MessageStatus status) async {
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({'status': status.name});
  }

  // Mark all as read and update message status
  Future<void> markAsRead(String chatRoomId) async {

    if (currentUserId.isEmpty) return;
    
    // Reset room unread count
    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'unreadCount_$currentUserId': 0,
    }, SetOptions(merge: true));

    // Update individual messages status to 'read'
    final unreadMessages = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('status', isNotEqualTo: 'read')
        .get();

    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'status': 'read'});
    }
    await batch.commit();
  }

  // Get User Profile Stream
  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // Get Messages Stream
  Stream<QuerySnapshot> getMessages(String chatRoomId, {bool isGroup = false}) {
    String collectionPath = isGroup ? 'groups' : 'chat_rooms';
    return _firestore
        .collection(collectionPath)
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get User Profile
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }
  
  // Get Chat Rooms for current user
  Stream<QuerySnapshot> getChatRooms() {
    return _firestore
        .collection('chat_rooms')
        .where('users', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
}
