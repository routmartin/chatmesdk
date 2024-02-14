import 'package:chatme/data/auth_data/storage_token.dart';
import 'package:chatme/data/chat_room/chat_room_controller.dart';
import 'package:chatme/data/chat_room/chat_room_message_controller.dart';
import 'package:chatme/data/chat_room/model/chat_model/chat_room_model.dart';
import 'package:chatme/data/group_room/group_message_controller.dart';
import 'package:chatme/data/profile/controller/account_user_profile_controller.dart';
import 'package:chatme/routes/app_routes.dart';
import 'package:chatme/util/constant/app_asset.dart';
import 'package:chatme/util/constant/call_enum.dart';
import 'package:chatme/util/helper/chat_helper.dart';
import 'package:chatme/util/helper/date_time.dart';
import 'package:chatme/util/helper/message_helper.dart';
import 'package:chatme/util/text_style.dart';
import 'package:chatme/widgets/call/join_existing_call_button.dart';
import 'package:chatme/widgets/cupertino/cupertino_dialog.dart';
import 'package:chatme/widgets/unread_count_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

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
  final textStyle = AppTextStyle.smallTextMessage;
  Get.lazyPut(() => AccountUserProfileController());
  final userId = Get.find<AccountUserProfileController>().profile?.id ?? '';
  bool _isMyMessage = false;

  if (senderId == userId) {
    _isMyMessage = true;
  }
  // check if render in group or personal
  if (isFromGroup) {
    //check who is sender
    // ignore: unrelated_type_equality_checks
    if (_isMyMessage) {
      preText = 'you:'.tr;
    } else if (senderName.isNotEmpty) {
      preText = '$senderName: ';
    } else {
      preText = '';
    }
  } else {
    // ignore: unrelated_type_equality_checks
    if (_isMyMessage) {
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
    var _content;
    if (!_isMyMessage && !isFromGroup) {
      _content = 'unsent_a_message'.tr;
      _content = '$_content'.capitalizeFirst ?? '';
    } else if (isFromGroup) {
      _content = 'unsent_a_message'.tr;
      _content = '$_content'.capitalizeFirst ?? '';
      _content = ('$preText$_content');
    } else {
      _content = 'you_unsent_a_message'.tr;
    }
    return Text(
      _content,
      style: textStyle,
      maxLines: 1,
    );
    //check forward message
  } else if (_model.lastMessage?.refType == 'forward') {
    var _content = 'forward_a_message'.tr;
    if (!_isMyMessage && !isFromGroup) {
      _content = '$content'.capitalizeFirst ?? '';
    }
    return Text(
      ('$preText$_content'),
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
              if (_model.type == 'g') {
                await navigateToGroupChatMessage(_model, true);
              } else {
                await navigateToChatMessage(_model, true);
              }
            },
            mentionStyle: textStyle,
            maxLinesText: 1,
          );
        } else {
          var _content;
          if (isFromGroup) {
            _content = '$preText${convertLinebreak(content)}';
          } else {
            _content = convertLinebreak(content);
          }
          return Text(
            _content,
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
          content = ('$content');
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
        if (!_isMyMessage && !isFromGroup) {
          content = '$content'.capitalizeFirst ?? '';
        } else if (isFromGroup) {
          content = '$content'.capitalizeFirst ?? '';
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

        if (!_isMyMessage && !isFromGroup) {
          content = '$content'.capitalizeFirst ?? '';
        }
        return Text(
          ('$preText$content'),
          style: textStyle,
          maxLines: 1,
        );
      case 'file':
        if (_model.lastMessage?.attachments!.isNotEmpty ?? false) {
          int _fileLength = _model.lastMessage?.attachments?.length ?? 0;
          if (_fileLength > 1) {
            content = 'sent_files'.tr;
          } else {
            content = 'sent_a_file'.tr;
          }
        }
        if (!_isMyMessage && !isFromGroup) {
          content = '$content'.capitalizeFirst ?? '';
        }
        return Text(
          ('$preText$content'),
          style: textStyle,
          maxLines: 1,
        );
      case 'activity':
        if (_model.lastMessage?.args != null) {
          var _text = MessageHelper.findActivityMessage(
            _model.lastMessage?.message ?? '',
            _model.lastMessage!.args,
          );
          content = _text;
        }
        return Text(
          ('$content'),
          style: textStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
          text = _isMyMessage
              ? '${_model.name} ' + 'missed_your_call'.tr
              : 'You'.tr + ' ' + 'missed_audio_call'.tr.toLowerCase();
        } else {
          text = _isMyMessage ? 'you_called'.tr + ' ' + _model.name : '${_model.name} ' + 'called_you'.tr;
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
  var userId = Get.put(AccountUserProfileController()).profile?.id ?? '';
  var unreadCount = model.unreadCount;
  var messageStatus = model.lastMessage?.status ?? '';
  var senderId = model.lastMessage?.sender?.id ?? '';
  var _radius = 10.0;
  bool _isHasMention = model.hasMention;
  var hasDraft =
      (model.draft?.message?.isNotEmpty ?? false) || model.draft?.message != null || (model.draft?.showDraft ?? false);
  // * self message
  if (senderId == userId) {
    if (model.type == 'g' && model.isCalling) {
      bool isJoinCall = Get.find<ChatRoomController>().audioCallEventState == CallEventEnum.joinCall;
      if (isJoinCall) return SizedBox();
      return JoinExistCallButton(
        fontSize: 10,
        padding: 4,
        onJoinCall: () {},
      );
    } else if (messageStatus == 'reject') {
      return Icon(
        Icons.error,
        color: Color(0xffCD2525),
      );
    } else if (model.lastMessage?.isSeen ?? false) {
      return Text('seen'.tr);
    } else if (model.unReadCountBiggerThan0 || model.isMarkUnread) {
      return CircleAvatar(
        radius: _radius,
        backgroundColor: Color(0xffCD2525),
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
    if (model.type == 'g' && model.isCalling) {
      bool isJoinCall = Get.find<ChatRoomController>().audioCallEventState == CallEventEnum.joinCall;
      if (model.unreadCount > 0) {
        return Row(children: [
          if (!isJoinCall) ...[
            JoinExistCallButton(
              fontSize: 10,
              padding: 4,
              onJoinCall: () {},
            )
          ],
          SizedBox(width: 2),
          UnReadCountWidget(amount: unreadCount, isMute: model.isMuted)
        ]);
      }
      if (isJoinCall) return SizedBox();
      return JoinExistCallButton(
        fontSize: 10,
        padding: 4,
        onJoinCall: () {},
      );
    }
    if (model.isMarkUnread) {
      return CircleAvatar(
        radius: _radius,
        backgroundColor: Color(0xffCD2525),
      );
    } else if (_isHasMention) {
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
              child: Text(
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
      if (model.isOfficial ?? false) return Text('');
      return Text('');
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
  await Get.toNamed(
    Routes.chat_room_message,
    arguments: chatArugment,
  )?.then((_) async {
    controller.trckRoomIn = '';
    await ChatHelper.onTrackRoomOFF();
    await Get.find<ChatRoomMessageController>().saveDraftMessage();
  });
};

final navigateToGroupChatMessage = (ChatRoomModel chatModel, bool personalList) async {
  var _controller = Get.find<ChatRoomController>();
  _controller.removeUnreadCount(chatModel.id, personalList);
  var chatArugment = [chatModel.id, ''];
  _controller.trckRoomIn = chatModel.id ?? '';
  await Get.toNamed(Routes.group_chat_room_message, arguments: chatArugment)?.then((value) async {
    await Get.find<GroupMessageController>().saveDraftMessage();
    await ChatHelper.onTrackRoomOFF();
  });
};

final slidableRoomItems = (int index, ChatRoomController controller, BuildContext context,
    GlobalKey<AnimatedListState> key, Animation<double> animation, ChatRoomModel modelMessage, ChatType chatType,
    {required Widget child}) {
  var _model = modelMessage;
  var ratio = 0.65;
  var confirmSize = _model.confirmSize = Get.width * ratio;
  var groupDisband = _model.lastMessage?.message == 'activity.group.disband';
  var buttonSize = _model.buttonSize = groupDisband ? Get.width * ratio / 2 : Get.width * ratio / 3;

  _model.unReadCountBiggerThan0 = _model.unreadCount > 0;
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
              onPressMarkButton(_model, index, controller);
            },
            child: Row(
              children: [
                AnimatedSize(
                  curve: Curves.fastOutSlowIn,
                  duration: const Duration(seconds: 1),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    height: double.maxFinite,
                    width: _model.showConfirm || groupDisband ? 0 : buttonSize,
                    color: Colors.grey,
                    child: GetBuilder<ChatRoomController>(
                        id: 'markBuilder',
                        builder: (_) {
                          return Text(
                            _model.unReadCountBiggerThan0 || _model.isMarkUnread
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
                          _model,
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
                        width: _model.showConfirm ? confirmSize : buttonSize,
                        color: _model.redColor ? Colors.red : Colors.green,
                        child: Text(
                          _model.showConfirm ? 'confirm'.tr : 'hide'.tr,
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
                        clickDeleteButton(_model);
                      });
                    },
                    child: AnimatedSize(
                      curve: Curves.fastOutSlowIn,
                      duration: const Duration(seconds: 1),
                      child: Container(
                        alignment: Alignment.center,
                        height: double.maxFinite,
                        width: _model.showConfirm ? 0 : buttonSize,
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

Future<void> clickDeleteButton(ChatRoomModel _model) async {
  final userAlreadyReadDelete = StorageToken.readWarningDelete();
  if (userAlreadyReadDelete) {
    _model.showConfirm = true;
    _model.redColor = true;
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
        child: Card(
          elevation: 0,
          margin: const EdgeInsets.all(10),
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
  cupertinoDialog(context,
      height: 130,
      content: 'the_chat_will_reappear_as_soon_as_there’s_a_new_message.'.tr,
      buttonText: 'ok'.tr, onTap: () async {
    navigator!.pop(context);
  });
};

Widget listenSubtypeActionWidget(String text, [ChatRoomModel? model]) {
  var isGroup = model?.type == 'g';
  var listOfPersonTyping = model?.whoTyping?.last ?? [];
  return GetBuilder<ChatRoomController>(
      id: model?.id ?? 'official',
      builder: (context) {
        return DefaultTextStyle(
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w400,
            fontSize: 13.33,
          ),
          child: Expanded(
            child: isGroup ? Text('$listOfPersonTyping ' + 'is_typing'.tr) : Text(text),
          ),
        );
      });
}
