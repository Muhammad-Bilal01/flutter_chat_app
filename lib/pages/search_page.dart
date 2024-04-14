import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  TextEditingController _searchController = TextEditingController();

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
                  .snapshots(),

              // .where('email', isNotEqualTo: widget.userModel.email)
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
                        onTap: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) {
                              return const ChatRoomPage();
                            },
                          ));
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
