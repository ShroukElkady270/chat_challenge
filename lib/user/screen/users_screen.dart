import 'package:educatly_challenge/auth/cubit/auth_cubit.dart';
import 'package:educatly_challenge/chat/presentation/chat_screen.dart';
import 'package:educatly_challenge/user/bloc/user_bloc.dart';
import 'package:educatly_challenge/user/bloc/user_event.dart';
import 'package:educatly_challenge/user/bloc/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    context.read<UserBloc>().add(FetchUsers());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(userId, context),
          ),
        ],
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded) {
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            userId: userId,
                            recipientId: state.usersId[index],
                            recipientEmail: user['email'] ?? 'Unknown User',
                          ),
                        ),
                      );

                    },
                    child: ListTile(
                      leading: user['avatarUrl'] != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(user['avatarUrl']),
                            )
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(user['email'] ?? 'Unknown User'),
                      subtitle: Text(
                          user['isOnline'] ?? false ? 'Online' : 'Offline',),
                    ),
                  ),
                );
              },
            );
          } else if (state is UserError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('No users found.'));
          }
        },
      ),
    );
  }
}
