import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final prefProvider =
    Provider<SharedPreferencesService>((ref) => throw UnimplementedError());

Future<Override> prefProviderOverride() async {
  return prefProvider.overrideWithValue(
    SharedPreferencesService(await SharedPreferences.getInstance()),
  );
}

class SharedPreferencesService {
  SharedPreferencesService(this.sharedPreferences);

  final SharedPreferences sharedPreferences;

  static const onBoardingCompleteKey = 'onBoardingComplete';

  Future<void> setOnBoardingComplete() async {
    await sharedPreferences.setBool(onBoardingCompleteKey, true);
  }

  bool isOnBoardingComplete() =>
      sharedPreferences.getBool(onBoardingCompleteKey) ?? false;
}
