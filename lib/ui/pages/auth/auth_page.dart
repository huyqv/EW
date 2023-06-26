import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/data/pref.dart';
import 'package:sample/router/route_name.dart';
import 'package:sample/router/routing.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/pages/home/home_page.dart';
import 'package:sample/ui/pages/result_page.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/auth_vm.dart';
import 'package:sample/ui/widgets/button.dart';
import 'package:sample/ui/widgets/input_text.dart';
import 'package:sample/ui/widgets/pin.dart';
import 'package:sample/utils/string_extension.dart';

import 'otp_view.dart';

var pinScaleProvider = StateProvider.autoDispose((ref) => false);

class AuthPage extends BaseStatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends BaseState<AuthPage> with TickerProviderStateMixin {
  late AuthVM _authVM;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  late AnimationController _timerController;
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _pinFocusNode = FocusNode();
  late Pref _sharedPreferences;
  bool isShowOtp = false;

  Future<void> _onOtpChange(String? otp) async {
    if (otp != null && otp.length == 4) {
      FocusScope.of(context).unfocus();
      await _authVM.verifyOTP(otp, (isSuccess, isSignUp) {
        _timerController.reset();
        if (isSuccess) {
          Navigator.of(context).pop();
          if (isSignUp) {
            _showCreatePinBottomSheet(context);
          } else {
            _showPinBottomSheet(context);
          }
        } else {
          print("VerifyOtp: Fails");
        }
      });
    }
  }

  @override
  void initState() {
    _timerController =
        AnimationController(vsync: this, duration: const Duration(seconds: 90));
    super.initState();
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _authVM = ref.read(authProvider);
    _sharedPreferences = ref.read(prefProvider);
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(ImageName.backgroundRegister),
                  fit: BoxFit.cover),
              color: ColorRes.primary.withOpacity(0.5)),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 80,
                    ),
                    Image.asset(
                      ImageName.logoEuroText,
                      width: 162,
                      height: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      height: 54,
                    ),
                    Text(
                      "Nhập số điện thoại",
                      style: TextStyles.text24WhiteBold(context),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Hãy bắt đầu khám phá cùng D Vision",
                      style: TextStyles.text14(context)
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    InputTextOutline(
                      hintText: "Số điện thoại",
                      controller: _phoneController,
                      textInputType: TextInputType.phone,
                      textStyle: TextStyles.text16WhiteBold(context),
                      maxLength: 10,
                      autoFocus: true,
                      prefixIcon: ImageName.phone,
                      focusNode: _phoneFocusNode,
                      validator: (phone) {
                        if (phone.isPhone() || phone!.isEmpty) {
                          return null;
                        } else {
                          return "Số điện thoại không đúng định dạng.";
                        }
                      },
                      onChange: (text) {
                        _formKey.currentState!.validate();
                        _authVM.onChangePhone(
                            text, _formKey.currentState!.validate());
                      },
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: ButtonView(
                      onTap: () async {
                        if (_formKey.currentState!.validate() &&
                            _phoneController.text.isNotEmpty &&
                            !isShowOtp) {
                          isShowOtp = true;
                          await _authVM.authPhone(_phoneController.text);
                          _pinController.clear();
                          _showOtpBottomSheet(context);
                          isShowOtp = false;
                        }
                      },
                      backgroundColor: ColorRes.primary,
                      text: 'Tiếp theo',
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOtpBottomSheet(BuildContext context) {
    appShowBottomSheet(SizedBox(
      height: MediaQuery.of(context).size.height - 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    color: ColorRes.gray),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                "Kiểm tra tin nhắn",
                style: TextStyles.text24Bold(context),
              ),
              const SizedBox(
                height: 16,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: "Nhập mã OTP mà chúng tôi vừa gửi tới số",
                    style: TextStyles.text14Gray(context),
                    children: [
                      TextSpan(
                          text: "\nđiện thoại ",
                          style: TextStyles.text14Gray(context)),
                      TextSpan(
                          text: _phoneController.text,
                          style: TextStyles.text14Bold(context)
                              ?.copyWith(color: ColorRes.primary))
                    ]),
              ),
              OtpView(
                onChanged: _onOtpChange,
              ),
            ],
          ),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              ref.watch(authProvider);
              return _authVM.isShowProgress ? child! : const SizedBox();
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 54),
              child: CircularProgressIndicator(
                color: ColorRes.primary,
              ),
            ),
          )
        ],
      ),
    ));
  }

  void _showPinBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40))),
      builder: (context) => SizedBox(
        height: height(context) - 110,
        child: Padding(
          padding: const EdgeInsets.only(left: 52, bottom: 54, right: 52),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 45,
                    height: 4,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                            color: Colors.transparent, width: 0.1),
                        color: ColorRes.gray),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Nhập mã PIN",
                    style: TextStyles.text24Bold(context),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Nhập mã PIN để truy cập vào tài khoản",
                    style: TextStyles.text14Gray(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Pin(
                    onChanged: (pin) async {
                      if (pin?.length == 6) {
                        FocusScope.of(context).unfocus();
                        await _authVM.login(pin!, (user) {
                          if (user != null) {
                            _sharedPreferences.setUser(user);
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              pushAndRemove(context, const HomePage());
                            });
                          } else {
                            _pinController.text = "";
                          }
                        });
                      }
                    },
                    focusNode: _pinFocusNode,
                    textEditingController: _pinController,
                  )
                ],
              ),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  ref.watch(authProvider);
                  return _authVM.loginError
                      ? Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Text(
                            "Mã PIN không đúng, vui lòng thử lại.",
                            textAlign: TextAlign.center,
                            style: TextStyles.text12(context)
                                ?.copyWith(color: ColorRes.red),
                          ),
                        )
                      : _authVM.isShowProgress
                          ? const Padding(
                              padding: EdgeInsets.only(top: 54),
                              child: CircularProgressIndicator(
                                color: ColorRes.primary,
                              ),
                            )
                          : const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() => _timerController.forward());
  }

  void _showCreatePinBottomSheet(BuildContext context) {
    _authVM.startPutConfirm('');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40))),
      builder: (context) => const CreatePinView(),
    );
  }
}

