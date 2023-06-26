import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/data/firebase.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/pages/home/home_page.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/dimen.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/door_vm.dart';
import 'package:sample/ui/vm/home_vm.dart';
import 'package:sample/ui/widgets/button.dart';
import 'package:sample/ui/widgets/input_text.dart';

import '../../model/door.dart';
import '../widgets/app_bar.dart';
import '../widgets/layout.dart';

var doorWarningProvider = StateProvider((ref) => DoorWarning());
var _switchValueProvider = StateProvider((ref) => true);

class DoorWarningItem {
  String text = '';
  String description = '';
  Duration duration = Duration(milliseconds: -1);

  DoorWarningItem({
    required this.text,
    required this.description,
    required this.duration,
  });

  static const defaultDuration = 10000;
}

class DoorWarningPage extends BaseStatefulWidget {
  final Door door;

  const DoorWarningPage({Key? key, required this.door}) : super(key: key);

  @override
  _DoorWarningPageState createState() => _DoorWarningPageState();
}

class _DoorWarningPageState extends BaseState<DoorWarningPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _doorFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      var status = ref.watch(internetStatusProvider);
      if(status == ConnectivityResult.none) {
        toastInternetError(context);
      }
      ref.read(_switchValueProvider.state).state =
          widget.door.warning.isEnable();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.door.warning.type == 'custom') {
      _textController.text = widget.door.warning.value.toString();
    }
    return Scaffold(
        appBar: widgetAppBar(context: context, centerWidget: logoDark()),
        body: padding(
            horizontal: Dimen.padding16,
            child: SizedBox(
              height: height(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            padding(top: Dimen.padding24),
                            Text(
                              "Thiết lập cảnh báo",
                              style: TextStyles.text24Bold(context),
                            ),
                            padding(top: Dimen.padding48),
                            //_defaultListWidget(),
                            //_settingCustomWidget(context),
                          ],
                        ),
                      ),
                      _switchWidget(context)
                    ],
                  ),
                  sloganBottomWidget(context)
                ],
              ),
            )));
  }

  Widget _switchWidget(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      var switchValue = ref.watch(_switchValueProvider);
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: ColorRes.lightGray,
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              ImageName.notification,
              width: 24,
              height: 24,
            ),
            SizedBox(
              width: 10,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nhận thông báo",
                    style: TextStyles.text14Bold(context),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Cảnh báo khi có người lạ ở trước cửa",
                    style: TextStyles.text14Gray(context),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Consumer(builder: (context, ref, child) {
              var status = ref.watch(internetStatusProvider);
              return status != ConnectivityResult.none
                  ? CupertinoSwitch(
                      value: switchValue,
                      activeColor: ColorRes.primary,
                      onChanged: (value) {
                        ref.read(_switchValueProvider.state).state = value;
                        var warning = value == false
                            ? DoorWarning(type: 'custom', value: -1)
                            : DoorWarning();
                        FirebaseUtil.setWarningSetting(widget.door, warning);
                      })
                  : IgnorePointer(
                      ignoring: true,
                      child: CupertinoSwitch(
                          value: switchValue,
                          activeColor: ColorRes.primary,
                          onChanged: (value) {
                            ref.read(_switchValueProvider.state).state = value;
                            var warning = value == false
                                ? DoorWarning(type: 'custom', value: -1)
                                : DoorWarning();
                            FirebaseUtil.setWarningSetting(
                                widget.door, warning);
                          }),
                    );
            })
          ],
        ),
      );
    });
  }

  Widget _acceptButton(BuildContext context) {
    return ButtonView(
        padding: const EdgeInsets.only(bottom: 24),
        text: "Xác nhận",
        onTap: () {
          DoorWarning warning = ref.read(doorWarningProvider.state).state;
          if (warning.type == 'custom') {
            try {
              warning.value = int.parse(_textController.text);
            } catch (e) {
              warning.value = 0;
            }
          }
          if (warning.value <= 0) {
            toastError(context, 'Vui lòng nhập giá trị lớn hơn 0');
            return;
          }
          FirebaseUtil.setWarningSetting(widget.door, warning);
          Navigator.of(context).pop();
        });
  }

  Widget _defaultListWidget() {
    return Consumer(
      builder: (context, ref, _) {
        var provider = ref.watch(doorWarningProvider.state);
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _listItem.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) => _settingItemWidget(
            context,
            _listItem[index],
          ),
        );
      },
    );
  }

  Widget _settingCustomWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimen.padding16, vertical: Dimen.padding16),
      margin: const EdgeInsets.only(bottom: Dimen.padding8),
      decoration: BoxDecoration(
          color: ColorRes.lightGray,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.transparent)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tùy chọn thời gian (giây)',
                        style: TextStyles.text16Bold(context),
                      ),
                      Consumer(builder: (context, ref, child) {
                        DoorWarning warning =
                            ref.watch(doorWarningProvider.state).state;
                        bool isSelected = warning.type != 'default';
                        return appCheckBox(
                          isChecked: isSelected,
                          paddingHorizontal: Dimen.padding8,
                          checkable: false,
                        );
                      }),
                    ],
                  ),
                  onTap: () {
                    var duration = 0;
                    try {
                      int.parse(_textController.text);
                    } catch (e) {}
                    ref.read(doorWarningProvider.state).state =
                        DoorWarning(type: 'custom', value: duration);
                  },
                ),
                padding(bottom: Dimen.padding8),
                InputTextOutline(
                  controller: _textController,
                  unFocusBorderColor: ColorRes.middleGray,
                  focusBorderColor: ColorRes.middleGray,
                  textInputType: TextInputType.phone,
                  focusNode: _doorFocusNode,
                  onChange: (text) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingItemWidget(BuildContext context, DoorWarningItem item) {
    return GestureDetector(
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: Dimen.padding16),
        margin: const EdgeInsets.only(bottom: Dimen.padding8),
        decoration: BoxDecoration(
            color: ColorRes.lightGray,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.transparent)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.text,
                    style: TextStyles.text16Bold(context),
                  ),
                  Text(
                    item.description,
                    style: TextStyles.text12Gray(context),
                  )
                ],
              ),
            ),
            Consumer(builder: (context, ref, child) {
              DoorWarning warning = ref.read(doorWarningProvider.state).state;
              bool isSelected = warning.type == 'default' &&
                  warning.value == item.duration.inMilliseconds;
              return appCheckBox(
                isChecked: isSelected,
                paddingHorizontal: Dimen.padding8,
                checkable: false,
              );
            })
          ],
        ),
      ),
      onTap: () {
        ref.read(doorWarningProvider.state).state =
            DoorWarning(value: item.duration.inMilliseconds);
      },
    );
  }
}

List<DoorWarningItem> _listItem = [
  DoorWarningItem(
    text: 'Không cảnh báo',
    description: 'Không cảnh báo khi có người lạ đứng trước cửa',
    duration: Duration(milliseconds: -1),
  ),
  DoorWarningItem(
    text: 'Nhạy',
    description: 'Cảnh báo khi có người lạ trước cửa trong thời gian ngắn',
    duration: Duration(milliseconds: 10000),
  ),
  DoorWarningItem(
    text: 'Vừa phải',
    description: 'Cảnh báo khi người lạ đứng trước cửa trên 1 phút',
    duration: Duration(milliseconds: DoorWarningItem.defaultDuration),
  ),
  DoorWarningItem(
    text: 'Hạn chế',
    description: 'Cảnh báo khi người lạ đứng trước cửa trên 5 phút',
    duration: Duration(milliseconds: 300000),
  ),
];
