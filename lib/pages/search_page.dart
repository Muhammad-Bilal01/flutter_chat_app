import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/utils.dart';
import 'package:flutter_chat_app/models/chatroom_model.dart';
import 'package:flutter_chat_app/models/user_model.dart';
import 'package:flutter_chat_app/pages/chat_room_page.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  // get Chatroom
  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel chatroom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('participants.${widget.userModel.uid}', isEqualTo: true)
        .where('participants.${targetUser.uid}', isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChat =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      log("Existing Chatroom!");
      chatroom = existingChat;
    } else {
      ChatRoomModel newChatroom = ChatRoomModel(
        chatRoomId: uuid.v1(),
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
        lastMessage: "",
        updatedOn: DateTime.now(),
        users: [
          widget.userModel.uid.toString(),
          targetUser.uid.toString(),
        ],
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatRoomId)
          .set(newChatroom.toMap());

      log("New Chatroom Created!");
      chatroom = newChatroom;
    }
    return chatroom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Search User"),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(hintText: "Search Email..."),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white),
                onPressed: () {
                  setState(() {});
                },
                child: const Text("Search"),
              ),
            ),
            const SizedBox(height: 20),
            // Stream Builder
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('email',
                      isEqualTo: _searchController.text.toString().trim())
                  .where('email', isNotEqualTo: widget.userModel.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot querySnapshot =
                        snapshot.data as QuerySnapshot;
                    if (querySnapshot.docs.isNotEmpty) {
                      Map<String, dynamic> userMap =
                          querySnapshot.docs[0].data() as Map<String, dynamic>;

                      UserModel searchedUser = UserModel.fromMap(userMap);
                      return ListTile(
                        onTap: () async {
                          ChatRoomModel? chatroomModel =
                              await getChatRoomModel(searchedUser);

                          if (chatroomModel != null) {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(
                              builder: (context) {
                                return ChatRoomPage(
                                  currentUser: widget.userModel,
                                  targetUser: searchedUser,
                                  firebaseUser: widget.firebaseUser,
                                  chatroomModel: chatroomModel,
                                );
                              },
                            ));
                          }
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[500],
                          backgroundImage:
                              NetworkImage(searchedUser.profilePic!),
                        ),
                        title: Text(searchedUser.fullName!),
                        subtitle: Text(searchedUser.email!),
                        trailing:
                            const Icon(Icons.keyboard_arrow_right_outlined),
                      );
                    } else {
                      return const Center(
                        child: Text("No Data Found!"),
                      );
                    }
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text("An Error Occured!"),
                    );
                  } else {
                    return const Center(
                      child: Text("No Data Found!"),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ),
      )),
    );
  }
}
