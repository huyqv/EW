import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/data/pref.dart';
import 'package:sample/router/route_name.dart';
import 'package:sample/router/routing.dart';
import 'package:sample/ui/pages/auth/auth_page.dart';
import 'package:sample/ui/pages/intro/intro_state.dart';
import 'package:sample/ui/res/dimen.dart';

import '../../res/image_name.dart';
import '../base_page.dart';

final pageProvider = StateProvider((ref) => 0);
final pageItemList = [
  {
    'title': 'Bước 1',
    'message':
        'Kết nối ứng dụng D Vision với Smart Door thông qua Wi-Fi Hotspot.',
    'image': ImageName.intro1,
  },
  {
    'title': 'Bước 2',
    'message':
        'Đăng ký khuôn mặt.\nTiến hành xác thực khuôn mặt bạn và những người thân trong gia đình.',
    'image': ImageName.intro2,
  },
  {
    'title': 'Bước 3',
    'message':
        'Hoàn tất đăng ký! \nKhám phá ngay những tính năng đặc biệt cùng D Vision nhé.',
    'image': ImageName.intro3,
  }
];

class IntroPage extends BaseStatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends BaseState<IntroPage> {
  late IntroState state;
  late Pref _pref;
  Timer? _timerBack;
  Timer? _timerNext;

  @override
  void initState() {
    state = IntroState(context);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    _pref = ref.read(prefProvider);
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Stack(
        children: [
          Image.asset(
            ImageName.introBg,
            width: width(context),
            height: height(context),
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                padding(bottom: Dimen.padding24),
                state.carouselSlider(pageItemList, (page) {
                  final currentPage = ref.watch(pageProvider.state).state;
                  if (currentPage != page) {
                    ref.read(pageProvider.state).state = page;
                    state.setTextPage(page);
                  }
                }),
                padding(bottom: Dimen.padding24),
                state.textSlider(pageItemList, (page) {
                  final currentPage = ref.watch(pageProvider.state).state;
                  if (currentPage != page) {
                    ref.read(pageProvider.state).state = page;
                    state.setImagePage(page);
                  }
                }),
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buttonArrowLeft(context, ref),
                        Container(),
                        buttonArrowRight(context, ref),
                      ],
                    ),
                    state.pageIndicator(ref.watch(pageProvider.state).state),
                  ],
                ),
                padding(bottom: Dimen.padding24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buttonArrowLeft(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(pageProvider);
    if (currentPage == 0) {
      return const SizedBox();
    }
    return state.buttonArrowLeft(() {
      if (_timerBack?.isActive ?? false) {
        _timerBack?.cancel();
      }
      _timerBack = Timer(const Duration(milliseconds: 500), () {
        final currentPage = ref.read(pageProvider.state).state;
        var previousPage = currentPage;
        if(currentPage > 0) {
          previousPage = currentPage - 1;
        }
        ref.read(pageProvider.state).state = previousPage;
        state.setImagePage(previousPage);
        state.setTextPage(previousPage);
      });
    });
  }

  Widget buttonArrowRight(BuildContext context, WidgetRef ref) {
    return state.buttonArrowRight(() {
      if (_timerNext?.isActive ?? false) {
        _timerNext?.cancel();
      }
      _timerNext = Timer(const Duration(milliseconds: 500), () {
        final currentPage = ref.read(pageProvider.state).state;
        if (currentPage < 2) {
          final nextPage = currentPage + 1;
          ref.read(pageProvider.state).state = nextPage;
          state.setImagePage(nextPage);
          state.setTextPage(nextPage);
        } else {
          _pref.setOnBoardingComplete();
          Routing.navigate2(context, (context) => const AuthPage(),
              routeName: RouteName.auth, replace: true);
        }
      });
    });
  }
}

