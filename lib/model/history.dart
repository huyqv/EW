import 'package:flutter/material.dart';
import 'package:sample/model/door.dart';
import 'package:sample/model/member.dart';
import 'package:sample/utils/time.dart';

class History {
  String door = "";
  String image = '';
  String status = '';
  int time = 0;
  String userId = '';
  Member? userObj;
  Door? doorObj;

  History(this.door, this.image, this.status, this.time, this.userId);

  History.fromJson(Map<String, dynamic> json) {
    door = json["door"];
    image = json["image"];
    status = json["status"];
    time = json["time"];
    userId = json["userId"];
  }

  Map<String, dynamic> toJson() =>
      {
        "door": door,
        "image": image,
        "status": status,
        "time": time,
        "userId": userId
      };

  History.init(History history) {
    door = history.door;
    image = history.image;
    status = history.door;
    time = history.time;
    userId = history.door;
    userObj = history.userObj;
    doorObj = history.doorObj;
  }

  bool isSuccess() => status == "success";

  String statusToString() {
    if (status == "success") {
      return " đã vào ";
    } else {
      return " không vào được ";
    }
  }

  dateTimeToString() {
    var date = dateFromMilliseconds(time);
    var now = DateTime.now();
    var str = stringFromDate("hh:mm aaa", date);
    if (DateUtils.isSameDay(date, now)) {
      return "Hôm nay $str";
    }
    var yesterday = now.subtract(const Duration(days: 1));
    if (DateUtils.isSameDay(date, yesterday)) {
      return "Hôm qua $str";
    }
    return "${date.day}/${date.month}/${date.year} $str";
  }

  String timeToString() {
    var date = dateFromMilliseconds(time);
    return stringFromDate("HH:mm", date);
  }

  String dateToString() {
    var date = dateFromMilliseconds(time);
    var now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) {
      return "Hôm nay";
    }
    var yesterday = now.subtract(const Duration(days: 1));
    if (DateUtils.isSameDay(date, yesterday)) {
      return "Hôm qua";
    }
    return stringFromDate("dd/MM/yyyy", date);
  }

  String date() {
    return stringFromDate("dd/MM/yyyy", dateFromMilliseconds(time));
  }
}
