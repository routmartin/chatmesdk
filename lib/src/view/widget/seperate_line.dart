import 'package:flutter/material.dart';

import '../../util/theme/app_color.dart';

class WidgetBindingSeperateLine extends StatelessWidget {
  const WidgetBindingSeperateLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1,
      color: AppColors.black.withOpacity(0.07),
    );
  }
}
