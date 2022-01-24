import 'package:flutter/services.dart';

class Native {

  Native._internal();

  static const MethodChannel channel = MethodChannel('com.example.sample/flutter');

  static Future<void> showToast(String message) async {
    await channel.invokeMethod('showToast', <String, String>{
      'message': message
    });
  }

}
