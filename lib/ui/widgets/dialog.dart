import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

showBottomDialog(BuildContext context, Widget dialogWidget) {
  showMaterialModalBottomSheet(
    context: context,
    duration: const Duration(milliseconds: 500),
    shape: const RoundedRectangleBorder(
      side: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(40),
        topLeft: Radius.circular(40),
      ),
    ),
    builder: (context) => dialogWidget,
  );
}
