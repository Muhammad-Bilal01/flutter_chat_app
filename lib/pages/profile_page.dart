import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/ui_helper.dart';
import 'package:flutter_chat_app/models/user_model.dart';
import 'package:flutter_chat_app/pages/home_page.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final UserModel usermodel;
  final User firebaseUser;
  const ProfilePage(
      {super.key, required this.usermodel, required this.firebaseUser});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? imageFile;

  final TextEditingController _nameController = TextEditingController();

// Check Values
  void checkValues() {
    String fullName = _nameController.text.toString().trim();
    if (fullName == "" || imageFile == null) {
      UiHelper.showAlertDialog(context, "Missing Fields",
          "Please Insert all Feilds and insert image");
      // print("ERROR: Please Insert all Feilds");
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    UiHelper.showLoadingDialog(context, "Uploading Image...");
    UploadTask uploadTask = FirebaseStorage.instance
        .ref('profile-pictures')
        .child(widget.usermodel!.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullName = _nameController.text.toString().trim();

    widget.usermodel!.fullName = fullName;
    widget.usermodel!.profilePic = imageUrl;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.usermodel!.uid.toString())
        .set(widget.usermodel!.toMap())
        .then((value) {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return HomePage(
              userModel: widget.usermodel, firebaseUser: widget.firebaseUser);
        },
      ));
      _nameController.clear();
      log("Data Uploaded");
    });
  }

// pickImage
  void imagePick(ImageSource source) async {
    XFile? pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      cropImage(pickedImage);
    }
  }

  // crop Image
  void cropImage(XFile file) async {
    CroppedFile? cropfile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );
    if (cropfile != null) {
      setState(() {
        imageFile = File(cropfile.path);
      });
    }
  }

  // show Image Options
  void showPhotoOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upload Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  imagePick(ImageSource.gallery);
                },
                leading: const Icon(Icons.photo),
                title: const Text("Select from Gallery"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  imagePick(ImageSource.camera);
                },
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  showPhotoOptions(context);
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      (imageFile != null) ? FileImage(imageFile!) : null,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: (imageFile == null)
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  hintText: "Enter Full Name",
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    checkValues();
                  },
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
