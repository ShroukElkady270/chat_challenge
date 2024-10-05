import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educatly_challenge/auth/presentation/login_screen.dart';
import 'package:educatly_challenge/core/secure_storage_service.dart';
import 'package:educatly_challenge/chat/presentation/chats_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class AuthCubit extends Cubit<User?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SecureStorageService _storageService =
      SecureStorageService(); // Use the secure storage service

  AuthCubit() : super(null) {
    _init();
  }

  // Initialize user state asynchronously
  void _init() async {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        // Store the user token securely when user is authenticated
        String? idToken = await user.getIdToken();
        await _storageService.saveToken('authToken', idToken!);
      } else {
        // Clear the token when user logs out
        await _storageService.deleteToken('authToken');
      }
      emit(user);
    });
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      String? idToken = await userCredential.user!.getIdToken();
      String? userId = userCredential.user!.uid;
      // Store the token securely after login
      await _storageService.saveToken('authToken', idToken!);
      await _storageService.storeUserId(userId);
      updateUserStatus(userId, true);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatsScreen(userId: userId)),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> register(
    String email,
    String password,
    XFile image,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      String? idToken = await userCredential.user!.getIdToken();
      // Store the token securely after registration
      await _storageService.saveToken('authToken', idToken!);

      User? user = userCredential.user;

      if (user != null) {
        String userId = user.uid;

        await uploadAvatar(userId, image);

        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'email': email,
          'avatarUrl': await getAvatarDownloadUrl(userId),
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatsScreen(userId: userCredential.user!.uid),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> logout(String userId, BuildContext context) async {
    await _auth.signOut();
    // Clear the stored token on logout
    await _storageService.clearAll();
    await _storageService.deleteUserId();

    updateUserStatus(userId, false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );

  }

  Future<void> uploadAvatar(String userId, XFile image) async {
    try {
      File file = File(image.path);
      Reference storageReference =
          FirebaseStorage.instance.ref().child('avatars/$userId/avatar.jpg');

      UploadTask uploadTask = storageReference.putFile(file);

      await uploadTask.whenComplete(() => print('Avatar upload complete'));
    } catch (e) {
      print('Error uploading avatar: $e');
    }
  }

  Future<String> getAvatarDownloadUrl(String userId) async {
    try {
      Reference storageReference =
          FirebaseStorage.instance.ref().child('avatars/$userId/avatar.jpg');

      return await storageReference.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting avatar download URL: $e');
      }
      return '';
    }
  }

  void updateUserStatus(String userId, bool isOnline) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isOnline': isOnline,
    });
  }
}
