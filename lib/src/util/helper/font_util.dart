import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class FontUtil {
  FontUtil._();

  static double size(String size) => double.parse(size).sp;
  static Color color(String hexCode) => Color(int.parse(hexCode));
  static String tr(String text) => text.tr;
}
