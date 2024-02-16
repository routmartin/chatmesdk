// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

import '../../../data/api_helper/storage_token.dart';
import '../../../data/chat_room/chat_room.dart';
import '../../../data/chat_room/model/chat_model/chat_room_model.dart';
import '../../../util/constant/call_enum.dart';
import '../../../util/helper/chat_helper.dart';
import '../../../util/helper/date_time.dart';
import '../../../util/helper/message_helper.dart';
import '../../../util/text_style.dart';
import '../../../util/theme/app_color.dart';
import '../../widget/unread_counter.dart';
import '../chat_room/chat_room_screen.dart';

final convertLinebreak = (String text) {
  return text.replaceAll('\n', ' ');
};
final generateTimeStamp = (ChatRoomModel model) {
  var text = '';
  DateTime? draftTime = DateTime.tryParse(model.draft?.createdAt ?? '');
  DateTime? lastMessageTime = model.lastMessage?.updatedAt;

  if (model.draft?.message == null) {
    text = DateTimeHelper.timeStamp(lastMessageTime);
  } else {
    text = DateTimeHelper.showTime24H(draftTime);
  }

  return Text(text, style: AppTextStyle.smallTextRegularGrey);
};

var generateMessage = (ChatRoomModel _model, bool isFromGroup) {
  bool officialAnnouncement = (_model.isOfficial ?? false) && (_model.lastMessage?.type == 'html');
  if (officialAnnouncement) {
    var title = _model.lastMessage?.htmlContent?.split('</h4>').first ?? '';
    return HtmlWidget(title);
  }

  String messageType = _model.lastMessage?.type ?? '';
  String preText = '';
  String content = '';
  final senderId = _model.lastMessage?.sender?.id ?? '';
  final senderName = _model.lastMessage?.sender?.name ?? '';
  const textStyle = AppTextStyle.smallTextMessage;
  String userId = '';
  bool isMyMessage = false;

  if (senderId == userId) {
    isMyMessage = true;
  }
  // check if render in group or personal
  if (isFromGroup) {
    //check who is sender
    // ignore: unrelated_type_equality_checks
    if (isMyMessage) {
      preText = 'you:'.tr;
    } else if (senderName.isNotEmpty) {
      preText = '$senderName: ';
    } else {
      preText = '';
    }
  } else {
    // ignore: unrelated_type_equality_checks
    if (isMyMessage) {
      preText = '${'you'.tr} ';
    } else if (senderName.isNotEmpty) {
      preText = '';
    }
  }

  //check draft
  if ((_model.draft?.message?.isNotEmpty ?? false) && (_model.draft?.showDraft ?? true)) {
    content = _model.draft?.message ?? 'draft';
    return RichText(
      text: TextSpan(
        text: '${'draft'.tr} : ',
        style: textStyle.copyWith(color: Colors.red),
        children: [
          TextSpan(
            text: convertLinebreak(content),
            style: textStyle,
          ),
        ],
      ),
      maxLines: 1,
    );
    //check unsent message
  } else if (_model.lastMessage?.status == 'unsent') {
    String content;
    if (!isMyMessage && !isFromGroup) {
      content = 'unsent_a_message'.tr;
      content = '$content'.capitalizeFirst ?? '';
    } else if (isFromGroup) {
      content = 'unsent_a_message'.tr;
      content = '$content'.capitalizeFirst ?? '';
      content = ('$preText$content');
    } else {
      content = 'you_unsent_a_message'.tr;
    }
    return Text(
      content,
      style: textStyle,
      maxLines: 1,
    );
    //check forward message
  } else if (_model.lastMessage?.refType == 'forward') {
    var content = 'forward_a_message'.tr;
    if (!isMyMessage && !isFromGroup) {
      content = content.capitalizeFirst ?? '';
    }
    return Text(
      ('$preText$content'),
      style: textStyle,
      maxLines: 1,
    );
  } else {
    switch (messageType) {
      case 'text':
        content = _model.lastMessage?.message ?? '';
        //has mention
        if (_model.lastMessage?.mentions != null && _model.lastMessage!.mentions!.isNotEmpty) {
          return MessageHelper.messageTextParser(
            _model.lastMessage?.message ?? '',
            textStyle,
            _model.lastMessage!.mentions,
            true,
            onClickMention: (id) async {
              await navigateToChatMessage(_model, true);
            },
            mentionStyle: textStyle,
            maxLinesText: 1,
          );
        } else {
          String textContent;
          if (isFromGroup) {
            textContent = '$preText${convertLinebreak(content)}';
          } else {
            textContent = convertLinebreak(content);
          }
          return Text(
            textContent,
            style: textStyle,
            maxLines: 1,
          );
        }
      case 'sticker':
        if (_model.lastMessage?.sticker?.emoji?.isEmpty ?? false) {
          content = ' sticker'.tr;
        }
        content = _model.lastMessage?.sticker?.emoji ?? 'sticker'.tr;
        if (isFromGroup) {
          content = ('$preText$content');
        } else {
          content = (content);
        }
        return Text(
          content,
          style: textStyle,
          maxLines: 1,
        );
      case 'contact':
        content = 'friend_contact'.tr;
        return Text(
          ('$preText$content'),
          style: textStyle,
          maxLines: 1,
        );
      case 'voice':
        content = 'sent_a_voice_message'.tr;
        if (!isMyMessage && !isFromGroup) {
          content = content.capitalizeFirst ?? '';
        } else if (isFromGroup) {
          content = content.capitalizeFirst ?? '';
        }
        return Text(
          ('$preText$content'),
          style: textStyle,
          maxLines: 1,
        );
      case 'media':
        String type = '';
        int mediaLength = _model.lastMessage?.attachments?.length ?? 0;
        if (mediaLength > 0) {
          type = (_model.lastMessage?.attachments!.first['originalName'] ?? '');
        }
        content = 'sent_a_media'.tr;
        if (type.isImageFileName) content = 'sent_a_photo'.tr;
        if (type.isVideoFileName) content = 'sent_a_video'.tr;
        if (type.isAudioFileName) content = 'sent_an_audio'.tr;
        if (mediaLength > 1) content = 'sent_multiple_media'.tr;

        if (!isMyMessage && !isFromGroup) {
          content = content.capitalizeFirst ?? '';
        }
        return Text(
          ('$preText$content'),
          style: textStyle,
          maxLines: 1,
        );
      case 'file':
        if (_model.lastMessage?.attachments!.isNotEmpty ?? false) {
          int fileLength = _model.lastMessage?.attachments?.length ?? 0;
          if (fileLength > 1) {
            content = 'sent_files'.tr;
          } else {
            content = 'sent_a_file'.tr;
          }
        }
        if (!isMyMessage && !isFromGroup) {
          content = content.capitalizeFirst ?? '';
        }
        return Text(
          ('$preText$content'),
          style: textStyle,
          maxLines: 1,
        );

      case 'link':
        return Text(
          _model.lastMessage?.message ?? 'link'.tr,
          maxLines: 1,
          style: textStyle,
          overflow: TextOverflow.ellipsis,
        );
      case 'vows':
        String text = '';
        bool isMissedCall = _model.lastMessage?.call?.isMissedCall ?? false;
        if (isMissedCall) {
          text = isMyMessage
              ? '${_model.name} ${'missed_your_call'.tr}'
              : '${'You'.tr} ${'missed_audio_call'.tr.toLowerCase()}';
        } else {
          text = isMyMessage ? '${'you_called'.tr} ${_model.name}' : '${_model.name} ${'called_you'.tr}';
        }
        return Text(
          text,
          maxLines: 1,
          style: textStyle,
          overflow: TextOverflow.ellipsis,
        );
      default:
        return Text(
          ('$preText${convertLinebreak(content)}'),
          maxLines: 1,
          style: textStyle,
        );
    }
  }
};

