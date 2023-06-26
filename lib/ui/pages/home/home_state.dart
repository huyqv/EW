import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/model/history.dart';
import 'package:sample/ui/pages/history/dialog.dart';
import 'package:sample/ui/vm/home_vm.dart';
import 'package:sample/ui/widgets/time_line.dart';

import '../../../model/door.dart';
import '../../res/color.dart';
import '../../res/dimen.dart';
import '../../res/image_name.dart';
import '../../res/text_styles.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/layout.dart';
import '../door_info_page.dart';
import '../setting_page.dart';

class HomeState {
  BuildContext context;

  HomeState(this.context);

  final ScrollController doorScrollCtrl = ScrollController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceScrollChange;

  Widget backgroundImage() {
    return Positioned(
      width: width(context),
      height: height(context),
      child: Image.asset(ImageName.backgroundHome, fit: BoxFit.cover),
    );
  }

  Widget appBar({required Widget title}) {
    return widgetAppBar(
        context: context,
        backgroundColor: Colors.transparent,
        leftWidget: const SizedBox(),
        centerWidget: title,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          settingButton(),
        ]);
  }

  Widget appBar2() {
    return widgetAppBar(
        context: context,
        backgroundColor: Colors.transparent,
        leftWidget: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset(
            ImageName.check3,
            width: 24,
            height: 24,
          ),
        ),
        centerWidget: Text(
          "Tính năng nhanh",
          style: TextStyles.text14WhiteBold(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light);
  }

  Widget pageTitle() {
    return padding(
      horizontal: Dimen.padding24,
      top: Dimen.padding8,
      vertical: Dimen.padding24,
      child: Text("Xin chào!", style: TextStyles.text24WhiteBold(context)),
    );
  }

  Widget scrollView({required Widget child, required HomeVM homeVM}) {
    return Expanded(
      child: NotificationListener(
        onNotification: (t) {
          if (t is ScrollUpdateNotification) {
            if (_debounceScrollChange?.isActive ?? false) {
              _debounceScrollChange?.cancel();
            }
            _debounceScrollChange =
                Timer(const Duration(milliseconds: 100), () {
              if (_scrollController.position.pixels > 150 &&
                  homeVM.selectedDoor != null) {
                homeVM.setAppBarTitle(homeVM.selectedDoor!.getDisplayName());
              } else {
                homeVM.setAppBarTitle(null);
              }
            });
          }
          return true;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: child,
        ),
      ),
    );
  }

  Widget settingButton() {
    return GestureDetector(
      onTap: () {
        push(context, const SettingPage());
      },
      child: SizedBox(
        width: Dimen.appBarSize,
        height: Dimen.appBarSize,
        child: Center(child: Image.asset(
          ImageName.setting,
          width: 24,
          height: 24,
        ),),
      ),
    );
  }

  Widget appBarTitle(String? title) {
    if (title != null) {
      return Text(title, style: TextStyles.text14WhiteBold(context));
    }
    return logoLight();
  }

  Widget addDoorButton() {
    return GestureDetector(
      onTap: () {
        push(context, const DoorInfoPage());
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Dimen.doorItemRadius),
        child: Container(
          width: 88,
          height: Dimen.doorItemHeight,
          color: Colors.white.withOpacity(0.2),
          child: DottedBorder(
            dashPattern: const [4, 4],
            borderType: BorderType.RRect,
            strokeWidth: 3,
            color: Colors.white,
            radius: Dimen.doorItemRadius,
            child: Container(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: Dimen.padding8),
                  Image.asset(
                    ImageName.add,
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(height: Dimen.padding16),
                  Text('Thêm cửa', style: TextStyles.text14WhiteBold(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget doorItemWidget(
      {required Door door,
      required Function(Door) onTap,
      }) {
    BoxDecoration border;
    Color doorColor;
    Color flatColor;
    Color textColor;
    if (door.isSelected) {
      border = BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 2, color: ColorRes.primary),
        borderRadius: BorderRadius.circular(Dimen.doorRadiusValue),
      );
      doorColor = ColorRes.primary;
      flatColor = ColorRes.primaryLight;
      flatColor = ColorRes.primaryLight;
      textColor = Colors.black;
    } else {
      border = BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        border: Border.all(width: 0.3, color: ColorRes.white),
        borderRadius: BorderRadius.circular(Dimen.doorRadiusValue),
      );
      doorColor = const Color(0xFFE3ECFF);
      flatColor = Colors.white.withOpacity(0.2);
      textColor = Colors.white;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: GestureDetector(
        onTap: () {
          onTap(door);
        },
        child: Container(
          width: 160,
          height: Dimen.doorItemHeight,
          decoration: border,
          child: Stack(
            children: [
              Positioned(
                right: 8,
                top: 8,
                child: Image.asset(
                  door.isConnected ? ImageName.wifiOn : ImageName.wifiOff,
                  width: 32,
                  height: 20,
                ),
              ),
              Positioned(
                  top: 16,
                  left: 48,
                  child: SizedBox(
                    height: 40,
                    width: 48,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          bottom: 0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: flatColor,
                            ),
                          ),
                        ),
                        Positioned(
                            right: 0,
                            top: 0,
                            child: Image.asset(
                              ImageName.door,
                              color: doorColor,
                              width: 32,
                              height: 32,
                            ))
                      ],
                    ),
                  )),
              Positioned(
                  left: 24,
                  right: 24,
                  bottom: 16,
                  child: Text(
                    door.getDisplayName(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget doorListView(
    List<Door> list,
    Function(Door) onTap,
  ) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding:
          const EdgeInsets.only(left: Dimen.padding24, right: Dimen.padding24),
      itemCount: list.length + 1,
      controller: doorScrollCtrl,
      itemBuilder: (context, index) {
        if (index == 0) {
          return addDoorButton();
        }
        return doorItemWidget(
            door: list[index - 1],
            onTap: (door) {
              final offset = 88 + index * (160 + 16) - width(context) / 3 * 2;
              doorScrollCtrl.animateTo(
                offset.toDouble(),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
              onTap(door);
            },
        );
      },
    );
  }

  Widget historyWidget(List<History> historyList) {
    return historyList.isNotEmpty
        ? HistoryBuilder(
            padding: EdgeInsets.only(
                bottom: historyList.length > 3 ? 0 : 300, left: 24),
            builder: (context, history, child) {
              return historyLightItemWidget(context, history);
            },
            physics: const NeverScrollableScrollPhysics(),
            data: historyList)
        : _listHistoryEmptyWidget(context);
  }

  Widget historyWarningWidget(List<History> historyList) {
    return historyList.isNotEmpty
        ? HistoryBuilder(
            padding: EdgeInsets.only(
                bottom: historyList.length > 3 ? 0 : 300, left: 24),
            builder: (context, value, child) {
              return historyWarningLightItemWidget(context, history: value,
                  onTap: () {
                showDialogWarning(context: context, history: value);
              });
            },
            physics: const NeverScrollableScrollPhysics(),
            data: historyList)
        : _listHistoryEmptyWidget(context);
  }

  Widget _listHistoryEmptyWidget(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Image.asset(
            ImageName.action,
            width: 160,
            height: 160,
            fit: BoxFit.cover,
          ),
        ),
      ),
      Center(
        child: Text(
          "Chưa có hoạt động",
          style: TextStyles.text24WhiteBold(context),
        ),
      ),
      Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          child: Text(
            "Lịch sử sẽ hiển thị khi có lượt ra vào cửa",
            style: TextStyles.text14White(context),
          ),
        ),
      ),
      const SizedBox(
        height: 200,
      )
    ]);
  }

}
