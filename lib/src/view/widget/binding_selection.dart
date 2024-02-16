import 'package:flutter/material.dart';

import '../../util/constant/app_assets.dart';

class WidgetBindngSelection extends StatelessWidget {
  const WidgetBindngSelection({
    Key? key,
    required this.isSelected,
    this.onChanged,
    required this.isWidgetShow,
    this.borderColor = Colors.grey,
  }) : super(key: key);
  final bool isSelected;
  final VoidCallback? onChanged;
  final bool isWidgetShow;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isWidgetShow,
      child: InkWell(
        onTap: onChanged,
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: AnimatedCrossFade(
            firstChild: Image.asset(
              Assets.app_assetsIconsSelectionIcon,
              width: 16,
              height: 16,
            ),
            secondChild: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 1.8,
                  color: borderColor!,
                ),
              ),
            ),
            crossFadeState: _checkShowSelectWidget(),
            duration: Duration(microseconds: 400),
          ),
        ),
      ),
    );
  }

  CrossFadeState _checkShowSelectWidget() {
    if (isSelected) return CrossFadeState.showFirst;
    return CrossFadeState.showSecond;
  }
}