final generateLowerTrailing = (ChatRoomModel model) {
  var userId = '';
  var unreadCount = model.unreadCount;
  var messageStatus = model.lastMessage?.status ?? '';
  var senderId = model.lastMessage?.sender?.id ?? '';
  var radius = 10.0;
  bool isHasMention = model.hasMention;
  var hasDraft =
      (model.draft?.message?.isNotEmpty ?? false) || model.draft?.message != null || (model.draft?.showDraft ?? false);
  // * self message
  if (senderId == userId) {
    if (messageStatus == 'reject') {
      return const Icon(
        Icons.error,
        color: Color(0xffCD2525),
      );
    } else if (model.lastMessage?.isSeen ?? false) {
      return Text('seen'.tr);
    } else if (model.unReadCountBiggerThan0 || model.isMarkUnread) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xffCD2525),
      );
    } else if (messageStatus == 'unsent') {
      return Text('sent'.tr);
    } else if (hasDraft) {
      return Text(''.tr);
    } else {
      return Text(messageStatus.tr);
    }
  }

  // * message from other
  else {
    if (model.isMarkUnread) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xffCD2525),
      );
    } else if (isHasMention) {
      return Row(
        children: [
          Flexible(
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '@',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          Flexible(
              child: UnReadCountWidget(
            amount: unreadCount,
            isMute: model.isMuted,
          ))
        ],
      );
    } else if (!model.isMarkUnread && unreadCount > 0) {
      return UnReadCountWidget(
        amount: unreadCount,
        isMute: model.isMuted,
      );
    }
    //*PM required to show seen for the message we send to other
    // else if (model.lastMessage?.isSeen ?? false || model.isMarkUnread) {
    //   return Text('seen'.tr);
    // }

    else {
      if (model.isOfficial ?? false) return const Text('');
      return const Text('');
    }
  }
};

