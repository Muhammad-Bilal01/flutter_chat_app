import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/firebase_helper.dart';
import 'package:flutter_chat_app/models/chatroom_model.dart';
import 'package:flutter_chat_app/models/user_model.dart';
import 'package:flutter_chat_app/pages/chat_room_page.dart';
import 'package:flutter_chat_app/pages/login_page.dart';
import 'package:flutter_chat_app/pages/search_page.dart';

class HomePage extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Chat App"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chatrooms')
                .where('users', arrayContains: userModel.uid)
                .orderBy('updatedOn')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: dataSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoom = ChatRoomModel.fromMap(
                          dataSnapshot.docs[index].data()
                              as Map<String, dynamic>);

                      Map<String, dynamic> participants =
                          chatRoom.participants!;

                      List<String> participantsKeys =
                          participants.keys.toList();
                      // remove current user id
                      participantsKeys.remove(userModel.uid);

                      return FutureBuilder(
                        future: FirebaseHelper.getUserModelById(
                            participantsKeys[0]),
                        builder: (context, userData) {
                          if (userData.connectionState ==
                              ConnectionState.done) {
                            if (userData != null) {
                              UserModel targetUser = userData.data as UserModel;
                              return ListTile(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return ChatRoomPage(
                                          currentUser: userModel,
                                          targetUser: targetUser,
                                          firebaseUser: firebaseUser,
                                          chatroomModel: chatRoom);
                                    },
                                  ));
                                },
                                title: Text(targetUser.fullName!),
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(targetUser.profilePic!),
                                ),
                                subtitle: (chatRoom.lastMessage != "")
                                    ? Text(chatRoom.lastMessage!)
                                    : Text(
                                        "Say Hi to your new friends.",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      ),
                              );
                            } else {
                              return Container();
                            }
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("${snapshot.error}"),
                  );
                } else {
                  return const Center(
                    child: Text("No Chats Found!"),
                  );
                }
              } else {
                const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SearchPage(userModel: userModel, firebaseUser: firebaseUser),
            ),
          );
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
