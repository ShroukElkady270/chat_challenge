import 'package:educatly_challenge/auth/cubit/auth_cubit.dart';
import 'package:educatly_challenge/models/chats_model.dart';
import 'package:educatly_challenge/user/screen/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_screen.dart';
import '../services/chat_service.dart';

class ChatsScreen extends StatefulWidget {
  final String userId;

  const ChatsScreen({super.key, required this.userId});

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _chats = [];

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  void _fetchChats() {
    _chatService.fetchAllChats(widget.userId).listen((chats) {
      setState(() {
        _chats = chats;
      });
    });
  }

  void _openChat(String chatId) {
    // Navigate to the chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          userId: widget.userId,
          recipientId: '',
          recipientEmail: 'Unknown User',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(widget.userId, context),
          ),
        ],
      ),
      body: StreamBuilder<List<Chat>>(
        stream: ChatService().fetchUserChats(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No chats available. Start chatting',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 13.0),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UsersScreen(userId: widget.userId,)
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.add,
                      size: 30.0,
                    ),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                title: Text(chat.lastMessage),
                subtitle: Text(chat.lastMessageTimestamp.toString()),
                onTap: () {
                  _openChat(chat.chatId);
                },
              );
            },
          );
        },
      ),
    );
  }
}
