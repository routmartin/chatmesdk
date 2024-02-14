import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../util/theme/app_color.dart';

class ScaffoldWrapper extends StatelessWidget {
  const ScaffoldWrapper({
    Key? key,
    required this.child,
    this.padding = 22,
    this.color,
  }) : super(key: key);
  final Widget child;
  final double padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        padding: EdgeInsets.symmetric(horizontal: padding),
        decoration: BoxDecoration(
          gradient: color == null
              ? AppColors.profileGradient()
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color!,
                    color!,
                  ],
                ),
        ),
        child: SafeArea(
          bottom: false,
          child: child,
        ),
      ),
    );
  }
}
