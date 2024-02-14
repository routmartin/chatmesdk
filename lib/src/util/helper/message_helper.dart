import 'dart:developer';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audio_session/audio_session.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/chat_room/model/message_response_model.dart';
import 'date_time.dart';
import 'method_channel_helper.dart';

class MessageHelper {
  static final assetsAudioPlayer = AssetsAudioPlayer();

  static Future<void> setAudioSessionOn() async {
    final session = await AudioSession.instance;
    try {
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker,
      ));
      await session.setActive(true);
    } catch (e) {
      if (kDebugMode) {
        print('setAudioSession catch: $e');
      }
    }
  }

  static Future<void> setAudioSessionOff() async {
    final session = await AudioSession.instance;
    try {
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      ));
      await session.setActive(true);
    } catch (e) {
      if (kDebugMode) {
        print('setAudioSession catch: $e');
      }
    }
  }

  static void playMessageSentSound() async {
    var isSilent = await checkSilentMode();
    if (!isSilent && isSoundSettingTurnOn()) {
      if (GetPlatform.isIOS) {
        await MethodChannelHelper.setAudioSessionActive(false);
      }
      await assetsAudioPlayer.open(Audio('assets/sent.wav'));
    }
  }

  static void playMessageReceivedSound() async {
    var isSilent = await checkSilentMode();
    if (!isSilent && isSoundSettingTurnOn()) {
      if (GetPlatform.isIOS) {
        await MethodChannelHelper.setAudioSessionActive(false);
      }
      await assetsAudioPlayer.open(Audio('assets/receive.wav'));
    }
  }

  static Future<void> endCallSound() async {
    if (GetPlatform.isIOS) {
      await MethodChannelHelper.setAudioSessionActive(false);
    }
    await assetsAudioPlayer.open(Audio('assets/end_call_sound.mp3'));
  }

  static void connectingCallSound() async {
    await assetsAudioPlayer.open(Audio('assets/connecting.mp3'));
  }

  static Future<void> setPlayerOutput({required bool isSpeaker}) async {
    await assetsAudioPlayer.pause();
    final avAudioSession = GetPlatform.isIOS ? AVAudioSession() : null;
    final androidAudioManager = GetPlatform.isAndroid ? AndroidAudioManager() : null;
    if (GetPlatform.isIOS) {
      await avAudioSession?.setActive(false);
      await avAudioSession?.setCategory(
        AVAudioSessionCategory.playAndRecord,
        AVAudioSessionCategoryOptions.mixWithOthers,
        AVAudioSessionMode.defaultMode,
        AVAudioSessionRouteSharingPolicy.defaultPolicy,
      );
      await avAudioSession
          ?.overrideOutputAudioPort(isSpeaker ? AVAudioSessionPortOverride.speaker : AVAudioSessionPortOverride.none);
      await Future.delayed(const Duration(milliseconds: 300));
      await avAudioSession?.setActive(true);
    } else {
      await androidAudioManager?.setSpeakerphoneOn(isSpeaker);
      if (isSpeaker) {
        await androidAudioManager?.setMode(AndroidAudioHardwareMode.inCommunication);
      } else {
        await androidAudioManager?.setMode(AndroidAudioHardwareMode.normal);
      }
    }
    await assetsAudioPlayer.play();
  }

  static Future<void> ringingSound() async {
    if (GetPlatform.isIOS) {
      await MethodChannelHelper.setAudioSessionActive(false);
    }
    await assetsAudioPlayer.open(
      Audio('assets/ringing_sound.mp3'),
      showNotification: false,
      notificationSettings: const NotificationSettings(
        playPauseEnabled: false,
        nextEnabled: false,
        prevEnabled: false,
        stopEnabled: false,
        seekBarEnabled: false,
      ),
      loopMode: LoopMode.single,
    );
    // default to earpiece
    await setPlayerOutput(isSpeaker: false);
  }

  static void messageVibration() async {
    if (checkVibrationSettingTurnOn()) {
      await HapticFeedback.vibrate();
    }
  }

  static void longPressVibration() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      log(e.toString(), name: 'vibrate');
    }
  }

  static void moveToDeleteVoiceVibration() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      log(e.toString(), name: 'vibrate');
    }
  }

  static Future<bool> checkSilentMode() async {
    bool isTrue = false;
    RingerModeStatus ringerStatus = await SoundMode.ringerModeStatus;
    switch (ringerStatus) {
      case RingerModeStatus.normal:
        isTrue = false;
        break;
      case RingerModeStatus.silent:
      case RingerModeStatus.vibrate:
      case RingerModeStatus.unknown:
      default:
        isTrue = true;
        break;
    }

    return isTrue;
  }

  static List<String> messageSplitStringByLength(String str, int length) {
    List<String> data = [];
    data.add(str.substring(0, length));
    data.add(str.substring(length));
    return data;
  }

  static bool messageEmojiTwo(String emojiMessage) {
    bool isTwo = false;
    if (emojiMessage.length > 4) {
      return isTwo;
    } else {
      var regex = RegExp(
          r'(?:[\u00A9\u00AE\u203C\u2049\u2122\u2139\u2194-\u2199\u21A9-\u21AA\u231A-\u231B\u2328\u23CF\u23E9-\u23F3\u23F8-\u23FA\u24C2\u25AA-\u25AB\u25B6\u25C0\u25FB-\u25FE\u2600-\u2604\u260E\u2611\u2614-\u2615\u2618\u261D\u2620\u2622-\u2623\u2626\u262A\u262E-\u262F\u2638-\u263A\u2640\u2642\u2648-\u2653\u2660\u2663\u2665-\u2666\u2668\u267B\u267F\u2692-\u2697\u2699\u269B-\u269C\u26A0-\u26A1\u26AA-\u26AB\u26B0-\u26B1\u26BD-\u26BE\u26C4-\u26C5\u26C8\u26CE-\u26CF\u26D1\u26D3-\u26D4\u26E9-\u26EA\u26F0-\u26F5\u26F7-\u26FA\u26FD\u2702\u2705\u2708-\u270D\u270F\u2712\u2714\u2716\u271D\u2721\u2728\u2733-\u2734\u2744\u2747\u274C\u274E\u2753-\u2755\u2757\u2763-\u2764\u2795-\u2797\u27A1\u27B0\u27BF\u2934-\u2935\u2B05-\u2B07\u2B1B-\u2B1C\u2B50\u2B55\u3030\u303D\u3297\u3299]|(?:\uD83C[\uDC04\uDCCF\uDD70-\uDD71\uDD7E-\uDD7F\uDD8E\uDD91-\uDD9A\uDDE6-\uDDFF\uDE01-\uDE02\uDE1A\uDE2F\uDE32-\uDE3A\uDE50-\uDE51\uDF00-\uDF21\uDF24-\uDF93\uDF96-\uDF97\uDF99-\uDF9B\uDF9E-\uDFF0\uDFF3-\uDFF5\uDFF7-\uDFFF]|\uD83D[\uDC00-\uDCFD\uDCFF-\uDD3D\uDD49-\uDD4E\uDD50-\uDD67\uDD6F-\uDD70\uDD73-\uDD7A\uDD87\uDD8A-\uDD8D\uDD90\uDD95-\uDD96\uDDA4-\uDDA5\uDDA8\uDDB1-\uDDB2\uDDBC\uDDC2-\uDDC4\uDDD1-\uDDD3\uDDDC-\uDDDE\uDDE1\uDDE3\uDDE8\uDDEF\uDDF3\uDDFA-\uDE4F\uDE80-\uDEC5\uDECB-\uDED2\uDEE0-\uDEE5\uDEE9\uDEEB-\uDEEC\uDEF0\uDEF3-\uDEF6]|\uD83E[\uDD10-\uDD1E\uDD20-\uDD27\uDD30\uDD33-\uDD3A\uDD3C-\uDD3E\uDD40-\uDD45\uDD47-\uDD4B\uDD50-\uDD5E\uDD80-\uDD91\uDDC0]))');
      if (regex.hasMatch(emojiMessage)) {
        isTwo = true;
        return isTwo;
      }
    }
    return isTwo;
  }

  static void debounceAction(VoidCallback method) {
    EasyDebounce.debounce(
      'typingDebounce',
      const Duration(milliseconds: 200),
      () => method(),
    );
  }

  static String messageOnlineDateTimeFormat(String dateTime) {
    var now = DateTime.now();
    var diff = now.difference(DateTime.parse(dateTime));
    var lastOnline = '';
    if (diff.inDays < 1) {
      if (diff.inMinutes < 1) {
        return '${'a_few_seconds'.tr} ${'ago'.tr}';
      }
      if (diff.inHours < 1) {
        lastOnline = '${diff.inMinutes} ${'minute'.tr} ${'ago'.tr}';
      } else if (diff.inHours < 23) {
        lastOnline = '${diff.inHours} ${'hours'.tr} ${'ago'.tr}';
      } else {
        lastOnline = 'yesterday'.tr;
      }
    } else {
      final date = DateTime.parse(dateTime).toLocal();
      lastOnline = DateTimeHelper.showShortDate(date.toString());
    }
    return lastOnline;
  }

  static bool isSoundSettingTurnOn() {
    // return Get.find<AccountUserProfileController>().profile?.setting?.isAllowSoundAlert ?? false;
    return true;
  }

  static bool checkVibrationSettingTurnOn() {
    // return Get.find<AccountUserProfileController>().profile?.setting?.isAllowVibrate ?? false;
    return true;
  }

  static String checkPinMessageType(MessageModel model) {
    if (model.message != '') {
      return model.message!;
    } else if (model.type == 'sticker') {
      return '[${"sticker".tr}]';
    } else if (model.type == 'media') {
      if (model.attachments?.length == 1) {
        String url = model.attachments!.first.url ?? '';
        return url.isImageFileName ? '[${"photo".tr}]' : '[${"video".tr}]';
      }
      return '[${"media".tr}]';
    } else if (model.type == 'voice') {
      return '[${"voice".tr}]';
    } else {
      return '[${"file".tr}]';
    }
  }

  static List<MessageModel> onGetMessageListWithTimeStamp(List<MessageModel> rawList) {
    var groupListByTime = groupBy(rawList, (MessageModel message) {
      return DateTimeHelper.generateMessageWithTimeStamp(message, rawList);
    });
    List<MessageModel> newSortedList = [];
    DateTime lastMessageDate = DateTime.now();
    for (var entry in groupListByTime.entries) {
      var timeStamp = entry.key;
      var mesages = entry.value;
      for (int i = 0; i < mesages.length; i++) {
        if (i == 0) {
          var messageDate =
              DateFormat('yyyy-MM-dd HH:mm:ss', 'zh').parse(mesages[i].createdAt!.toString(), true).toLocal();
          int diffMinutes = messageDate.difference(lastMessageDate).inMinutes;
          if (diffMinutes < 0 || diffMinutes > 5) {
            lastMessageDate = messageDate;
          } else {
            timeStamp = '';
          }
        }

        var addedTimeStampMessage = mesages[i];
        addedTimeStampMessage.timeStamp = i == 0 ? timeStamp : '';
        newSortedList.add(addedTimeStampMessage);
      }
    }
    return newSortedList;
  }

  // Make sure you have set indexMessageForScroll value correctly before call this function
  static Future<void> onScrollToMessageIndex(var controller, String messageId,
      {bool isJumpTo = false, bool isAnimatedPin = true, bool isAnimatedMessage = true}) async {
    // set to false temporary to prevent auto scroll
    controller.isEnableScrollMore = false;
    controller.update();
    // set messageId and then reset for animation
    if (isAnimatedPin) {
      controller.messageIdForAnimationPin = messageId;
    }
    if (isAnimatedMessage) {
      controller.messageIdForAnimationMessage = messageId;
    }
    controller.update();
    // var maxIndex = controller.listMessage.length - 1;
    // var scrollPositionAdded = 0;
    // if (maxIndex - controller.indexMessageForScroll > 2) {
    //   scrollPositionAdded = 1;
    // }
    if (controller.indexMessageForScroll != -1) {
      if (isJumpTo) {
        controller.observerController.jumpTo(
          index: controller.indexMessageForScroll,
          offset: (targetOffset) {
            // move to center of screen
            return Get.height * .3;
          },
        );
      } else {
        await controller.observerController.animateTo(
          index: controller.indexMessageForScroll,
          duration: const Duration(milliseconds: 150),
          curve: Curves.ease,
          offset: (targetOffset) {
            // move to center of screen
            return Get.height * .3;
          },
        );
      }
    }
    await Future.delayed(const Duration(milliseconds: 200));
    controller.messageIdForAnimationPin = '';
    controller.messageIdForAnimationMessage = '';
    controller.isEnableScrollMore = true;
    controller.update();
  }

  static bool checkIfUserId(String id) {
    RegExp exp = RegExp(r'^[0-9a-fA-F]{24}$');
    bool isUserId = exp.hasMatch(id);
    return isUserId;
  }

  static Widget messageTextParser(
    String message,
    TextStyle style,
    List<Mention>? mentions,
    bool isReplyMessage, {
    Function(String id)? onClickMention,
    TextStyle? mentionStyle,
    int? maxLinesText,
  }) {
    const style0 = TextStyle(
      color: Color(0xff193D82),
      fontSize: 15.33,
      height: 1.4,
      decoration: TextDecoration.underline,
    );
    const styleMention = TextStyle(
      color: Colors.white,
      fontSize: 15.33,
      height: 1.4,
      fontWeight: FontWeight.w700,
    );
    return ParsedText(
      text: message,
      maxLines: maxLinesText ?? (isReplyMessage ? 2 : null),
      style: style,
      textWidthBasis: TextWidthBasis.longestLine,
      parse: <MatchText>[
        MatchText(
          type: ParsedType.CUSTOM,
          pattern: r'@([a-fA-F0-9_]{24})(?!\w)',
          style: mentionStyle ?? styleMention,
          onTap: (str) async {
            String mentionID = str.substring(1);
            if (mentions!.isNotEmpty) {
              var mentionObj = mentions.firstWhere(
                (element) => element.id == mentionID,
                orElse: () => Mention(id: '', name: ''),
              );
              if (onClickMention != null && mentionObj.id != '') {
                onClickMention(mentionObj.id);
              }
            }
          },
          renderText: ({String? str, String? pattern}) {
            String mentionID = str!.substring(1);
            Map<String, String> map = <String, String>{};
            if (mentions!.isNotEmpty) {
              var mentionObj = mentions.firstWhere(
                (element) => element.id == mentionID,
                orElse: () => Mention(id: '', name: ''),
              );
              var displayName =
                  mentionObj.id == '' ? str : '@${mentionObj.name.trimRight().replaceAll(RegExp(' '), '_')}';
              map['display'] = displayName;
              map['value'] = str;
            } else {
              map['display'] = str;
              map['value'] = str;
            }
            return map;
          },
        ),
        MatchText(
            type: ParsedType.EMAIL,
            style: style0,
            onTap: (params) {
              var url = Uri.parse('mailto:$params');
              launchUrl(url);
            }),
        // Link (Url)
        MatchText(
            type: ParsedType.CUSTOM,
            pattern:
                r'[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+-~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.,!%~#?&\/\/=]*)',
            style: style0,
            onTap: (params) async {
              var checkUrl = params.toLowerCase().startsWith('http') ? params : 'https://$params';
              var url = Uri.parse(checkUrl);
              var can = await canLaunchUrl(url);
              if (can) {
                await launchUrl(url);
              }
            }),
        MatchText(
            type: ParsedType.PHONE,
            style: style0,
            onTap: (params) async {
              var url = Uri.parse('tel:$params');
              var can = await canLaunchUrl(url);
              if (can) {
                await launchUrl(url);
              }
            }),
        MatchText(
            type: ParsedType.CUSTOM,
            pattern: r'(\+?( |-|\.)?\d{1,5}( |-|\.)?)?(\(?\d{3}\)?|\d{2,3})( |-|\.)?(\d{2,3}( |-|\.)?\d{2,4})',
            style: style0,
            onTap: (params) async {
              var url = Uri.parse('tel:$params');
              var can = await canLaunchUrl(url);
              if (can) {
                await launchUrl(url);
              }
            }),
      ],
    );
  }

  static String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    int minutes = duration.inMinutes;
    int remainingSeconds = seconds - (minutes * 60);
    String formattedDuration = '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    return formattedDuration;
  }

  static Widget buildTimeStamp(String timeStamp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 12,
      ),
      child: Text(
        timeStamp,
        style: const TextStyle(
          color: Color(0xff787878),
          fontSize: 11.11,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
