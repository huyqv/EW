import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sample/data/firebase.dart';
import 'package:sample/model/user.dart';
import 'package:sample/ui/pages/auth/auth_page.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/pages/home/home_page.dart';
import 'package:sample/ui/pages/splash_page.dart';
import 'package:sample/ui/res/color.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'data/pref.dart';

PermissionStatus? camPermission;

class ImageCached extends ImageCache {
  @override
  void clear() {
    super.clear();
  }
}

class CustomWidgetsBinding extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() => ImageCached();
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await FirebaseUtil.init();
  runApp(ProviderScope(
    overrides: [
      await prefProviderOverride(),
    ],
    child: App(),
  ));
}

class App extends BaseStatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends BaseState<App> {
  late Pref _preferencesService;
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      DefaultCacheManager manager = new DefaultCacheManager();
      await manager.emptyCache();
    });
    Future.delayed(Duration(seconds: 3), () {
      FlutterNativeSplash.remove();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _preferencesService = ref.read(prefProvider);
    Account? _user = _preferencesService.getUser();
    bool _hasFirstRun = _preferencesService.isOnBoardingComplete();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: ColorRes.white,
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        buttonTheme: ButtonThemeData(
          buttonColor: ColorRes.primary,
          minWidth: 90,
          height: 56,
          textTheme: ButtonTextTheme.normal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                textStyle: MaterialStateProperty.all<TextStyle>(
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                foregroundColor:
                    MaterialStateProperty.all<Color>(ColorRes.primary),
                backgroundColor:
                    MaterialStateProperty.all<Color>(ColorRes.primary),
                shadowColor: MaterialStateProperty.all<Color>(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))))),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: ColorRes.primary,
          ),
          textStyle: GoogleFonts.mulish(
            textStyle: const TextStyle(
              color: ColorRes.primary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        )),
        appBarTheme: AppBarTheme(
          backgroundColor: ColorRes.white,
          systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
        ),
      ),
      themeMode: ThemeMode.dark,
      home: _hasFirstRun && _user != null
          ? const HomePage()
          : _hasFirstRun
              ? const AuthPage()
              : SplashPage(),
    );
  }
}

void applyAppTheme() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: ColorRes.statusBarColor,
    statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
    statusBarBrightness: Brightness.dark, // For iOS (dark icons)
  ));
}
