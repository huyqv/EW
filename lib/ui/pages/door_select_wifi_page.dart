import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sample/data/pref.dart';
import 'package:sample/model/wifi.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/pages/home/home_page.dart';
import 'package:sample/ui/pages/wifi_page.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/dimen.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/door_vm.dart';
import 'package:sample/ui/vm/wifi_vm.dart';
import 'package:sample/ui/widgets/app_bar.dart';
import 'package:sample/ui/widgets/button.dart';
import 'package:sample/ui/widgets/input_text.dart';
import 'package:sample/ui/widgets/layout.dart';

import '../../utils/permission.dart';

var showPassProvider = StateProvider((ref) => true);

class DoorSelectWifiPage extends BaseStatefulWidget {
  const DoorSelectWifiPage({Key? key}) : super(key: key);

  @override
  _DoorSelectWifiPageState createState() => _DoorSelectWifiPageState();
}

class _DoorSelectWifiPageState extends BaseState<DoorSelectWifiPage> {
  late WifiVM wifiVM;
  final TextEditingController _wifiNameController = TextEditingController();
  final TextEditingController _wifiPassWordController = TextEditingController();
  final TextEditingController _ipAddressController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  late Pref _preferencesService;
  final FocusNode _wifiFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _ipAddressFocusNode = FocusNode();

  String? _validateSsid(String? ssid) {
    if (ssid != null && ssid.isNotEmpty && ssid != "unknown") {
      return null;
    } else {
      return "SSID không hợp lệ";
    }
  }

  String? _validatePassword(String? password) {
    if (password != null && password.isNotEmpty && password.length >= 8) {
      return null;
    } else {
      return "Password không hợp lệ";
    }
  }

  void _onShowPassClick() {
    var provider = ref.read(showPassProvider.state);
    provider.state = !provider.state;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    wifiVM = ref.read(wifiProvider);
    wifiVM.stopScan();
    var doorVM = ref.read(doorProvider);
    doorVM.isLoading = false;
    doorVM.errorMessage = '';
    _preferencesService = ref.read(prefProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widgetAppBar(
        context: context,
        centerWidget: logoDark(),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: height(context) - 100,
          width: width(context),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _bodyWidget(context, ref),
                _bottomWidget(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bodyWidget(BuildContext context, WidgetRef ref) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(
            height: 24,
          ),
          Text(
            "Chọn Wi-Fi",
            style: TextStyles.text24Bold(context),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            "Kết nối “Smart Door” với mạng Wi-Fi \nđể thiết bị sẵn sàng hoạt động",
            style: TextStyles.text14(context)
                ?.copyWith(color: ColorRes.middleGray),
            textAlign: TextAlign.center,
          ),
          Platform.isAndroid
              ? InputTextOutline(
            padding: const EdgeInsets.only(top: 24, bottom: 16),
                  hintText: "Nhập tên Wi-Fi",
                  controller: _wifiNameController,
                  focusBorderColor: ColorRes.primary,
                  unFocusBorderColor: ColorRes.middleGray,
                  prefixIcon: ImageName.wifi,
                  suffixIcon: ImageName.dropDown,
                  focusNode: _wifiFocusNode,
                  onSuffixIconClick: () {
                    _showWifiBottomSheet(context);
                  },
                  validator: _validateSsid,
                  onChange: (text) {},
                )
              : InputTextOutline(
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  hintText: "Nhập tên Wi-Fi",
                  controller: _wifiNameController,
                  focusBorderColor: ColorRes.primary,
                  unFocusBorderColor: ColorRes.middleGray,
                  prefixIcon: ImageName.wifi,
                  focusNode: _wifiFocusNode,
                  validator: _validateSsid,
                  onChange: (text) {},
                ),
          InputTextOutline(
            hintText: "Nhập mật khẩu Wi-Fi",
            controller: _wifiPassWordController,
            focusBorderColor: ColorRes.primary,
            unFocusBorderColor: ColorRes.middleGray,
            focusNode: _passwordFocusNode,
            obscureText: ref.watch(showPassProvider.state).state,
            prefixIcon: ImageName.lock,
            suffixIcon: ref.watch(showPassProvider.state).state
                ? ImageName.eyeHide
                : ImageName.eye,
            onSuffixIconClick: _onShowPassClick,
            validator: _validatePassword,
            onChange: (text) {},
          ),
          padding(top: Dimen.padding32),
          Consumer(builder: (context, ref, _) {
            var provider = ref.watch(doorProvider);
            return Text(
              provider.errorMessage,
              style: TextStyles.text10(context)!.copyWith(color: ColorRes.red),
            );
          }),
          padding(
            horizontal: Dimen.padding32,
            top: Dimen.padding48,
            child: RichText(
              text: TextSpan(
                  text: "* ",
                  style:
                      TextStyles.text14(context)?.copyWith(color: Colors.red),
                  children: [
                    TextSpan(
                        text:
                            "Lưu ý: Vui lòng nhập chính xác tên Wi-Fi hiện có và đang hoạt động tại địa điểm đặt thiết bị",
                        style: TextStyles.text12Gray(context))
                  ]),
              textAlign: TextAlign.center,
            ),
          ),
          Consumer(builder: (context, ref, _) {
            var provider = ref.watch(doorProvider);
            return Text(
              provider.doorAddress,
              style: TextStyles.text10(context),
            );
          }),
        ],
      ),
    );
  }

