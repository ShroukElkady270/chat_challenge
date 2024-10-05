import 'dart:async';

import 'package:educatly_challenge/models/message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String userId; // Current user's ID
  final String recipientId; // Recipient's ID
  final String recipientEmail; // Recipient's ID

  const ChatScreen({
    super.key,
    required this.userId,
    required this.recipientId,
    required this.recipientEmail,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  bool _isOnline = false;
  DateTime? _lastSeen;
  bool _isTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _fetchUserStatus(widget.recipientId);
    _fetchMessages();
    _setTypingStatus();
    _listenToTypingStatus();
  }

  void _fetchUserStatus(String userId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _isOnline = snapshot.data()?['isOnline'] ?? false;
          _lastSeen = (snapshot.data()?['lastSeen'] != null
              ? snapshot.data() != null
                  ? ['lastSeen']
                  : null
              : null) as DateTime?;
        });
      }
    });
  }

  Future<String> getUserAvatar(String userId) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (snapshot.exists) {
      return snapshot.data()?['avatarUrl'] ??
          ''; // Return avatar URL or empty string if not found
    }
    return ''; // Default to empty string if user not found
  }

  void _fetchMessages() {
    FirebaseFirestore.instance
        .collection('messages')
        .where('recipientId', isEqualTo: widget.userId)
        .where('senderId', isEqualTo: widget.recipientId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) async {
      List<Message> messages = [];
      for (var doc in snapshot.docs) {
        String avatarUrl = await getUserAvatar(doc.data()['senderId']);
        messages.add(Message(
          senderId: doc.data()['senderId'],
          recipientId: doc.data()['recipientId'],
          text: doc.data()['text'],
          timestamp: doc.data()['timestamp'],
          avatarUrl: avatarUrl,
        ));
      }
      setState(() {
        _messages = messages;
      });
    });
  }

  void _setTypingStatus() {
    FirebaseFirestore.instance
        .collection('typing_status')
        .doc(widget.recipientId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _isTyping = snapshot.data()?['isTyping'] ?? false;
        });
      }
    });
  }

  void _listenToTypingStatus() {
    FirebaseFirestore.instance
        .collection('typing_status')
        .doc(widget.recipientId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _isTyping = snapshot.data()?['isTyping'] ?? false;
        });
      }
    });
  }

  void _sendMessage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _messageController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('messages').add({
        'text': _messageController.text,
        'senderId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'recipientId': widget.recipientId,
        'avatarUrl': '',
      });
      _messageController.clear();
    }
  }

  void _setTyping(bool isTyping) {
    FirebaseFirestore.instance
        .collection('typing_status')
        .doc(widget.userId)
        .set({
      'isTyping': isTyping,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Column(
            children: [
              Text(
                widget.recipientEmail,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _isOnline
                    ? "Online"
                    : "Last seen: ${_lastSeen != null ? DateFormat('hh:mm a').format(_lastSeen!) : 'unknown'}",
                style: const TextStyle(
                  fontSize: 13.0,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final chatDocs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index) {
                    var document = chatDocs[index];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                    String? avatarUrl = data.containsKey('avatarUrl')
                        ? data['avatarUrl']
                        : 'default_avatar_url';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 23.0,
                        vertical: 4.0,
                      ),
                      child: Align(
                        alignment: widget.userId == chatDocs[index]['senderId']
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.userId == chatDocs[index]['senderId']
                                ? Colors.blue
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                avatarUrl!,
                              ),
                            ),
                            title: Text(chatDocs[index]['text']),
                            subtitle: Text(
                              'From ${chatDocs[index]['recipientId']} - ${DateFormat('hh:mm a').format(chatDocs[index]['timestamp'].toDate())}',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("${widget.recipientEmail} is typing..."),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _setTyping(value.isNotEmpty); // Set typing status
                      if (_typingTimer != null) {
                        _typingTimer!.cancel(); // Cancel previous timer
                      }
                      // Set a timer to update typing status to false after 1 second of inactivity
                      _typingTimer = Timer(const Duration(seconds: 1), () {
                        _setTyping(false);
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
