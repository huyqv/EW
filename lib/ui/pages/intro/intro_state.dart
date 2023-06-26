import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../res/color.dart';
import '../../res/dimen.dart';
import '../../res/text_styles.dart';
import '../../widgets/dot_indicator.dart';
import '../../widgets/layout.dart';

class IntroState {
  BuildContext context;

  IntroState(this.context);

  final CarouselController carouselController = CarouselController();
  final PageController textController = PageController(initialPage: 0);

  Widget carouselSlider(
    List<Map<String, String>> list,
    Function(int) onPageChanged,
  ) {
    return Expanded(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: CarouselSlider(
              items: list.map((element) => carouselItem(element)).toList(),
              carouselController: carouselController,
              options: CarouselOptions(
                viewportFraction: 0.5,
                aspectRatio: 570 / 1142,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                initialPage: 0,
                autoPlay: false,
                onPageChanged: (index, reason) {
                  onPageChanged(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget carouselItem(Map<String, String> item) {
    return Center(
      child: Image.asset(
        item['image']!,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget textSlider(
    List<Map<String, String>> list,
    Function(int) onPageChanged,
  ) {
    return SizedBox(
      height: height(context) / 5,
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: textController,
        scrollDirection: Axis.horizontal,
        onPageChanged: onPageChanged,
        itemBuilder: (context, index) {
          return textItem(list[index]);
        },
      ),
    );
  }

  Widget textItem(Map<String, String> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          item['title']!,
          style: TextStyles.text24WhiteBold(context)
              ?.copyWith(color: ColorRes.white),
        ),
        padding(
          top: Dimen.padding8,
          left: Dimen.padding16,
          right: Dimen.padding16,
          child: Text(
            item['message']!,
            style: TextStyles.text14(context)?.copyWith(color: ColorRes.white),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  Widget pageIndicator(int page) {
    return DotIndicator(
      controller: textController,
      page: page,
      itemCount: 3,
      color: ColorRes.white,
      fixedSize: true,
      onPageSelected: (int page) {},
    );
  }

  Widget buttonArrowLeft(GestureTapCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        width: 54,
        margin: const EdgeInsets.only(left: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1)),
        child: const Icon(
          Icons.arrow_back,
          size: 27,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buttonArrowRight(GestureTapCallback onTap) {
    return padding(
      right: Dimen.padding16,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54,
          width: 100,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              color: ColorRes.primaryBlack),
          child: const Icon(
            Icons.arrow_forward,
            size: 27,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void setImagePage(int page) {
    carouselController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void setTextPage(int page) {
    textController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

}
