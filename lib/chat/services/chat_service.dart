import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educatly_challenge/models/chats_model.dart';
import 'package:educatly_challenge/models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Stream<List<Message>> fetchMessages(String userId, String recipientId) {
    return _firestore
        .collection('messages')
        .where('recipientId', isEqualTo: recipientId)
        .where('senderId', isEqualTo: userId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromFirestore(doc.data()))
            .toList());
  }

  Future<void> sendMessage(Message message) async {

    // Create a unique chat ID based on the user IDs
    String chatId = message.senderId.compareTo(message.recipientId) < 0
        ? '${message.senderId}_${message.recipientId}'
        : '${message.recipientId}_${message.senderId}';

    // Create a Chat instance
    Chat chat = Chat(
      chatId: chatId,
      userIds: [message.senderId, message.recipientId],
      lastMessage: message.text,
      lastMessageTimestamp: DateTime.now(),
    );

    createChat(chat);

    // Add message to messages collection
    await _firestore.collection('messages').add({
      'senderId': message.senderId,
      'recipientId': message.recipientId,
      'text': message.text,
      'timestamp': Timestamp.now(),
      'avatarUrl': message.avatarUrl,
    });

    // Create or update chat document
    await _firestore.collection('chats').doc('${message.senderId}_${message.recipientId}').set({
      'userIds': [message.senderId, message.recipientId],
      'lastMessage': message.text,
      'lastMessageTimestamp': Timestamp.now(),
    }, SetOptions(merge: true)); // Use merge to update existing chat document
  }

  // Fetch all chats for a specific user
  Stream<List<Map<String, dynamic>>> fetchAllChats(String userId) {
    return _firestore
        .collection('chats')
        .where('userIds', arrayContains: userId) // Check if userId is part of the chat
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Create a new chat
  Future<void> createChat(Chat chat) async {
    await _firestore.collection('chats').doc(chat.chatId).set(chat.toMap());
  }

  // Fetch all chats for a user
  Stream<List<Chat>> fetchUserChats(String userId) {
    return _firestore
        .collection('messages')
        .where('userIds', arrayContains: userId) // Get chats involving the user
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      return Chat(
        chatId: doc.id,
        userIds: List<String>.from(data['userIds']),
        lastMessage: data['lastMessage'] ?? '',
        lastMessageTimestamp: (data['lastMessageTimestamp'] as Timestamp).toDate(),
      );
    }).toList());
  }

}
