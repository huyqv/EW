import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:sample/data/native.dart';
import 'package:sample/model/history.dart';
import 'package:sample/model/member.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/pages/history/history_page.dart';
import 'package:sample/ui/pages/home/dialog.dart';
import 'package:sample/ui/pages/user/member_info_page.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/dimen.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/home_vm.dart';
import 'package:sample/ui/widgets/dash_border.dart';
import 'package:sample/ui/widgets/layout.dart';

import 'home_state.dart';

var _menuShowProvider = StateProvider((ref) => false);
var _tabPositionProvider = StateProvider((ref) => 0);
var internetStatusProvider = StateProvider((ref) => ConnectivityResult.none);

class HomePage extends BaseStatefulWidget {
  const HomePage({
    Key? key,
    this.isShowDialog = false,
  }) : super(key: key);
  final bool isShowDialog;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends BaseState<HomePage>
    with SingleTickerProviderStateMixin {
  late StreamSubscription _subscription;
  late HomeVM _homeVM;
  late HomeState state;

  void showAlertWarning(History history) {
    userTopAlert(context, history.image, ImageName.error2, "Cảnh báo",
        "Đang có người lạ ở trước cửa",
        isError: true);
  }

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      ref.read(internetStatusProvider.state).state = result;
      if (result == ConnectivityResult.none) {
        toastInternetError(context);
      }
    });
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.isShowDialog) {
        showDialogAddMember(
            context, _homeVM.selectedDoor!, _homeVM.memberListByDoor);
      }
      _homeVM.listenHistoryWarning(showAlertWarning);
    });
    Connectivity().checkConnectivity().then((value) {
      ref.read(internetStatusProvider.state).state = value;
      if (value == ConnectivityResult.none) {
        toastInternetError(context);
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    state = HomeState(context);
    _homeVM = ref.read(homeProvider);
    _homeVM.listenDoorList();
    _homeVM.listenMemberList();
    return Scaffold(
      body: Stack(
        children: [
          state.backgroundImage(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer(builder: (context, ref, child) {
                  var enableFastFuture = ref.watch(_menuShowProvider);
                  return enableFastFuture
                      ? state.appBar2()
                      : state.appBar(
                          title: Consumer(builder: (context, ref, _) {
                          final title = ref.watch(homeProvider).appBarTitle;
                          return state.appBarTitle(title);
                        }));
                }),
                state.scrollView(
                  homeVM: _homeVM,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      state.pageTitle(),
                      SizedBox(
                        height: 100,
                        child: Consumer(
                          builder: (context, ref, _) {
                            /// event
                            final vm = ref.watch(homeProvider);
                            var internetError =
                                ref.watch(internetStatusProvider);
                            return state.doorListView(vm.doorList, (door) {
                              if (vm.selectedDoor!.serial != door.serial) {
                                _homeVM.setSelectedDoor(door);
                                return;
                              }
                              ref.read(_menuShowProvider.state).state = true;

                              /// event
                              showHomeMenuDialog(
                                context,
                                ref,
                                onClose: () {
                                  var provider =
                                      ref.read(_menuShowProvider.state);
                                  provider.state = false;
                                },
                                onOpenDoorTap: () {
                                  if (door.isConnected &&
                                      internetError !=
                                          ConnectivityResult.none) {
                                    _homeVM.openDoor(
                                      door: door,
                                      onSuccess: () {
                                        // toastActionDoorSuccess(
                                        //   context,
                                        //   "Mở cửa thành công",
                                        //   "${door.getDisplayName()} đã được mở",
                                        // );
                                      },
                                      onError: (message) {
                                        toastError(context, message,
                                            icon: ImageName.wifiDisconnect);
                                      },
                                    );
                                  } else {
                                    toastInternetError(context);
                                  }
                                },
                              );
                            });
                          },
                        ),
                      ),
                      padding(top: Dimen.padding24),
                      _infoWidget(context),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  ///
  Widget _infoWidget(
    BuildContext context,
  ) {
    return Container(
      width: width(context),
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            ColorRes.primaryBlack.withOpacity(0.2),
            ColorRes.primaryBlack.withOpacity(0.85)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          border: Border.all(color: Colors.transparent),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      child: Consumer(builder: (context, ref, child) {
        ref.watch(homeProvider);
        var internetStatus = ref.watch(internetStatusProvider);
        return internetStatus != ConnectivityResult.none
            ? _homeVM.doorList.isNotEmpty
                ? _listMember(context, _homeVM.memberListByDoor)
                : _listDoorEmptyWidget(context)
            : _internetErrorWidget(context);
      }),
    );
  }

  Widget _listMember(BuildContext context, List<Member> members) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 24, top: 24),
        child: Text(
          "Danh sách thành viên (${members.length})",
          style: TextStyles.text16WhiteBold(context),
        ),
      ),
      SizedBox(
        height: 164,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 42),
            itemCount: members.length + 1,
            itemBuilder: (context, index) => index == 0
                ? _addMemberWidget(context)
                : _userWidget(context, member: members[index - 1], onTap: () {
                    _homeVM.selectedMember = members[index - 1];
                    push(context, const MemberInfoPage());
                  })),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Lịch sử hoạt động",
              style: TextStyles.text16WhiteBold(context),
            ),
            GestureDetector(
              onTap: () {
                push(
                    context,
                    HistoryPage(
                      door: _homeVM.selectedDoor!,
                    ));
              },
              child: Text(
                "Xem tất cả",
                style: TextStyles.text12WhiteBold(context)
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
      HomeTabBar(
        index: ref.read(_tabPositionProvider),
        onTap: (index) {
          ref.read(_tabPositionProvider.state).state = index;
        },
      ),
      Consumer(builder: (context, ref, child) {
        var historyList = ref.watch(homeProvider).histories;
        var historyWarningList = ref.watch(homeProvider).historiesWarning;
        var tabIndex = ref.watch(_tabPositionProvider);
        return tabIndex == 0
            ? state.historyWidget(historyList)
            : state.historyWarningWidget(historyWarningList);
      }),
    ]);
  }

  Widget _listDoorEmptyWidget(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 64, bottom: 24),
          child: Image.asset(
            ImageName.document,
            width: 160,
            height: 160,
          ),
        ),
        Text(
          "Chưa có thông tin",
          style: TextStyles.text24WhiteBold(context),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 42, right: 42, top: 16),
          child: Text(
            "“Thêm cửa” để quản lý và bắt đầu cài đặt các chức năng",
            style: TextStyles.text14White(context),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(
          height: 300,
        )
      ],
    );
  }

  Widget _internetErrorWidget(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 64, bottom: 34),
          child: Image.asset(
            ImageName.internetError,
            width: 160,
            height: 160,
          ),
        ),
        Text(
          "Chưa có kết nối Wi-fi",
          style: TextStyles.text24WhiteBold(context)
              ?.copyWith(color: ColorRes.primaryLight),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 42, right: 42, top: 16),
          child: Text(
            "Vui lòng kiểm tra lại kết nối Wi-fi để Cửa được hoạt động",
            style: TextStyles.text14White(context),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(
          height: 300,
        )
      ],
    );
  }

  Widget _addMemberWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_homeVM.selectedDoor == null) {
          Native.showToast("Vui lòng chọn cửa");
        } else {
          showDialogAddMember(
              context, _homeVM.selectedDoor!, _homeVM.memberList);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: DashPathBorder.all(
                  borderSide: const BorderSide(color: ColorRes.primaryLight),
                  dashArray: CircularIntervalList([5, 2.5])),
            ),
            child: Image.asset(
              ImageName.addUser,
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "Thêm mới",
              style: TextStyles.text12WhiteBold(context),
            ),
          )
        ],
      ),
    );
  }

  Widget _userWidget(
    BuildContext context, {
    required Member member,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 74,
          child: Column(
            children: [
              Container(
                width: 74,
                height: 74,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF46D0FC), width: 1),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          member.userPhoto,
                        ),
                        fit: BoxFit.cover),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0452E3).withOpacity(0),
                            const Color(0xFF0452E3).withOpacity(0.5),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  member.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.text12WhiteBold(context),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTabBar extends StatefulWidget {
  final ValueChanged<int> onTap;
  final int? index;

  const HomeTabBar({
    Key? key,
    required this.onTap,
    this.index,
  }) : super(key: key);

  @override
  HomeTabBarState createState() => HomeTabBarState();
}

class HomeTabBarState extends State<HomeTabBar> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    if (widget.index != null) {
      _tabController.animateTo(widget.index!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 32, right: 32, top: 24, bottom: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 0.3, color: Colors.white),
          color: Colors.white.withOpacity(0.2)),
      child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(
              16,
            ),
            color: Colors.white,
          ),
          unselectedLabelColor: Colors.white,
          labelColor: ColorRes.primaryBlack,
          labelStyle: TextStyles.text14Bold(context),
          unselectedLabelStyle: TextStyles.text14White(context),
          onTap: widget.onTap,
          physics: const NeverScrollableScrollPhysics(),
          tabs: const [
            Tab(text: "Lượt ra vào"),
            Tab(text: "Cảnh báo"),
          ]),
    );
  }
}
