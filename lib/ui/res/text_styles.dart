import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sample/ui/res/color.dart';

class TextStyles {
  static final TextStyles _singleton = TextStyles._internal();

  factory TextStyles() {
    return _singleton;
  }

  TextStyles._internal();

  static TextStyle? text40(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 28,
          fontWeight: FontWeight.w500));

  static TextStyle? text28(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 28,
          fontWeight: FontWeight.w500));

  static TextStyle? text28Bold(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 28,
          fontWeight: FontWeight.w700));

  static TextStyle? text28WhiteBold(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w700));

  static TextStyle? text24(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w500));

  static TextStyle? text24Bold(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w700));

  static TextStyle? text24WhiteBold(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700));

  static TextStyle? text14(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500));

  static TextStyle? text14White(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500));

  static TextStyle? text14Gray(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: ColorRes.middleGray,
          fontSize: 14,
      fontWeight: FontWeight.w500));

  static TextStyle? text14Bold(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w700));

  static TextStyle? text14WhiteBold(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700));

  static TextStyle? text16(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500));

  static TextStyle? text16Gray(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: ColorRes.middleGray,
          fontSize: 16,
          fontWeight: FontWeight.w700));

  static TextStyle? text16Bold(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w700));

  static TextStyle? text16WhiteBold(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700));

  static TextStyle? text12(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w500));

  static TextStyle? text12Gray(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: ColorRes.middleGray,
          fontSize: 12,
          fontWeight: FontWeight.w500));

  static TextStyle? text12Bold(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w700));

  static TextStyle? text12WhiteBold(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700));

  static TextStyle? text12White(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12));

  static TextStyle? text10(BuildContext context) => GoogleFonts.mulish(
      textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.w500));
}
