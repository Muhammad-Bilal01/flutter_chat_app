class UserModel {
  String? uid;
  String? fullName;
  String? email;
  String? profilePic;

  UserModel({this.uid, this.fullName, this.email, this.profilePic});

  // from consructor
  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map['uid'];
    fullName = map['fullName'];
    email = map['email'];
    profilePic = map['profilePic'];
  }

  // to method
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'profilePic': profilePic
    };
  }
}
