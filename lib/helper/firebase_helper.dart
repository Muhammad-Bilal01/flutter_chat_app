import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/models/user_model.dart';

class FirebaseHelper {
  static Future<UserModel?> getUserModelById(String uid) async {
    UserModel? usermodel;

    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (snapshot != null) {
      usermodel = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
    }

    return usermodel;
  }
}
