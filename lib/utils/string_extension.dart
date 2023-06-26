
extension Validate on String? {
  bool isPhone() {
    if(this == null) {
      return false;
    }
    // String pattern = r'^(?:[+0])?[0-9]{10}$';
    String pattern = r'^\+?0[1-9]{1}[0-9]{8}$';
    RegExp regex = RegExp(pattern);
    if (regex.hasMatch(this!)) {
      return true;
    } else {
      return false;
    }
  }

  bool? validatePhone() {
    if(this == null) {
      return false;
    }
    String pattern = r'^(?:[+0][0-9])?[0-9]{10}$';
    RegExp regex = RegExp(pattern);
    if (regex.hasMatch(this!)) {
      return true;
    } else {
      return false;
    }
  }

  bool? validatePassword() {
    if(this == null) {
      return false;
    }
    String pattern = r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9])(?=.{8,})';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(this!)) {
      return false;
    } else {
      return true;
    }
  }

  bool validateName() {
    if(this == null) {
      return false;
    }
    if (this!.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}