import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sample/model/door.dart';
import 'package:sample/model/history.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/pages/history/dialog.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/history_vm.dart';
import 'package:sample/ui/vm/home_vm.dart';
import 'package:sample/ui/widgets/app_bar.dart';
import 'package:sample/ui/widgets/sliver_title_view.dart';
import 'package:sample/ui/widgets/layout.dart';
import 'package:sample/ui/widgets/time_line.dart';
import "package:collection/collection.dart";
import 'package:sample/utils/time.dart';

var _expandAppBarProvider = StateProvider((ref) => true);

class HistoryPage extends BaseStatefulWidget {
  const HistoryPage({
    Key? key,
    required this.door,
  }) : super(key: key);
  final Door door;

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends BaseState<HistoryPage>
    with TickerProviderStateMixin {
  final RefreshController _historyRefreshController = RefreshController();
  final RefreshController _historyWarningRefreshController =
      RefreshController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  late HomeVM _homeVM;
  late HistoryVM _vm;

  void onTabChange() {
    _vm.onTabChange(_tabController.index);
  }

  @override
  void initState() {
    _tabController = TabController(
        length: 2,
        vsync: this,
        animationDuration: const Duration(milliseconds: 500));
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _vm.init(widget.door);
    });
    _tabController.addListener(onTabChange);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.removeListener(onTabChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _homeVM = ref.read(homeProvider);
    _vm = ref.read(historyProvider);
    _vm.memberList = _homeVM.memberList;
    _vm.doorList = _homeVM.doorList;
    return Scaffold(
        body: NotificationListener(
      onNotification: (t) {
        if (t is ScrollUpdateNotification) {
          var currentState = ref.read(_expandAppBarProvider);
          if (_scrollController.position.pixels > 40 && currentState == true) {
            ref.read(_expandAppBarProvider.state).state = false;
          } else if (_scrollController.position.pixels < 40 &&
              currentState == false) {
            ref.read(_expandAppBarProvider.state).state = true;
          }
        }
        return true;
      },
      child: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _appBar(context),
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            elevation: 0,
            titleSpacing: 0,
            title: Container(
              margin: const EdgeInsets.only(
                left: 32,
                right: 32,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(width: 0.3, color: Colors.white),
                color: ColorRes.lightGray,
              ),
              child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: ColorRes.primary,
                  ),
                  unselectedLabelColor: ColorRes.middleGray,
                  labelColor: ColorRes.white,
                  labelStyle: TextStyles.text14Bold(context),
                  unselectedLabelStyle: TextStyles.text14White(context),
                  onTap: _vm.onTabChange,
                  tabs: const [
                    Tab(text: "Lượt ra vào"),
                    Tab(text: "Cảnh báo"),
                  ]),
            ),
          )
        ],
        body: Consumer(builder: (context, ref, child) {
          ref.watch(historyProvider);
          var groupHistory =
              groupBy(_vm.kHistoryList, (History obj) => obj.date());
          var groupWarningHistory =
              groupBy(_vm.kHistoryWarningList, (History obj) => obj.date());
          if (_historyRefreshController.isLoading) {
            _historyRefreshController.loadComplete();
          }
          if (_historyWarningRefreshController.isLoading) {
            _historyWarningRefreshController.loadComplete();
          }
          return SizedBox(
            height: height(context),
            child: TabBarView(controller: _tabController, children: [
              groupHistory.isNotEmpty
                  ? historyListWidget(context, _historyRefreshController,
                      groupHistory, false, _vm.onHistoryLoadMore)
                  : historyEmptyWidget(context, true),
              groupWarningHistory.isNotEmpty
                  ? historyListWidget(context, _historyWarningRefreshController,
                      groupWarningHistory, true, _vm.onHistoryWarningLoadMore)
                  : historyEmptyWidget(context, true),
            ]),
          );
        }),
      ),
    ));
  }

  Widget historyListWidget(
      BuildContext context,
      RefreshController refreshController,
      Map<String, List<History>> group,
      bool isWarning,
      void Function() onLoadMore) {
    return SmartRefresher(
      controller: refreshController,
      onLoading: onLoadMore,
      footer: const ClassicFooter(
        loadingText: "",
        canLoadingText: "",
        idleText: "",
        idleIcon: SizedBox(),
        loadStyle: LoadStyle.HideAlways,
      ),
      enablePullDown: false,
      enablePullUp: true,
      child: ListView.builder(
          itemCount: group.keys.length,
          itemBuilder: (context, index) {
            var values = group.values.elementAt(index);
            var history =
                values.where((element) => element.doorObj != null).toList();
            return HistoryBuilder(
              builder: (context, data, child) {
                return isWarning
                    ? historyWarningDarkItemWidget(context, onTap: () {
                        showDialogWarning(context: context, history: data);
                      }, history: data)
                    : historyDarkItemWidget(context, data);
              },
              data: history,
              header: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  dateToString(history[0].time),
                  style: TextStyles.text14Bold(context)
                      ?.copyWith(color: ColorRes.middleGray),
                ),
              ),
              physics: const NeverScrollableScrollPhysics(),
            );
          }),
    );
  }

  SliverAppBar _appBar(BuildContext context) {
    return SliverAppBar(
      leading: backButtonDark(context),
      automaticallyImplyLeading: false,
      expandedHeight: 140.0,
      floating: true,
      pinned: true,
      snap: true,
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      title: SliverTitleView(child: euroLogoWidget()),
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Text(
            "Lịch sử hoạt động",
            style: TextStyles.text16Bold(context),
          ),
        ),
      ),
    );
  }
}
