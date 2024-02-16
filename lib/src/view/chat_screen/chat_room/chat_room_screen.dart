import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/chat_room/chat_room.dart';
import '../../../util/constant/app_constant.dart';
import 'chat_room_appbar.dart';
import 'chat_room_body.dart';
import 'widget/chat_room_textfield.dart';

class ChatRoomMessageScreen extends StatefulWidget {
  final String roomId;
  const ChatRoomMessageScreen({super.key, required this.roomId});

  @override
  State<ChatRoomMessageScreen> createState() => _ChatRoomMessageScreenState();
}

class _ChatRoomMessageScreenState extends State<ChatRoomMessageScreen> {
  @override
  void initState() {
    super.initState();
    final controller = Get.put(ChatRoomMessageController());
    controller.roomId = widget.roomId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: Platform.isIOS ? 16 : 10),
            const ChatRoomAppBar(),
            const Expanded(child: ChatRoomBody()),
            AnimatedPadding(
              padding: MediaQuery.of(context).viewInsets,
              duration: const Duration(
                milliseconds: AppConstants.animationDuration100,
              ),
              curve: Curves.easeOut,
              child: const ChatRoomTextField(),
            ),
          ],
        ),
      ),
    );
  }
}
