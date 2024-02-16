import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../util/constant/app_constant.dart';

class ChatVoiceLongPressWrapper extends StatefulWidget {
  const ChatVoiceLongPressWrapper({
    Key? key,
    required this.child,
    required this.isLongPress,
    required this.isCancelled,
    required this.isReleaseHold,
  }) : super(key: key);
  final bool isLongPress;
  final bool isCancelled;
  final bool isReleaseHold;
  final Widget child;
  @override
  State<ChatVoiceLongPressWrapper> createState() => ChatVoiceLongPressWrapperState();
}

class ChatVoiceLongPressWrapperState extends State<ChatVoiceLongPressWrapper> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: AppConstants.animationDuration200),
          child: widget.isLongPress
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      widget.isCancelled
                          ? 'release_to_cancel'.tr
                          : widget.isReleaseHold
                              ? 'release_to_lock'.tr
                              : 'swipe_left_to_cancel_and_release_to_send'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13.33,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                )
              : const Offstage(),
        ),
        widget.child
      ],
    );
  }
}
