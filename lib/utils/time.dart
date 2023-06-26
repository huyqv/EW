import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

var datetimeFormat = "hh:mm aaa dd/MM/yyyy";

//  return stringFromDate("HH:mm aaa", date);
String stringFromDate(String format, DateTime dateTime) {
  final formatter = DateFormat(format);
  return formatter.format(dateTime);
}

DateTime dateFromMilliseconds(int milliseconds) {
  return DateTime.fromMillisecondsSinceEpoch(milliseconds);
}

String dateToString(int time) {
  var date = dateFromMilliseconds(time);
  var now = DateTime.now();
  if (DateUtils.isSameDay(date, now)) {
    return "Hôm nay";
  }
  var yesterday = now.subtract(const Duration(days: 1));
  if (DateUtils.isSameDay(date, yesterday)) {
    return "Hôm qua";
  } else {
    return stringFromDate("dd/MM/yyyy", date);
  }
}