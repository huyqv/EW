class Member {
  String userId = '';
  String userName = '';
  String userPhoto = '';
  int lastUpdate = 0;
  bool isBlocked = false;
  bool isSelected = false;

  Member({
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.lastUpdate,
    required this.isBlocked,
  });

  Member.fromJson(Map<String, dynamic> json) {
    userId = json["userId"];
    userName = json["userName"];
    userPhoto = json["userPhoto"];
    lastUpdate = json["lastUpdate"];
    isBlocked = json["isBlocked"];
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "userName": userName,
      "userPhoto": userPhoto,
      "lastUpdate" : lastUpdate,
      "isBlocked" : isBlocked
    };
  }
}
