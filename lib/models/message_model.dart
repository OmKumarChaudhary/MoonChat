import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image }
enum MessageStatus { sent, delivered, read }

class MessageModel {
  final String senderId;
  final String text;
  final String? imageUrl;
  final MessageType type;
  final Timestamp timestamp;
  final MessageStatus status;

  MessageModel({
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      type: map['type'] == 'image' ? MessageType.image : MessageType.text,
      timestamp: map['timestamp'] ?? Timestamp.now(),
      status: _parseStatus(map['status']),
    );
  }

  static MessageStatus _parseStatus(String? status) {
    switch (status) {
      case 'delivered': return MessageStatus.delivered;
      case 'read': return MessageStatus.read;
      default: return MessageStatus.sent;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'type': type == MessageType.image ? 'image' : 'text',
      'timestamp': timestamp,
      'status': status.name,
    };
  }
}
