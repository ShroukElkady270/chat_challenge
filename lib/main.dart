import 'package:educatly_challenge/auth/cubit/auth_cubit.dart';
import 'package:educatly_challenge/auth/presentation/login_screen.dart';
import 'package:educatly_challenge/core/secure_storage_service.dart';
import 'package:educatly_challenge/chat/presentation/chats_screen.dart';
import 'package:educatly_challenge/user/bloc/user_bloc.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initializeFCM(); // Initialize push notifications

  final storageService = SecureStorageService();
  final storedToken = await storageService.getToken('authToken');
  final userId = await storageService.getUserId();

  // Activate Firebase App Check with Play Integrity (Android)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  runApp(MyApp(
    storedToken: storedToken,
    userId: userId,
  ));
}

class MyApp extends StatelessWidget {
  final String? storedToken;
  final String? userId;

  const MyApp({super.key, this.storedToken, this.userId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => UserBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chat App',
        theme: ThemeData.dark(),
        home: storedToken != null
            ? ChatsScreen(
                userId: userId ?? '',
              )
            : const LoginScreen(),
      ),
    );
  }
}
