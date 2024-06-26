import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/ui_helper.dart';
import 'package:flutter_chat_app/models/user_model.dart';
import 'package:flutter_chat_app/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passcontroller = TextEditingController();
  TextEditingController _cPasscontroller = TextEditingController();

// checkValues
  void checkValues(BuildContext context) {
    String email = _emailcontroller.text.toString().trim();
    String password = _passcontroller.text.toString().trim();
    String cPassword = _cPasscontroller.text.toString().trim();

    if (email == '' || password == "" || cPassword == '') {
      UiHelper.showAlertDialog(
          context, "Missing Fields", "Please Insert all Feilds");
      // print("ERROR: Please enter all the fields");
    } else if (!email.contains('@')) {
      UiHelper.showAlertDialog(
          context, "Invalid Email", "Please Enter correct email");
      //  print("ERROR: Please enter valid email");
    } else if (password != cPassword) {
      UiHelper.showAlertDialog(
          context, "Password Mismatch", "Please enter same password");
      print("ERROR: Password not match");
    } else {
      signup(email, password, context);
    }
  }

// Signup
  void signup(String email, String password, BuildContext context) async {
    UserCredential? credential;
    UiHelper.showLoadingDialog(context, "Loading...");

    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (exc) {
      Navigator.pop(context);
      UiHelper.showAlertDialog(
          context, "Error Occured", exc.message.toString());
      // print(exc.code.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(email: email, uid: uid, fullName: "", profilePic: "");
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        _emailcontroller.clear();
        _passcontroller.clear();
        _cPasscontroller.clear();
        print("New User Created!");
        //  GO to Profile Page
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                usermodel: newUser,
                firebaseUser: credential!.user!,
              ),
            ));
      });
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
                  TextFormField(
                    controller: _cPasscontroller,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "Confirm Password",
                      hintText: "Enter Confirm Password",
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
                      child: const Text("Signup"),
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
            const Text("Already have an account?"),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
