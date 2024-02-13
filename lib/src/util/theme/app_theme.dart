import 'package:flutter/material.dart';

import 'app_color.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      fontFamily: 'PingFang',
      primaryColor: AppColors.white,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        brightness: Brightness.light,
        background: AppColors.white,
        primary: AppColors.primaryColor,
        primaryContainer: Colors.yellow,
        secondary: Colors.red,
        surface: Colors.blue,
        inverseSurface: Colors.purple,
        onPrimary: Colors.pink,
        onSecondary: Colors.orange,
        onSurface: Colors.orange.shade100,
        onInverseSurface: Colors.orange.shade800,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              elevation: 0,
              splashFactory: NoSplash.splashFactory)));
}