final navigateToChatMessage = (
  ChatRoomModel chatModel,
  bool personalList,
) async {
  var controller = Get.find<ChatRoomController>();
  var chatArugment = [chatModel.id, ''];
  controller.trckRoomIn = chatModel.id ?? '';
  controller.removeUnreadCount(chatModel.id, personalList);
  // await Get.to(
  //   const ChatRoomMessageScreen(),
  //   arguments: chatArugment,
  // )?.then((_) async {
  //   controller.trckRoomIn = '';
  //   await ChatHelper.onTrackRoomOFF();
  //   await Get.find<ChatRoomMessageController>().saveDraftMessage();
  // });
};

final slidableRoomItems = (int index, ChatRoomController controller, BuildContext context,
    GlobalKey<AnimatedListState> key, Animation<double> animation, ChatRoomModel modelMessage, ChatType chatType,
    {required Widget child}) {
  var model = modelMessage;
  var ratio = 0.65;
  var confirmSize = model.confirmSize = Get.width * ratio;
  var groupDisband = model.lastMessage?.message == 'activity.group.disband';
  var buttonSize = model.buttonSize = groupDisband ? Get.width * ratio / 2 : Get.width * ratio / 3;

  model.unReadCountBiggerThan0 = model.unreadCount > 0;
  return StatefulBuilder(builder: ((context, setState) {
    return Slidable(
      key: ValueKey(index),
      groupTag: '1',
      endActionPane: ActionPane(
        extentRatio: ratio,
        motion: const DrawerMotion(),
        children: [
          CustomSlidableAction(
            autoClose: true,
            padding: EdgeInsets.zero,
            onPressed: (BuildContext context) {
              onPressMarkButton(model, index, controller);
            },
            child: Row(
              children: [
                AnimatedSize(
                  curve: Curves.fastOutSlowIn,
                  duration: const Duration(seconds: 1),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    height: double.maxFinite,
                    width: model.showConfirm || groupDisband ? 0 : buttonSize,
                    color: Colors.grey,
                    child: GetBuilder<ChatRoomController>(
                        id: 'markBuilder',
                        builder: (_) {
                          return Text(
                            model.unReadCountBiggerThan0 || model.isMarkUnread
                                ? 'mark_as_read'.tr
                                : 'mark_as_unread'.tr,
                            textAlign: TextAlign.center,
                            style: AppTextStyle.smallTextMediumWhite,
                          );
                        }),
                  ),
                ),
                AbsorbPointer(
                  absorbing: false,
                  child: InkWell(
                    onTap: () async {
                      setState(() {
                        clickHideButton(
                          model,
                          index,
                          controller,
                          context,
                          key,
                          chatType,
                        );
                      });
                    },
                    child: AnimatedSize(
                      curve: Curves.fastOutSlowIn,
                      duration: const Duration(seconds: 1),
                      child: Container(
                        alignment: Alignment.center,
                        height: double.maxFinite,
                        width: model.showConfirm ? confirmSize : buttonSize,
                        color: model.redColor ? Colors.red : Colors.green,
                        child: Text(
                          model.showConfirm ? 'confirm'.tr : 'hide'.tr,
                          style: AppTextStyle.smallTextMediumWhite,
                        ),
                      ),
                    ),
                  ),
                ),
                AbsorbPointer(
                  absorbing: false,
                  child: InkWell(
                    onTap: () async {
                      setState(() {
                        clickDeleteButton(model);
                      });
                    },
                    child: AnimatedSize(
                      curve: Curves.fastOutSlowIn,
                      duration: const Duration(seconds: 1),
                      child: Container(
                        alignment: Alignment.center,
                        height: double.maxFinite,
                        width: model.showConfirm ? 0 : buttonSize,
                        color: Colors.red,
                        child: Text(
                          'delete'.tr,
                          style: AppTextStyle.smallTextMediumWhite,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
      child: SizeTransition(
        key: ValueKey(index),
        sizeFactor: animation,
        child: child,
      ),
    );
  }));
};

Future<void> clickDeleteButton(ChatRoomModel model) async {
  final userAlreadyReadDelete = StorageToken.readWarningDelete();
  if (userAlreadyReadDelete) {
    model.showConfirm = true;
    model.redColor = true;
  } else {
    warningDialog;
    await StorageToken.saveWarningDelete(true);
  }
}

final clickHideButton = (
  ChatRoomModel _model,
  int index,
  ChatRoomController controller,
  BuildContext context,
  GlobalKey<AnimatedListState> key,
  ChatType chatType,
) async {
  final userAlreadyReadHide = StorageToken.readWarningHide();
  if (userAlreadyReadHide) {
    if (_model.showConfirm) {
      await onClickConfirm(_model.redColor, index, controller, _model.id!, key, chatType);
    } else {
      _model.showConfirm = true;
      _model.redColor = false;
    }
  } else {
    warningDialog(context);
    await StorageToken.saveWarningHide(true);
  }
};

final removeItem = (int index, ChatRoomController controller, GlobalKey<AnimatedListState> key, ChatType chatType) {
  // if (chatType == ChatType.all) {
  //   controller.chatRoomList.removeAt(index);
  //   controller.getAllPersonRoom();
  // } else if (chatType == ChatType.group) {
  //   controller.groupRoomList.remove(index);
  //   controller.getAllGroupRoom();
  // }
  key.currentState?.removeItem(
    index,
    (_, animation) {
      return SizeTransition(
        sizeFactor: animation,
        child: const Card(
          elevation: 0,
          margin: EdgeInsets.all(10),
        ),
      );
    },
    duration: const Duration(milliseconds: 500),
  );
};

final onClickConfirm = (bool isDelete, int index, ChatRoomController controller, String roomId,
    GlobalKey<AnimatedListState> key, ChatType chatType) async {
  bool isHaveLastMessage = controller.chatRoomList[index].lastMessage?.id != null;
  if (isDelete && isHaveLastMessage) {
    bool isSuccess = await controller.deleteChatRoom(roomId);
    if (isSuccess) {
      removeItem(index, controller, key, chatType);
    }
    controller.chatRoomList[index].redColor = false;
    controller.chatRoomList[index].showConfirm = false;
  } else {
    bool isSuccess = await controller.hideChatRoom(roomId);
    if (isSuccess) {
      removeItem(index, controller, key, chatType);
    }

    controller.chatRoomList[index].redColor = false;
    controller.chatRoomList[index].showConfirm = false;
  }
};

final onPressMarkButton = (ChatRoomModel model, int index, ChatRoomController controller) {
  var roomId = controller.chatRoomList[index].id!;
  bool isFromGroup = model.type == 'g';
  if (model.unReadCountBiggerThan0 || model.isMarkUnread) {
    controller.markRoomAsRead(roomId, isFromGroup);
  } else {
    controller.markRoomAsUnRead(roomId, isFromGroup);
  }
};

final warningDialog = (BuildContext context) {
  // cupertinoDialog(context,
  //     height: 130,
  //     content: 'the_chat_will_reappear_as_soon_as_there’s_a_new_message.'.tr,
  //     buttonText: 'ok'.tr, onTap: () async {
  //   navigator!.pop(context);
  // });
};

Widget listenSubtypeActionWidget(String text, [ChatRoomModel? model]) {
  var isGroup = model?.type == 'g';
  var listOfPersonTyping = model?.whoTyping?.last ?? [];
  return GetBuilder<ChatRoomController>(
      id: model?.id ?? 'official',
      builder: (context) {
        return DefaultTextStyle(
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w400,
            fontSize: 13.33,
          ),
          child: Expanded(
            child: isGroup ? Text('$listOfPersonTyping ${'is_typing'.tr}') : Text(text),
          ),
        );
      });
}
