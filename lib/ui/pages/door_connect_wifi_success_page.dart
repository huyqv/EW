// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sample/ui/pages/base_page.dart';
// import 'package:sample/ui/pages/door_select_wifi_page.dart';
// import 'package:sample/ui/res/color.dart';
// import 'package:sample/ui/res/image_name.dart';
// import 'package:sample/ui/res/text_styles.dart';
// import 'package:sample/ui/widgets/app_bar.dart';
// import 'package:sample/ui/widgets/button.dart';
// import 'package:sample/ui/widgets/layout.dart';
//
// //ignore: must_be_immutable
// class DoorConnectWifiSuccessPage extends BasePage {
//   DoorConnectWifiSuccessPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: widgetAppBar(
//         context: context,
//         centerWidget: logoDark(),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             children: [
//               const SizedBox(
//                 height: 24,
//               ),
//               Text(
//                 "Smart Door",
//                 style: TextStyles.text24Bold(context),
//               ),
//               const SizedBox(
//                 height: 16,
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 40, right: 40),
//                 child: Text(
//                   "Kết nối thành công ứng dụng D Vision với “Smart Door”",
//                   style: TextStyles.text14(context)
//                       ?.copyWith(color: ColorRes.middleGray),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               const SizedBox(
//                 height: 16,
//               ),
//               SizedBox(
//                   width: width(context),
//                   height: height(context) / 2,
//                   child: Image.asset(ImageName.smartDoor, fit: BoxFit.cover,)),
//               const SizedBox(
//                 height: 16,
//               ),
//             ],
//           ),
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 16, right: 16),
//                 child: ButtonView(text: "Tiếp theo", onTap: () {
//                   push(context, const DoorSelectWifiPage());
//                 }),
//               ),
//               sloganBottomWidget(context)
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
