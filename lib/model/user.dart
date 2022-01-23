class User {
  String displayPhoto = '';
  String displayName = '';

  User.fromMap(Map<String, dynamic> map) {
    displayName = map['displayName'];
    displayPhoto = map['displayPhoto'];
  }
}
