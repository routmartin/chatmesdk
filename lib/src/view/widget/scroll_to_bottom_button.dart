import 'package:flutter/material.dart';

import '../../util/theme/app_color.dart';

class ChatScrollToButtomButton extends StatelessWidget {
  const ChatScrollToButtomButton({
    Key? key,
    required this.isShowScrollToBottom,
    required this.inRoomUnreadCountNumber,
    required this.scrollToBottom,
  }) : super(key: key);
  final bool isShowScrollToBottom;
  final int inRoomUnreadCountNumber;
  final Function() scrollToBottom;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 14.0,
      bottom: isShowScrollToBottom ? 14.0 : -44,
      child: AnimatedOpacity(
        opacity: isShowScrollToBottom ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
        child: InkWell(
          onTap: scrollToBottom,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.passthrough,
            children: [
              Container(
                width: 35.0,
                height: 35.0,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9).withOpacity(.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF787878),
                  size: 25,
                ),
              ),
              Positioned.fill(
                  child: Align(
                alignment: Alignment.topCenter,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: inRoomUnreadCountNumber > 0 ? 1 : 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      inRoomUnreadCountNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
