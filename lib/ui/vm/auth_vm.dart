import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sample/data/firebase.dart';
import 'package:sample/model/user.dart';
import 'package:sample/ui/vm/base_vm.dart';

final authProvider = ChangeNotifierProvider<AuthVM>((ref) {
  return AuthVM();
});

class AuthVM extends BaseVM {
  String phone = '';
  String pin = '';
  String jwt = '';
  bool phoneValidate = false;
  bool enableInputConfirmPass = false;
  bool pinConfirmIncorrect = false;
  bool loginError = false;

  Future<void> authPhone(String phone) async {
    enableInputConfirmPass = false;
    pinConfirmIncorrect = false;
    loginError = false;
    pin = '';
    this.phone = phone;
    var response = await postRequest(
      endpoint: 'user/reg/phone',
      body: {
        'reqId': phone,
        'cid': phone,
        'langCode': 'vi',
        'data': {
          'phone': phone,
        },
      },
    );
    String? jwt = response?['data']["jwt"];
    if (jwt != null && jwt.isNotEmpty) {
      this.jwt = jwt;
    }
  }

  Future<void> verifyOTP(String otp, void Function(bool isSuccess, bool isSignUp) onResult) async {
    var response = await postRequest(
      endpoint: 'user/reg/verifyOTP',
      body: {
        'reqId': phone,
        'cid': phone,
        'langCode': 'vi',
        'data': {
          'otp': otp,
          'jwt': this.jwt,
        },
      },
    );
    String? jwt = response?["data"]['jwt'];
    if (jwt != null && jwt.isNotEmpty) {
      this.jwt = jwt;
      Map<String, dynamic> decodedToken = JwtDecoder.decode(jwt);
      bool verifySuccess = decodedToken["Data"]["otp"] == "ok";
      String step = decodedToken["Data"]["step"];
      onResult(verifySuccess, step == "signup");
    } else {
      onResult(false, false);
    }
  }

  Future<void> createPin(String pin, void Function(Account? user) onResult) async {
    final pinEncode = utf8.encode(pin);
    final digest = sha256.convert(pinEncode);
    final response = await postRequest(
      endpoint: 'user/reg/pin',
      body: {
        'reqId': phone,
        'cid': phone,
        'langCode': 'vi',
        'data': {
          'pin': digest.toString(),
          'jwt': jwt,
        },
      },
    );
    onLoginResult(response, onResult);
  }

  Future<void> validatePin(String pin, void Function(Account? user) onResult, VoidCallback onConfirmPinError) async {
    if(pin == this.pin) {
      pinConfirmIncorrect = false;
      await createPin(pin, onResult);
    } else {
      pinConfirmIncorrect = true;
      onConfirmPinError();
      startPutConfirm("");
    }
  }

  Future<void> login(String pin, void Function(Account? user) onResult) async {
    loginError = false;
    var pinEncode = utf8.encode(pin);
    var digest = sha256.convert(pinEncode);
    dynamic response = await postRequest(
      endpoint: 'user/login',
      body: {
        'reqId': phone,
        'cid': phone,
        'langCode': 'vi',
        'data': {
          'pin': digest.toString(),
          'jwt': jwt,
        },
      },
    );
    onLoginResult(response, onResult);
  }

  void onChangePhone(String phone, bool isValidate) {
    phoneValidate = phone.length == 10 && isValidate;
    notifyListeners();
  }

  void startPutConfirm(String pin) {
    enableInputConfirmPass = pin.isNotEmpty;
    this.pin = pin;
    notifyListeners();
  }

  onLoginResult(dynamic response, void Function(Account? user) onResult) async {
    try {
      String? jwt = response?["result"]['jwt'];
      String? appToken = response?["result"]['AppFbToken'];
      String? doorToken = response?["result"]['doorFbToken'];
      if (jwt == null || appToken == null) {
        onLoginFailure(onResult);
        return;
      }
      UserCredential credential = await FirebaseUtil.loginWithToken(appToken);
      String userId = credential.user!.uid;
      onResult(Account(
        phone: phone,
        jwt: jwt,
        uid: userId,
        appToken: appToken,
        doorToken: doorToken!,
      ));
      notifyListeners();
    } catch (e) {
      onLoginFailure(onResult);
    }
  }

  onLoginFailure(void Function(Account? user) onResult) {
    loginError = true;
    onResult(null);
    notifyListeners();
  }

  Future<void> logOut() async {
    return await FirebaseUtil.logOut();
  }
}
