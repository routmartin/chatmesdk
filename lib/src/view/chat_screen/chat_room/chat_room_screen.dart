import 'dart:io';
import 'package:chatme/data/chat_room/chat_room_controller.dart';
import 'package:chatme/template/call/call_screen/call_view/draggable_widget.dart';
import 'package:chatme/template/chat_screen/chat_room/chat_room_appbar.dart';
import 'package:chatme/template/chat_screen/chat_room/chat_room_body.dart';
import 'package:chatme/template/chat_screen/chat_room/widget/base_view_chat_me.dart';
import 'package:chatme/template/chat_screen/chat_room/widget/chat_room_textfield.dart';
import 'package:chatme/util/constant/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatRoomMessageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseViewChatMe(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: Platform.isIOS ? 16 : 22),
                ChatRoomAppBar(),
                Expanded(child: ChatRoomBody()),
                AnimatedPadding(
                  padding: MediaQuery.of(context).viewInsets,
                  duration: const Duration(
                    milliseconds: AppConstants.animationDuration100,
                  ),
                  curve: Curves.easeOut,
                  child: ChatRoomTextField(),
                ),
              ],
            ),

            /// This block for listening about you and partner
            GetBuilder<ChatRoomController>(
              init: ChatRoomController(),
              builder: (controller) {
                return controller.isOffVideo
                    ? DraggableWidgetVideoCall(
                        topMargin: 95.0,
                        bottomMargin: Platform.isAndroid ? 88 : 120,
                      )
                    : !controller.isPartner
                        ? DraggableWidgetVideoCall(
                            topMargin: 95.0,
                            bottomMargin: Platform.isAndroid ? 88 : 120,
                          )
                        : SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
