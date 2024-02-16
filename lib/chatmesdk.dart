library chatmesdk;

import 'dart:async';

import 'package:chatmesdk/src/data/api_helper/base/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'src/view/chat_screen/chat_room/chat_room_screen.dart';
import 'src/view/chat_screen/chat_room_listing/personal_chat_rooms/person_room_listing_screen.dart';

class Chatmesdk {
  static late String userId;
  static Future initalizer(String token, String userId, openChatUrl) async {
    userId = userId;
    await GetStorage.init();
    await BaseSocket.initSocketConnection(token, openChatUrl!);
    await initializeDateFormatting();
    Get.testMode = true;
  }

  static void navigateToChatList(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext ctx) => const PersonRoomListingScreen()));
  }

  static void navigateToChatroom(String roomId, BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext ctx) => ChatRoomMessageScreen(roomId: roomId)));
  }
}