  Widget _bottomWidget(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          var provider = ref.watch(doorProvider);
          return provider.isLoading
              ? const CircularProgressIndicator(
                  color: ColorRes.primary,
                )
              : ButtonView(
                  text: "Kết nối",
                  onTap: () async {
                    //SocketException: Software caused connection abort
                    // (OS Error: Software caused connection abort, errno = 103), address = 192.168.4
                    if (_formKey.currentState!.validate()) {
                      await ref.read(doorProvider).connectDoor(
                          ssid: _wifiNameController.text,
                          password: _wifiPassWordController.text,
                          user: _preferencesService.getUser()!,
                          doorName: provider.doorName,
                          onCompleted: (bool isSuccess) {
                            toastActionDoorSuccess(context, "Thêm cửa thành công", "${provider.doorName} đã được thêm ");
                            pushAndRemove(context, const HomePage());
                          });
                    }
                  });
        },
      ),
    );
  }

  Future<void> _showWifiBottomSheet(BuildContext context) async {
    await requestPermission(Permission.location, onGranted: () async {
      wifiVM.scan();
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40))),
        builder: (context) => SizedBox(
          height: MediaQuery.of(context).size.height - 110,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 45,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.transparent, width: 0.1),
                  color: ColorRes.gray,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Chọn Wi-Fi",
                style: TextStyles.text24Bold(context),
              ),
              const SizedBox(
                height: 8,
              ),
              Consumer(builder: (context, ref, child) {
                var provider = ref.watch(wifiProvider);
                if (provider.wifiList.isEmpty) {
                  return padding(
                    top: Dimen.padding80,
                    child: const CircularProgressIndicator(
                      color: ColorRes.primary,
                    ),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.wifiList.length,
                    itemBuilder: (context, index) {
                      return _wifiItemWidget(wifiVM.wifiList[index]);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ).whenComplete(() {
        wifiVM.stopScan();
        _wifiNameController.text = wifiVM.currentWifiSelected?.ssid ?? "";
      });
    }, onDenied: () {
      alertMessage(context, message: "Location permission require to scan");
    });
  }

  Widget _wifiItemWidget(Wifi wifi) {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 24, right: 24),
      decoration: BoxDecoration(
          color: ColorRes.lightGray,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.transparent)),
      child: RadioListTile<Wifi>(
        value: wifi,
        groupValue: wifiVM.currentWifiSelected,
        controlAffinity: ListTileControlAffinity.trailing,
        activeColor: ColorRes.primary,
        title: Row(
          children: [
            Image.asset(
              ImageName.wifi,
              width: 24,
              height: 24,
            ),
            const SizedBox(
              width: 16,
            ),
            Text(wifi.ssid ?? 'unknown ssid'),
          ],
        ),
        toggleable: false,
        onChanged: (Wifi? value) {
          wifiVM.onWifiChange(value);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
