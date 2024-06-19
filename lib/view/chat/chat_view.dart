import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final String chatUserId;

  ChatScreen({required this.chatUserId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  String? _currentUserId;
  late String _chatRoomId;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _currentUserId = _auth.currentUser?.uid;

    if (_currentUserId != null) {
      _chatRoomId = _getChatRoomId(_currentUserId!, widget.chatUserId);
    } else {
      // Handle the case when the user is not logged in
      // For example, navigate to the login screen or show an error message
      Navigator.of(context).pushReplacementNamed('/login'); // Example navigation to login screen
    }
  }

  String _getChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1-$user2' : '$user2-$user1';
  }

  Future<void> _sendMessage(String message, {String? imageUrl}) async {
    if (message.trim().isEmpty && imageUrl == null) return;

    final timestamp = FieldValue.serverTimestamp();
    final messageData = {
      'senderId': _currentUserId,
      'receiverId': widget.chatUserId,
      'message': message,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };

    _firestore.collection('chat_rooms').doc(_chatRoomId).collection('messages').add(messageData);

    _messageController.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final fileName = Uuid().v4();
      final storageRef = FirebaseStorage.instance.ref().child('chat_images').child(fileName);
      final uploadTask = storageRef.putFile(file);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _sendMessage('', imageUrl: downloadUrl);
    } catch (error) {
      print('Failed to upload image: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chat_rooms')
                  .doc(_chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message['senderId'] == _currentUserId;
                    return ListTile(
                      title: Column(
                        crossAxisAlignment:
                            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (message['imageUrl'] != null)
                            Image.network(
                              message['imageUrl'],
                              width: 150,
                              height: 150,
                            ),
                          if (message['message'] != null && message['message'].isNotEmpty)
                            Text(message['message']),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: _pickAndUploadImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
