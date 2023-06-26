// import 'package:flutter/material.dart';
// import 'package:sample/router/route_name.dart';
// import 'package:sample/router/routing.dart';
// import 'package:sample/ui/pages/door_connect_wifi_success_page.dart';
// import 'package:sample/ui/res/color.dart';
// import 'package:sample/ui/res/image_name.dart';
// import 'package:sample/ui/res/text_styles.dart';
// import 'package:sample/ui/widgets/layout.dart';
// import 'package:sample/utils/screen_size.dart';
//
// import '../widgets/app_bar.dart';
//
// class DoorInfoLoadingPage extends StatefulWidget {
//   const DoorInfoLoadingPage({Key? key}) : super(key: key);
//
//   @override
//   _DoorInfoLoadingPageState createState() => _DoorInfoLoadingPageState();
// }
//
// class _DoorInfoLoadingPageState extends State<DoorInfoLoadingPage> {
//
//   @override
//   void initState() {
//     Future.delayed(const Duration(seconds: 5), () {
//       Routing.navigate2(context, (context) => DoorConnectWifiSuccessPage(), routeName: RouteName.doorConnectWifiSuccess);
//     });
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         centerTitle: true,
//         title: logoDark(),
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 77,),
//                 Image.asset(ImageName.wifiAnim2, width: 134, height: 134,),
//                 const SizedBox(height: 24,),
//                 Text("Để điện thoại của bạn gần với Smart Door", style: TextStyles.text24Bold(context),),
//                 const SizedBox(height: 16,),
//                 Row(children: [
//                   Image.asset(ImageName.check, width: 24, height: 24,),
//                   Text("Kết nối với thiết bị thành công", style: TextStyles.text14(context)?.copyWith(color: ColorRes.middleGray),)
//                 ],),
//                 const SizedBox(height: 16,),
//                 Row(children: [
//                   Image.asset(ImageName.loading, width: 24, height: 24,),
//                   Text("Chuyển thông tin đến thiết bị thành công", style: TextStyles.text14(context)?.copyWith(color: ColorRes.middleGray),)
//                 ],)
//               ],
//             ),
//             sloganBottomWidget(context)
//           ],
//         ),
//       ),
//     );
//   }
// }
