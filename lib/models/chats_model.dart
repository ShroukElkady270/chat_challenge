class Chat {
  final String chatId;
  final List<String> userIds;
  final String lastMessage;
  final DateTime lastMessageTimestamp;

  Chat({
    required this.chatId,
    required this.userIds,
    required this.lastMessage,
    required this.lastMessageTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userIds': userIds,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
    };
  }
}
