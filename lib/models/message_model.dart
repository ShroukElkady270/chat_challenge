import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String recipientId;
  final String text;
  final DateTime timestamp;
  final String avatarUrl;

  Message({
    required this.senderId,
    required this.recipientId,
    required this.text,
    required this.timestamp,
    required this.avatarUrl,
  });

  // Convert a Firestore document to a Message object
  factory Message.fromFirestore(Map<String, dynamic> data) {
    return Message(
      senderId: data['senderId'],
      recipientId: data['recipientId'],
      text: data['text'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      avatarUrl: data['avatarUrl'] ?? '',
    );
  }

  // Convert a Message object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'recipientId': recipientId,
      'text': text,
      'timestamp': timestamp,
      'avatarUrl': avatarUrl,
    };
  }

}
