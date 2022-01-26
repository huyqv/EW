import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/utils/color_res.dart';
import 'package:sample/widgets/ui.dart';

import 'data/pref.dart';
import 'pages/menu_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(
    overrides: [
      await prefProviderOverride(),
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    applyAppTheme();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: ColorRes.white,
      ),
      home: MenuPage(),
    );
  }
}
