import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:moonchat/models/message_model.dart';
import 'package:moonchat/models/user_model.dart';
import 'package:moonchat/services/chat_service.dart';
import 'package:flutter/foundation.dart' as foundation;

class ChatScreen extends StatefulWidget {
  final UserModel receiver;
  final bool isGroup;
  final String? groupId;

  const ChatScreen({
    Key? key,
    required this.receiver,
    this.isGroup = false,
    this.groupId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  late String _chatRoomId;
  bool _showEmoji = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() => _showEmoji = false);
      }
    });
    if (widget.isGroup) {
      _chatRoomId = widget.groupId!;
    } else {
      _chatRoomId = _chatService.getChatRoomId(_chatService.currentUserId, widget.receiver.uid);
      // Mark as read when entering 1v1 chat
      _chatService.markAsRead(_chatRoomId);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      _chatService.sendMessage(
        _chatRoomId, 
        _messageController.text.trim(), 
        isGroup: widget.isGroup,
        receiverId: widget.receiver.uid
      );
      _messageController.clear();
    }
  }

  Future<void> _sendImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 70);
      if (image != null) {
        final List<int> imageBytes = await image.readAsBytes();
        String base64String = base64Encode(imageBytes);
        
        _chatService.sendMessage(
          _chatRoomId, 
          "Sent an image", 
          imageUrl: base64String, 
          isGroup: widget.isGroup,
          receiverId: widget.receiver.uid
        );
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _openImageFullscreen(String base64Image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewer(base64Image: base64Image),
      ),
    );
  }

  void _showUserDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF222232),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: widget.receiver.profileImage != null
                    ? MemoryImage(base64Decode(widget.receiver.profileImage!))
                    : null,
                child: widget.receiver.profileImage == null
                    ? Text(widget.receiver.fullName[0], style: const TextStyle(fontSize: 24, color: Colors.white))
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                widget.receiver.fullName,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '@${widget.receiver.username}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              const ListTile(
                leading: Icon(Icons.email_outlined, color: Color(0xFF7041EE)),
                title: Text('Email', style: TextStyle(color: Colors.grey, fontSize: 12)),
                subtitle: Text('User email hidden for privacy', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7041EE),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151522),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151522),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream: _chatService.getUserStream(widget.receiver.uid),
          builder: (context, snapshot) {
            String status = 'Offline';
            bool isOnline = false;
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              isOnline = data['isOnline'] ?? false;
              status = isOnline ? 'Online' : 'Offline';
            }

            return Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: widget.receiver.profileImage != null
                      ? MemoryImage(base64Decode(widget.receiver.profileImage!))
                      : null,
                  child: widget.receiver.profileImage == null
                      ? Text(widget.receiver.fullName[0], style: const TextStyle(color: Colors.white))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFirstName(widget.receiver.fullName),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        status,
                        style: TextStyle(color: isOnline ? Colors.green : Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showUserDetails,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(_chatRoomId, isGroup: widget.isGroup),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet", style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final message = MessageModel.fromMap(doc.data() as Map<String, dynamic>);
                    final bool isMe = message.senderId == _chatService.currentUserId;
                    
                    // Mark as delivered if I'm the receiver and it's currently 'sent'
                    if (!isMe && !widget.isGroup && message.status == MessageStatus.sent) {
                      _chatService.updateMessageStatus(_chatRoomId, doc.id, MessageStatus.delivered);
                    }

                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
          if (_showEmoji)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (Category? category, Emoji emoji) {
                  _messageController.text = _messageController.text + emoji.emoji;
                },
                config: Config(
                  height: 250,
                  emojiViewConfig: EmojiViewConfig(
                    columns: 7,
                    emojiSizeMax: 32 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.30 : 1.0),
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    gridPadding: EdgeInsets.zero,
                    recentsLimit: 28,
                    backgroundColor: const Color(0xFF151522),
                    noRecents: const Text(
                      'No Recents',
                      style: TextStyle(fontSize: 20, color: Colors.white24),
                      textAlign: TextAlign.center,
                    ),
                    buttonMode: ButtonMode.MATERIAL,
                  ),
                  categoryViewConfig: CategoryViewConfig(
                    initCategory: Category.RECENT,
                    indicatorColor: const Color(0xFF7041EE),
                    iconColor: Colors.grey,
                    iconColorSelected: const Color(0xFF7041EE),
                    backspaceColor: const Color(0xFF7041EE),
                    tabIndicatorAnimDuration: kTabScrollDuration,
                    categoryIcons: const CategoryIcons(),
                    backgroundColor: const Color(0xFF151522),
                  ),
                  skinToneConfig: const SkinToneConfig(
                    enabled: true,
                    dialogBackgroundColor: Colors.white,
                    indicatorColor: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return "User";
    return fullName.split(' ').first;
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    final String time = DateFormat('h:mm a').format(message.timestamp.toDate());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (widget.isGroup)
            Padding(
              padding: EdgeInsets.only(left: isMe ? 0 : 32, right: isMe ? 32 : 0, bottom: 4),
              child: isMe 
                ? const Text("You", style: TextStyle(color: Color(0xFF7041EE), fontSize: 10, fontWeight: FontWeight.bold))
                : FutureBuilder<UserModel?>(
                    future: _chatService.getUserProfile(message.senderId),
                    builder: (context, snapshot) {
                      return Text(
                        _getFirstName(snapshot.data?.fullName ?? "User"),
                        style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                      );
                    }
                  ),
            ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 12,
                  backgroundImage: widget.receiver.profileImage != null
                      ? MemoryImage(base64Decode(widget.receiver.profileImage!))
                      : null,
                  child: widget.receiver.profileImage == null
                      ? Text(widget.receiver.fullName[0], style: const TextStyle(fontSize: 8, color: Colors.white))
                      : null,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: message.type == MessageType.image && message.text == "Sent an image"
                      ? const EdgeInsets.all(4)
                      : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF7041EE) : const Color(0xFF222232),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                      bottomRight: isMe ? Radius.zero : const Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       if (message.type == MessageType.image && message.imageUrl != null) ...[
                         GestureDetector(
                            onTap: () => _openImageFullscreen(message.imageUrl!),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                                  maxHeight: 250,
                                ),
                                child: Image.memory(
                                  base64Decode(message.imageUrl!), 
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                         if (message.text != "Sent an image") const SizedBox(height: 8),
                       ],
                      if (message.text != "Sent an image")
                        Text(
                          message.text,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 32, right: 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(message.status),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return const Icon(Icons.check, color: Colors.grey, size: 14);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, color: Colors.grey, size: 14);
      case MessageStatus.read:
        return const Icon(Icons.done_all, color: Colors.blue, size: 14);
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF151522),
        border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
            onPressed: _sendImage,
          ),
          IconButton(
            icon: Icon(
              _showEmoji ? Icons.keyboard : Icons.emoji_emotions_outlined,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _showEmoji = !_showEmoji;
                if (_showEmoji) {
                  _focusNode.unfocus();
                } else {
                  _focusNode.requestFocus();
                }
              });
            },
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF222232),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF7041EE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageViewer extends StatelessWidget {
  final String base64Image;

  const ImageViewer({Key? key, required this.base64Image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: MemoryImage(base64Decode(base64Image)),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }
}
