import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_page.dart';

final wifiProvider = StateProvider((ref) => false);

class WifiPage extends BasePage {
  WifiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// StreamSubscription<ConnectivityResult>
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi) {
        ref.read(wifiProvider.state).state = true;
      } else {
        ref.read(wifiProvider.state).state = false;
      }
    });
    return defaultScaffold(
      child: Column(
        children: [
          CupertinoSwitch(
            value: ref.watch(wifiProvider),
            onChanged: (value) {},
          )
        ],
      ),
    );
  }
}

class WifiVM {}
