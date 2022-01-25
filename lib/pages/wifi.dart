import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/utils/base_state.dart';
import 'package:sample/widgets/ui.dart';

final wifiProvider = Provider((ref) => false);

class WifiPage2 extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wifiOn = ref.watch(wifiProvider);
    return defaultPageLayout(
      child: Column(
        children: [
          CupertinoSwitch(
            value: wifiOn,
            onChanged: (value) {},
          )
        ],
      ),
    );
  }
}

class WifiPage extends StatefulWidget {
  WifiPage({Key? key}) : super(key: key);

  @override
  State<WifiPage> createState() {
    return _WifiPageState();
  }
}

class _WifiPageState extends BaseState<WifiPage> {
  bool _switchWifi = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi) {
        _switchWifi = true;
      } else {
        _switchWifi = false;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void initConnectivity() async {
    try {
      ConnectivityResult result = await Connectivity().checkConnectivity();
    } on PlatformException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return defaultPageLayout(
      child: Column(
        children: [
          CupertinoSwitch(
            value: _switchWifi,
            onChanged: (value) {
              setState(() {
                _switchWifi = value;
              });
            },
          )
        ],
      ),
    );
  }
}
