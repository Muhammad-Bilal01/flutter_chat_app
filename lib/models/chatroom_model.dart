class ChatRoomModel {
  String? chatRoomId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  DateTime? updatedOn;
  List<dynamic>? users;

  ChatRoomModel({
    this.chatRoomId,
    this.participants,
    this.lastMessage,
    this.updatedOn,
    this.users,
  });

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map['chatRoomId'];
    participants = map['participants'];
    lastMessage = map['lastMessage'];
    updatedOn = map['updatedOn'].toDate();
    users = map['users'];
  }

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'participants': participants,
      'lastMessage': lastMessage,
      'updatedOn': updatedOn,
      'users': users,
    };
  }
}
