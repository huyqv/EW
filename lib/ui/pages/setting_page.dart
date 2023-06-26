import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/data/pref.dart';
import 'package:sample/ui/pages/auth/auth_page.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/auth_vm.dart';
import 'package:sample/ui/widgets/app_bar.dart';
import 'package:sample/ui/widgets/layout.dart';

class SettingPage extends BaseStatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends BaseState<SettingPage> {
  late AuthVM _authVM;
  late Pref _sharedPreferences;

  @override
  Widget build(BuildContext context) {
    _authVM = ref.read(authProvider);
    _sharedPreferences = ref.read(prefProvider);
    return Scaffold(
        appBar: widgetAppBar(context: context, centerWidget: euroLogoWidget()),
        body: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_bodyWidget(context, ref), _bottomWidget(context, ref)],
          ),
        ));
  }

  Widget _bodyWidget(BuildContext context, WidgetRef ref) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 50),
        child: Text(
          "Cài đặt",
          style: TextStyles.text24Bold(context),
        ),
      ),
      commonItemWidget(
          context: context,
          title: "Ứng dụng v1.0.0",
          prefixIcon: ImageName.iphone,
          backgroundColor: ColorRes.lightGray,
          onTap: () {}),
      commonItemWidget(
          context: context,
          title: "Firmware v1.2 (phiên bản mới nhất)",
          prefixIcon: ImageName.firmWare,
          backgroundColor: ColorRes.lightGray,
          margin: const EdgeInsets.only(top: 16),
          onTap: () {}),
    ]);
  }

  Widget _bottomWidget(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        GestureDetector(
            onTap: () async {
              await _logOut();
              pushAndRemove(context, const AuthPage());
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Đăng xuất",
                style: TextStyles.text16Bold(context)
                    ?.copyWith(color: ColorRes.red),
              ),
            )),
        sloganBottomWidget(context),
      ],
    );
  }

  Future<void> _logOut() async{
    await _authVM.logOut();
    await _sharedPreferences.setUser(null);
  }
}
