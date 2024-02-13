import 'dart:developer';
import 'package:get/get.dart';

import '../../data/api_helper/base/base.dart';
import '../../data/api_helper/storage_token.dart';
import '../../data/chat_room/chat_room.dart';
import 'crash_report.dart';

/// this class use to same block of code that use for both personal and group chat
/// this class use to same block of code that use for both personal and group chat
class ChatHelper {
  static String stickerNameAndDescription(dynamic item) {
    if (item == null) return '';
    try {
      if (isEnglish) {
        return item.first.value ?? 'n/a';
      } else {
        return item[1].value ?? 'n/a';
      }
    } catch (e) {
      final message = e.toString();
      CrashReport.send(ReportModel(message: message));
      return '';
    }
  }

  static Future<void> onTrackRoomON(String roomId) async {
    var request = {
      'body': {'roomId': roomId}
    };
    try {
      var messageSokcet = await BaseSocket.initConnectWithHeader(SocketPath.message);
      messageSokcet.emitWithAck(
        SocketPath.trackWhichRoomUserOn,
        request,
        ack: (result) async {
          Get.find<ChatRoomController>().trckRoomIn = roomId;
          log(result.toString(), name: 'trackroom');
        },
      );
    } catch (_) {
      rethrow;
    }
  }

  static Future<void> onTrackRoomOFF() async {
    var request = {
      'body': {'roomId': null}
    };
    try {
      var messageSokcet = await BaseSocket.initConnectWithHeader(SocketPath.message);
      messageSokcet.emitWithAck(
        SocketPath.trackWhichRoomUserOn,
        request,
        ack: (result) async {
          log(result.toString(), name: 'trackroom');
          Get.find<ChatRoomController>().trckRoomIn = '';
        },
      );
    } catch (_) {
      rethrow;
    }
  }

  static final bool _isEnglish = StorageToken.readLanguageChosen() == 'en';
  static bool get isEnglish => _isEnglish;
}
