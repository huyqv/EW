import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sample/router/route_name.dart';
import 'package:sample/router/routing.dart';
import 'package:sample/ui/pages/base_view.dart';
import 'package:sample/ui/pages/intro/intro_page.dart';
import 'package:sample/ui/res/dimen.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with BaseView{

  void _onNext(BuildContext context) async {
    await Routing.navigate2(context, (context) => const IntroPage(),
        routeName: RouteName.intro, replace: true);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          body: Stack(
            children: [
              Image.asset(
                ImageName.splashBg,
                width: width(context),
                height: height(context),
                fit: BoxFit.cover,
              ),
              Column(
                children: [
                  padding(top: Dimen.padding48),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        ImageName.logoEuroText,
                        width: 216,
                        height: 40,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "D Vision",
                        style: TextStyles.text40(context)
                            ?.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      ImageName.splashImg,
                      width: width(context),
                      height: width(context),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          _onNext(context);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "BẮT ĐẦU",
                              style: TextStyles.text24WhiteBold(context),
                            ),
                            padding(
                              left: 8,
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 30,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
