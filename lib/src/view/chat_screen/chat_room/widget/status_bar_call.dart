import 'package:chatme/data/chat_room/chat_room_controller.dart';
import 'package:chatme/util/constant/app_builder_id.dart';
import 'package:chatme/util/constant/call_enum.dart';
import 'package:chatme/util/helper/call_validator_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatusBarCell extends StatelessWidget {
  const StatusBarCell({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return GetBuilder<ChatRoomController>(
      id: AppBuilderID.audioCallBuilder,
      builder: (controller) {
        if (controller.roomType == 'g') return SizedBox.shrink();
        var displayTime = controller.intToTimeLeft(controller.start);
        if (controller.audioCallEventState == CallEventEnum.startCall ||
            controller.audioCallEventState == CallEventEnum.joinCall ||
            controller.audioCallEventState == CallEventEnum.connecting ||
            controller.audioCallEventState == CallEventEnum.audioCall) {
          return Material(
            child: GestureDetector(
              onTap: () async {
                await controller.navigateToVoiceScreen(false);
              },
              child: AnimatedContainer(
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width,
                height: statusBarHeight + 12,
                color: controller.audioCallEventState == CallEventEnum.joinCall ? Colors.green : Colors.red,
                duration: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    '${'touch_to_return_to_call'.tr} ${CallValidatorHelper.displayCallState(controller.audioCallEventState, displayTime)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
