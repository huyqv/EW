import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/ui/pages/door_select_wifi_page.dart';
import 'package:sample/ui/pages/wifi_page.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/wifi_vm.dart';
import 'package:sample/ui/widgets/app_bar.dart';
import 'package:sample/ui/widgets/button.dart';
import 'package:sample/ui/widgets/layout.dart';

import 'base_page.dart';

//ignore: must_be_immutable
class DoorTutorialPage extends BaseStatefulWidget {
  const DoorTutorialPage({Key? key}) : super(key: key);

  @override
  _DoorTutorialPageState createState() => _DoorTutorialPageState();
}

class _DoorTutorialPageState extends BaseState<DoorTutorialPage> {
  late WifiVM wifiVM;

  @override
  Widget build(BuildContext context) {
    wifiVM = ref.watch(wifiProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: widgetAppBar(
        context: context,
        centerWidget: logoDark(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 24,
              ),
              Text(
                "Kết nối thiết bị",
                style: TextStyles.text24Bold(context),
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text(
                  "Di chuyển đến gần cửa và kết nối ứng dụng \nD Vision với “Smart Door”",
                  style: TextStyles.text14(context)
                      ?.copyWith(color: ColorRes.middleGray),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 48,
              ),
              Image.asset(
                ImageName.tutorialConnectSmartDoor,
                height: 205,
                width: MediaQuery.of(context).size.width,
              )
            ],
          ),
          Column(
            children: [
              ButtonView(
                  text: "Đến cài đặt Wifi",
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  onTap: () {
                    AppSettings.openWIFISettings(asAnotherTask: false);
                  }),
              const SizedBox(
                height: 24,
              ),
              ButtonView(
                  text: "Tiếp tục",
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  borderColor: ColorRes.primary,
                  backgroundColor: ColorRes.white,
                  textColor: ColorRes.primary,
                  onTap: () {
                    push(context, const DoorSelectWifiPage());
                  }),
              sloganBottomWidget(context),
            ],
          )
        ],
      ),
    );
  }
}

