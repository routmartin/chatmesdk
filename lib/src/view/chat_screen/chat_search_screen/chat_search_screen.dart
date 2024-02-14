import 'package:chatme/template/chat_screen/chat_room/widget/base_view_chat_me.dart';
import 'package:chatme/template/chat_screen/chat_search_screen/chat_search_screen_body.dart';
import 'package:chatme/util/helper/font_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatSearchScreen extends StatelessWidget {
  const ChatSearchScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BaseViewChatMe(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                    child: Text(
                      FontUtil.tr('cancel'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff787878),
                      ),
                    ),
                  ),
                ),
              ),
              ChatSearchScreenBody(),
            ],
          ),
        ),
      ),
    );
  }
}