class CreatePinView extends BaseStatefulWidget {
  const CreatePinView({Key? key}) : super(key: key);

  @override
  _CreatePinViewState createState() => _CreatePinViewState();
}

class _CreatePinViewState extends BaseState<CreatePinView> {
  late AuthVM _authVM;
  final TextEditingController _pinCreateController = TextEditingController();
  final TextEditingController _pinConfirmController = TextEditingController();
  final FocusNode _pinCreateFocusNode = FocusNode();
  final FocusNode _pinConfirmFocusNode = FocusNode();
  late Pref _sharedPreferences;

  @override
  void initState() {
    _authVM = ref.read(authProvider);
    _sharedPreferences = ref.read(prefProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height(context) - 110,
      child: Padding(
        padding: const EdgeInsets.only(left: 54, right: 54, bottom: 54),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: 45,
                  height: 4,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                          color: Colors.transparent, width: 0.1),
                      color: ColorRes.gray),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  ref.watch(authProvider).enableInputConfirmPass
                      ? "Xác nhận mã PIN"
                      : "Tạo mã PIN",
                  style: TextStyles.text24Bold(context),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  ref.watch(authProvider).enableInputConfirmPass
                      ? "Vui lòng nhập lại mã PIN của bạn"
                      : "Nhập 6 chữ số sẽ được sử dụng để truy cập tài khoản của bạn",
                  style: TextStyles.text14Gray(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 40,
                ),
                Consumer(builder: (context, ref, child) {
                  var _enable = ref.watch(authProvider).enableInputConfirmPass;
                  return IgnorePointer(
                    ignoring: _enable,
                    child: Pin(
                      isScale: ref.watch(pinScaleProvider.state).state,
                      onTap: () {
                        ref.read(pinScaleProvider.state).state = false;
                      },
                      onChanged: (pin) async {
                        if (pin?.length == 1) {
                          _authVM.pinConfirmIncorrect = false;
                        }
                        if (pin?.length == 6) {
                          _authVM.startPutConfirm(pin!);
                          _pinConfirmFocusNode.requestFocus();
                          ref.read(pinScaleProvider.state).state = true;
                        }
                      },
                      focusNode: _pinCreateFocusNode,
                      textEditingController: _pinCreateController,
                    ),
                  );
                }),
                Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      ref.watch(authProvider);
                      return _authVM.enableInputConfirmPass
                          ? child!
                          : const SizedBox();
                    },
                    child: Pin(
                      onTap: () {
                        ref.read(pinScaleProvider.state).state = true;
                      },
                      onChanged: (pin) async {
                        if (pin?.length == 6) {
                          FocusScope.of(context).unfocus();
                          await _authVM.validatePin(pin!, (user) {
                            if (user != null) {
                              Routing.navigate2(
                                  context,
                                  (context) => ResultPage(
                                        theme: RESULT_THEME.success,
                                        title: 'Tuyệt vời',
                                        message:
                                            'Tài khoản của bạn đã được tạo thành công. \nHãy bắt đầu trải nghiệm những tính năng \ntuyệt vời.',
                                        buttons: [
                                          ButtonView(
                                            text: 'Bắt đầu ngay',
                                            onTap: () {
                                              pushAndRemove(
                                                  context, const HomePage());
                                            },
                                          ),
                                        ],
                                      ),
                                  routeName: RouteName.result);
                              _sharedPreferences.setUser(user);
                            } else {
                              Routing.navigate2(
                                  context,
                                  (context) => ResultPage(
                                        theme: RESULT_THEME.failure,
                                        title: 'Rất tiếc',
                                        message:
                                            'Tạo tài khoản không thành công',
                                        buttons: [
                                          ButtonView(
                                            text: 'Thử lại',
                                            onTap: () {
                                              Routing.popToRoot(context);
                                            },
                                          )
                                        ],
                                      ),
                                  routeName: RouteName.result);
                            }
                          }, () {
                            _pinCreateController.text = "";
                            _pinConfirmController.text = "";
                            ref.read(pinScaleProvider.state).state = false;
                          });
                        }
                      },
                      focusNode: _pinConfirmFocusNode,
                      textEditingController: _pinConfirmController,
                    ))
              ],
            ),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                ref.watch(authProvider);
                return _authVM.isShowProgress && !_authVM.pinConfirmIncorrect
                    ? child!
                    : _authVM.pinConfirmIncorrect
                        ? Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: Text(
                              "Mã PIN nhập lại không trùng nhau, vui lòng thử lại.",
                              textAlign: TextAlign.center,
                              style: TextStyles.text12(context)
                                  ?.copyWith(color: ColorRes.red),
                            ),
                          )
                        : const SizedBox();
              },
              child: const Padding(
                padding: EdgeInsets.only(top: 54),
                child: CircularProgressIndicator(
                  color: ColorRes.primary,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
