import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/ui_helper.dart';
import 'package:flutter_chat_app/models/user_model.dart';
import 'package:flutter_chat_app/pages/home_page.dart';
import 'package:flutter_chat_app/pages/signup_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passcontroller = TextEditingController();

// checkValues
  void checkValues(BuildContext context) {
    String email = _emailcontroller.text.toString().trim();
    String password = _passcontroller.text.toString().trim();

    if (email == '' || password == "") {
      UiHelper.showAlertDialog(
          context, "Invalid Data", "Please enter all the fields");
      //  print("ERROR: Please enter all the fields");
    } else if (!email.contains('@')) {
      UiHelper.showAlertDialog(
          context, "Invalid Data", "Please enter valid email");
      // print("ERROR: Please enter valid email");
    } else {
      login(email, password, context);
    }
  }

// Login
  void login(String email, String password, BuildContext context) async {
    UserCredential? credential;
    UiHelper.showLoadingDialog(context, "Loading...");

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (exc) {
      Navigator.pop(context);
      UiHelper.showAlertDialog(
          context, "Error Occured", exc.message.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userData =
          UserModel.fromMap(snapshot.data() as Map<String, dynamic>);

      // TODO: GO TO Home Page
      //  print("SUCCESS: Login");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomePage(userModel: userData, firebaseUser: credential!.user!),
          ));

      // clear feilds
      _emailcontroller.clear();
      _passcontroller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  Text(
                    "ChatApp",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailcontroller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      hintText: "Enter Email",
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passcontroller,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      hintText: "Enter Password",
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white),
                      onPressed: () {
                        checkValues(context);
                      },
                      child: const Text("Login"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account?"),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupPage(),
                    ));
              },
              child: const Text("Signup"),
            ),
          ],
        ),
      ),
    );
  }
}
