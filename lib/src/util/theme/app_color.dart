import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  AppColors._();

  static const white = Color(0xFFFFFFFF);
  static const black = Colors.black;
  static const red = Color(0XFFCD2525);
  static const lightGray = Color(0XFF999999);
  static const softGray = Color(0XFFABABAB);
  static const dartGray = Color(0XFFCCCCCC);
  static const secondLightGray = Color(0XFF787878);
  static const lightGrayBackground = Color(0XFFEFEFF4);
  // Decoration
  static const primaryColor = Color(0XFF4FB848);
  static const seconderyColor = Color(0xFF343434);
  static const subPrimaryColor = Color(0XFFCD2525);

  static const subSeconderyColor = Color(0XFFD2EAD8);
  static const scaffoldBackground = Color(0XFFFBFBFB);
  static const labelPrimaryGreen = Color(0XFFD2EAD8);
  static const disableContiner = Color(0XFFE2E6FF);
  // TextField
  static const inputBorderColor = Color(0XFFCCCCCC);
  static const errorBorderColor = Color(0XFFFF3333);
  static const inputBackgorundColor = Color(0XFFFFFFFF);
  // TextColor
  static const inputTextColor = Color(0XFF4B4B4B);
  static const bigTitleColor = Color(0XFF333333);
  static const primaryTextColor = Color(0XFF535353);
  static const txtSeconddaryColor = Color(0XFF343434);
  static const labelTextColor = Color(0XFFACACAC);
  static const meduiemTitleColor = Color(0XFF3A3A3C);
  static const textFiledBackgroundColor = Color(0XFF474849);

  static Color profileAppbarColor = const Color(0XFF47BA40).withOpacity(.13);
  static const buttonAcceptBackground = Color(0XFF4882B8);
  static const buttonVideoBackground = Color(0XFF374957);
  static const borderBackground = Color(0XFFD9D9D9);

  // unknow
  static const hexWhite = '0XFFFFFFFF';
  static const hexLightGray = '0XFFD9D9D9';
  static const hexGreen = '0XFF47BA40';
  static const hexBlack = '0XFF535353';
  static const hexGrey = '0XFF535353';
  static const hexLightblue = '0XFF4882B8';
  static const hexButtonGrey = '0xffACACAC';

  static LinearGradient profileGradient() => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0XFF47BA40).withOpacity(.13),
          const Color(0XFF47BA40).withOpacity(.1),
          const Color(0XFF47BA40).withOpacity(.1),
          const Color(0XFFBBBBBB).withOpacity(.05),
        ],
      );

  static BoxDecoration profileCardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 1,
          color: const Color(0xFFEEEEEE),
        ),
      );
  static TextStyle profileTextStyle() => const TextStyle(
        color: AppColors.txtSeconddaryColor,
        fontSize: 13.3,
        fontWeight: FontWeight.w400,
      );
  static double width = 365;

  static Null Function() onTapEmpty() => () {
        Get.snackbar('hello', 'good tap');
      };

  static final modalDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(4),
  );
  static const modalMargin = 25.0;
}
