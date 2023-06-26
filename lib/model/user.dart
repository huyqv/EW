class Account {

  String displayPhoto = '';
  String displayName = '';
  String jwt = '';
  String phone = '';
  String uid = '';
  String appToken = '';
  String doorToken = '';

  Account.fromMap(Map<String, dynamic> map) {
    displayName = map['displayName'];
    displayPhoto = map['displayPhoto'];
    jwt = map['jwt'];
    phone = map['phone'];
    uid = map['uid'];
    appToken = map['AppFbToken'];
    doorToken = map['doorFbToken'];
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'displayPhoto': displayPhoto,
        'jwt': jwt,
        'phone': phone,
        'uid': uid,
        'AppFbToken': appToken,
        'doorFbToken': doorToken,
      };

  Account({
    this.displayPhoto = '',
    this.displayName = '',
    this.jwt = '',
    this.phone = '',
    this.uid = '',
    this.appToken = '',
    this.doorToken = '',
  });

  String getPhone() {
    return phone;
  }
}
