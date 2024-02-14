import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../util/constant/app_assets.dart';
import '../../util/text_style.dart';

class ShareAppbar extends StatelessWidget {
  const ShareAppbar({
    Key? key,
    required this.title,
    this.trailing,
    this.icon,
    this.onBack,
    this.leading,
  }) : super(key: key);
  final String title;
  final Widget? trailing;
  final IconData? icon;
  final VoidCallback? onBack;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      child: Row(
        children: [
          InkWell(
            onTap: onBack ?? () => Get.back(),
            child: Container(
              width: 55,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 20, bottom: 20, left: 2),
              child: leading ??
                  (icon != null
                      ? Icon(
                          icon,
                        )
                      : Image.asset(Assets.app_assetsIconsSearchBackButton)),
            ),
          ),
          Expanded(
            child: Text(title.tr, textAlign: TextAlign.center, style: AppTextStyle.normalBold),
          ),
          trailing ?? const SizedBox(width: 55),
        ],
      ),
    );
  }
}
