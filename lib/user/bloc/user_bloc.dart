import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educatly_challenge/user/bloc/user_event.dart';
import 'package:educatly_challenge/user/bloc/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<FetchUsers>((event, emit) async {
      emit(UserLoading());
      try {
        // Fetch users from Firestore
        List<Map<String, dynamic>> users = await fetchUsersFromFirestore();
        emit(UserLoaded(users, userIds));
      } catch (e) {
        emit(UserError("Failed to fetch users: $e"));
      }
    });
  }
  List<String> userIds = [];

  // Fetch users from Firestore
  Future<List<Map<String, dynamic>>> fetchUsersFromFirestore() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
    for (var doc in snapshot.docs) {
      userIds.add(doc.id); // Get user ID
    }
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}