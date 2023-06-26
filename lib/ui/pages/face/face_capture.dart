import 'dart:io';
import 'dart:math' as math;

import 'package:app_settings/app_settings.dart';
import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sample/router/route_name.dart';
import 'package:sample/router/routing.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/pages/face/face_vm.dart';
import 'package:sample/ui/pages/home/home_page.dart';
import 'package:sample/ui/pages/result_page.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/dimen.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/home_vm.dart';
import 'package:sample/ui/widgets/app_bar.dart';
import 'package:sample/ui/widgets/button.dart';
import 'package:sample/ui/widgets/camera.dart';
import 'package:sample/ui/widgets/layout.dart';
import 'package:sample/ui/widgets/text.dart';
import 'package:sample/utils/camera.dart';

import '../../../main.dart';
import 'face_option.dart';

final _faceProvider = AutoDisposeChangeNotifierProvider<FaceVM>(
  (ref) {
    var vm = FaceVM();
    return vm;
  },
);

class FaceCapture extends BaseStatefulWidget {
  const FaceCapture({Key? key, required this.userName}) : super(key: key);
  final String userName;

  @override
  createState() => _FaceCaptureState();
}

class _FaceCaptureState extends BaseState<FaceCapture>
    with WidgetsBindingObserver {
  bool _checkingPermission = false;
  late FaceVM _vm;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && !_checkingPermission) {
      _checkPermission();
    }
    if (state == AppLifecycleState.paused) {
      //_vm.stopCamera();
      _checkingPermission = false;
    }
  }

  Future<void> _checkPermission() async {
    Future.delayed(Duration(seconds: 1), () {
      _vm.init();
      _checkingPermission = true;
    });
  }

  void _onRegisterFace() async {
    var internetStatus = ref.read(internetStatusProvider);
    if (internetStatus != ConnectivityResult.none) {
      var path = await getImagePath();
      File file = await File(path).create();
      file.writeAsBytesSync(_vm.uploadImage!);
      var fileX = XFile(file.path);
      var homeVM = ref.read(homeProvider);
      await _vm.addMember(
        fileX,
        homeVM.selectedDoor!,
        widget.userName,
        (url) {
          _showAlertSuccess(url);
          pushAndRemove(
            context,
            const HomePage(isShowDialog: false),
          );
        },
      );
    } else {
      toastInternetError(context);
    }
  }

  @override
  void initState() {
    _vm = ref.read(_faceProvider);
    WidgetsBinding.instance!.addObserver(this);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _checkPermission();
    });
    super.initState();
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance!.removeObserver(this);
    _vm.stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: height(context),
        width: width(context),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Consumer(
                builder: (context, ref, _) {
                  var vm = ref.watch(_faceProvider);
                  if (vm.isCameraStarted() && !vm.isSwitching) {
                    FaceOption.updateScreenSize(Size(
                      width(context),
                      height(context),
                    ));
                    return fullscreenCamera(context, vm.controller!);
                  }
                  return goneView();
                },
              ),
            ),

            // Face custom paint widgets
            fullStack(child: Consumer(builder: (context, ref, _) {
              final customPaint = ref.watch(_faceProvider).customPaint;
              return customPaint ?? goneView();
            })),

            // Camera control buttons
            Positioned(
              bottom: Dimen.padding24,
              left: 0,
              right: 0,
              child: buttonsByPermission(),
            ),

            // Captured image widgets
            fullStack(child: Consumer(builder: (context, ref, _) {
              var vm = ref.watch(_faceProvider);
              if (vm.isImageCaptured()) {
                return _imageCapturedWidget(context, ref);
              }
              return goneView();
            })),

            // Face focus widgets
            fullStack(child: contentByPermission()),

            // Application bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _appBar(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget contentByPermission() {
    return Consumer(builder: (context, ref, _) {
      var watch = ref.watch(_faceProvider);
      if (camPermission == null) {
        return Container(
          color: ColorRes.black,
        );
      }
      if (camPermission == PermissionStatus.denied) {
        return _permissionDeniedWidget();
      }
      if (camPermission == PermissionStatus.granted &&
          !watch.isImageCaptured()) {
        return _faceFocusWidget(context);
      }
      return goneView();
    });
  }

  Widget buttonsByPermission() {
    return Consumer(builder: (context, ref, _) {
      ref.watch(_faceProvider);
      if (camPermission == PermissionStatus.granted) {
        return _cameraButtons(context);
      }
      return goneView();
    });
  }

  Widget _appBar(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, _) {
        final vm = ref.watch(_faceProvider);
        return vm.isImageCaptured()
            ? widgetAppBar(
                context: context,
                leftWidget: backButtonDark(context),
                centerWidget: logoDark(),
              )
            : widgetAppBar(
                context: context,
                leftWidget: backButtonLight(context),
                centerWidget: logoLight(),
              );
      },
    );
  }

  Widget _permissionDeniedWidget() {
    final flatSize = width(context) * 0.42;
    return Container(
      color: ColorRes.primaryBlack,
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: flatSize,
                  height: flatSize,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFFE3ECFF)),
                  child: FractionallySizedBox(
                    widthFactor: 0.45,
                    heightFactor: 0.45,
                    child: Image.asset(ImageName.camera),
                  ),
                ),
                padding(top: Dimen.padding32),
                Text(
                  'Vui lòng cấp quyền truy cập camera',
                  textAlign: TextAlign.center,
                  style: TextStyles.text16WhiteBold(context),
                ),
              ],
            ),
          ),
          padding(
            horizontal: Dimen.padding24,
            bottom: Dimen.padding24,
            child: buttonPrimary(
              text: 'Cấp quyền camera',
              onPressed: () async {
                await AppSettings.openAppSettings();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraButtons(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final vm = ref.watch(_faceProvider);
        return vm.isCapturing
            ? progressView()
            : SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  children: [
                    Center(
                      child: _captureButton(),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: Dimen.padding24,
                      child: _cameraSwitchButton(),
                    )
                  ],
                ),
              );
      },
    );
  }

  Widget _faceFocusWidget(BuildContext context) {
    final focusSize = width(context) * FaceOption.focusViewRatio;
    final focusTop = height(context) * FaceOption.focusTopPadding;
    return Column(
      children: [
        padding(top: focusTop),
        Consumer(
          builder: (context, ref, _) {
            final vm = ref.watch(_faceProvider);
            return Image.asset(
              ImageName.faceRect,
              color: vm.hasFace ? ColorRes.primary : Colors.white,
              width: focusSize,
              height: focusSize,
              fit: BoxFit.fill,
            );
          },
        ),
        padding(
          horizontal: Dimen.padding24,
          top: Dimen.padding48,
          child: Consumer(
            builder: (context, ref, _) {
              final vm = ref.watch(_faceProvider);
              return Text(
                vm.message.isEmpty ? 'Chụp ảnh ngay' : vm.message,
                textAlign: TextAlign.center,
                style: TextStyles.text24WhiteBold(context),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _captureButton() {
    return GestureDetector(
      onTap: () async {
        await ref.watch(_faceProvider).captureImage();
      },
      child: Container(
        height: 72,
        width: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.6),
        ),
        child: Container(
          height: 56,
          width: 56,
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        ),
      ),
    );
  }

  Widget _imageCapturedWidget(BuildContext context, WidgetRef ref) {
    final focusSize = width(context) * 0.7;
    final portraitSize = width(context) * 0.65;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          padding(top: Dimen.padding96),
          Text(
            'Xác thực khuôn mặt',
            textAlign: TextAlign.center,
            style: TextStyles.text24Bold(context),
          ),
          padding(top: Dimen.padding16),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  width: focusSize,
                  height: focusSize,
                  child: Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          ImageName.faceRect,
                          color: ColorRes.primary,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      Center(
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _vm.capturedImage!,
                              width: portraitSize,
                              height: portraitSize,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                padding(top: Dimen.padding32),
                Text('Hãy chắc chắn hình ảnh khuôn mặt bạn',
                    style: TextStyles.text16(context)),
                Text('hiển thị rõ ràng, không bị mờ và chói sáng.',
                    style: TextStyles.text16Bold(context)),
                /*ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    vm.uploadImage!,
                    width: portraitSize / 3,
                    height: portraitSize / 3,
                    fit: BoxFit.contain,
                  ),
                ),*/
              ],
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              var isLoading = ref.watch(_faceProvider).isLoading;
              return isLoading
                  ? const Padding(
                      padding: EdgeInsets.only(top: 24, bottom: 32),
                      child: CircularProgressIndicator(
                        color: ColorRes.primary,
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        padding(
                          horizontal: Dimen.padding24,
                          child: ButtonView(
                            text: 'Xác nhận',
                            onTap: _onRegisterFace,
                          ),
                        ),
                        padding(top: Dimen.padding8),
                        padding(
                          horizontal: Dimen.padding24,
                          child: ButtonView(
                            text: 'Chụp lại',
                            theme: ButtonView.outline,
                            onTap: () {
                              _vm.hasFace = false;
                              _vm.isFaceProcessing = false;
                              _vm.isCapturing = false;
                              _vm.capturedImage = null;
                              _vm.startCamera();
                            },
                          ),
                        ),
                      ],
                    );
            },
          ),
          sloganBottomWidget(context),
        ],
      ),
    );
  }

  Widget _cameraSwitchButton() {
    return padding(
      left: Dimen.padding16,
      child: GestureDetector(
        onTap: () async {
          await _vm.switchCamera();
        },
        child: Container(
          height: 40,
          width: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0x4D051D3F),
          ),
          child: Image.asset(
            ImageName.faceCamSwitch,
            width: 24,
            height: 24,
            fit: BoxFit.cover,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showResult(BuildContext context, String url) {
    Routing.showResult(
      context,
      routeName: RouteName.faceCapture,
      page: ResultPage(
        theme: RESULT_THEME.success,
        title: 'Tuyệt vời',
        message: 'Đăng ký khuôn mặt thành công',
        buttons: [
          ButtonView(
            text: 'Hoàn tất',
            onTap: () {
              Routing.popToRoot(context);
              _showAlertSuccess(url);
            },
          ),
          const SizedBox(
            height: 24,
          ),
          ButtonView(
            text: 'Thêm thành viên',
            borderColor: ColorRes.primary,
            backgroundColor: Colors.white,
            textColor: ColorRes.primary,
            onTap: () {
              _vm.clearData();
              pushAndRemove(
                  context,
                  const HomePage(
                    isShowDialog: true,
                  ));
            },
          ),
        ],
      ),
    );
  }

  void _showAlertSuccess(String url) {
    topAlert(
        context,
        SizedBox(
          height: 40,
          width: 40,
          child: CircleAvatar(
            backgroundImage: NetworkImage(url),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: Image.asset(
                    ImageName.done,
                    width: 18,
                    height: 18,
                  ),
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  "Thêm thành viên thành công",
                  style: TextStyles.text14Bold(context),
                ),
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              "${widget.userName} được ra vào ${ref.read(homeProvider).selectedDoor!.getDisplayName()}",
              style: TextStyles.text14(context),
            )
          ],
        ));
  }
}
