import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'model/attachment_model.dart';
import 'model/message_response_model.dart';

class ChatRoomViewMediaController extends GetxController {
  List<AttachmentModel>? selectFiles = [];
  int selectIndex = 0;
  late PageController pageController;
  late bool isGroup;
  late bool isFromSearch;
  late MessageModel messageItem;
  @override
  void onInit() {
    selectFiles = Get.arguments[0];
    selectIndex = Get.arguments[1];
    isGroup = Get.arguments[2];
    isFromSearch = Get.arguments[3];
    messageItem = Get.arguments[4];
    pageController = PageController(viewportFraction: 1, initialPage: selectIndex);
    super.onInit();
  }
}
