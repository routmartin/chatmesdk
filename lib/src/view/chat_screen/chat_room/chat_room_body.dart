import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../data/chat_room/chat_room.dart';
import '../../../data/chat_room/model/message_response_model.dart';
import '../../../data/sticker_controlller/sticker_controller.dart';
import '../../../util/constant/app_assets.dart';

import '../../../util/helper/media_helper.dart';
import '../../../util/helper/message_helper.dart';
import '../../../util/theme/app_color.dart';
import '../../widget/animated_container.dart';
import '../../widget/no_network_widget.dart';
import '../../widget/scroll_to_bottom_button.dart';
import '../../widget/seperate_line.dart';
import 'widget/message_item.dart';

class ChatRoomBody extends StatefulWidget {
  const ChatRoomBody({
    Key? key,
  }) : super(key: key);

  @override
  State<ChatRoomBody> createState() => _ChatRoomBodyState();
}

class _ChatRoomBodyState extends State<ChatRoomBody> {
  // final GlobalKey _key = GlobalKey();
  bool openPinMessage = false;
  // final ScrollController _pinScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatRoomMessageController>(builder: (controller) {
      List<MessageModel> reversedList = List.from(controller.listMessage.reversed);
      // List<MessageModel> pinList = controller.listPinMessage;
      // int totalPins = controller.listPinMessageTotal;
      bool isAutoScroll = controller.messageIdForAnimationPin != '' || controller.messageIdForAnimationMessage != '';
      return GestureDetector(
        onTap: onChatRoomBodyClick,
        child: Column(
          children: [
            const NetworkConnectionTextWidget(),
            // AnimatedSize(
            //   curve: Curves.linear,
            //   duration: const Duration(milliseconds: 300),
            //   child: pinList.isNotEmpty
            //       ? Container(
            //           key: _key,
            //           height: 40,
            //           margin: const EdgeInsets.only(top: 2),
            //           width: double.maxFinite,
            //           padding: const EdgeInsets.only(left: 2.5),
            //           decoration: BoxDecoration(
            //             color: AppColors.primaryColor,
            //             border: Border(
            //               bottom: BorderSide(
            //                 width: 1,
            //                 color: Colors.grey.shade300,
            //               ),
            //             ),
            //           ),
            //           child: Container(
            //             color: Colors.white,
            //             child: pinnedMessages(context, pinList, reversedList, totalPins),
            //           ),
            //         )
            //       : const SizedBox(),
            // ),
            // Padding(
            //   padding: EdgeInsets.symmetric(vertical: openPinMessage ? 8 : 0),
            //   child: AnimatedSize(
            //     curve: Curves.linear,
            //     duration: const Duration(milliseconds: 200),
            //     child: SingleChildScrollView(
            //       child: Stack(
            //         children: [
            //           Positioned.fill(
            //             child: Visibility(
            //               visible: openPinMessage && controller.pinMessageLoading,
            //               child: const Align(
            //                 alignment: Alignment.bottomCenter,
            //                 child: Padding(
            //                   padding: EdgeInsets.all(2.0),
            //                   child: SizedBox(
            //                       width: 12,
            //                       height: 12,
            //                       child: CircularProgressIndicator.adaptive(
            //                         strokeWidth: 2,
            //                       )),
            //                 ),
            //               ),
            //             ),
            //           )
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            // Visibility(
            //   visible: controller.isBeforeMessageLoadMore,
            //   child: const Padding(
            //     padding: EdgeInsets.all(8.0),
            //     child: CircularProgressIndicator.adaptive(),
            //   ),
            // ),
            Expanded(
              child: Stack(
                children: [
                  controller.isLoading
                      ? const Center(child: CircularProgressIndicator.adaptive())
                      : reversedList.isEmpty
                          ? Center(
                              child: Text(
                                'no_message_here_yet..'.tr,
                                style: const TextStyle(
                                  color: Color(0xff787878),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13.3,
                                ),
                              ),
                            )
                          : ListViewObserver(
                              key: PageStorageKey(controller.roomId),
                              controller: controller.observerController,
                              onObserve: (p0) => onListenScroll(p0),
                              child: ListView.builder(
                                key: PageStorageKey(controller.roomId),
                                controller: controller.scrollListController,
                                padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                                physics: isAutoScroll ? const ClampingScrollPhysics() : const BouncingScrollPhysics(),
                                reverse: true,
                                addAutomaticKeepAlives: true,
                                itemCount: reversedList.length,
                                findChildIndexCallback: (Key key) {
                                  final ValueKey<String?> valueKey = key as ValueKey<String?>;
                                  final index = reversedList.indexWhere((item) => item.id == valueKey.value);
                                  if (index == -1) return null;
                                  return index;
                                },
                                itemBuilder: (context, index) {
                                  return MessageCard(
                                    key: ValueKey(reversedList[index].id),
                                    reversedList: reversedList,
                                    controller: controller,
                                    index: index,
                                  );
                                },
                              ),
                            ),
                  AnimatedOpacity(
                    opacity: openPinMessage ? 0.4 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          openPinMessage = false;
                        });
                      },
                      child: ColoredBox(
                        color: AppColors.black,
                        child: openPinMessage ? const SizedBox.expand() : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  ChatScrollToButtomButton(
                    isShowScrollToBottom: controller.isShowScrollToBottom,
                    inRoomUnreadCountNumber: controller.inRoomUnreadCountNumber,
                    scrollToBottom: controller.scrollToBottom,
                  ),
                ],
              ),
            ),
            Visibility(
                visible: controller.isAfterMessageLoadMore,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator.adaptive(),
                )),
            GetBuilder<ChatRoomMessageController>(
                id: 'replying',
                builder: (controller) {
                  var isUser = controller.accountId == controller.replyMessage?.sender?.id;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: controller.isOnReplying ? 90 : 0,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          width: .3,
                          color: Color(0xff787878),
                        ),
                      ),
                    ),
                    child: Visibility(
                      visible: controller.isOnReplying,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${'replying_to'.tr} ',
                                      style: const TextStyle(fontSize: 13.3),
                                    ),
                                    Expanded(
                                      child: Text(
                                        isUser ? 'Yourself'.tr : controller.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: controller.onCloseReply,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Image.asset(
                                          "packages/chatmesdk/assets/icons/profile_close_circle-button.png",
                                          width: 18,
                                          height: 18,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                _checkReplyMessageType(controller.replyMessage)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ],
        ),
      );
    });
  }

  void onChatRoomBodyClick() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
    Get.find<StickerController>().showPlusFooter = false;
    Get.find<StickerController>().showEmojiFooter = false;
    Get.find<ChatRoomMessageController>().shouldHaveButtonPadding = true;
    Get.find<ChatRoomMessageController>().showFooter = false;
    Get.find<ChatRoomMessageController>().update();
    Get.find<StickerController>().update();
  }

  Widget _checkReplyMessageType(MessageModel? rootReplyMessage) {
    var replyMessage = rootReplyMessage?.refType == 'forward' ? rootReplyMessage!.ref : rootReplyMessage;
    switch (replyMessage?.type) {
      case 'text':
      case 'link':
        return Expanded(
          child: Text(
            replyMessage?.message ?? '',
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.3, color: AppColors.lightGray),
          ),
        );
      case 'voice':
        return Expanded(
          child: Text(
            '<<${'voice'.tr}>>',
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.3, color: AppColors.lightGray),
          ),
        );
      case 'sticker':
        return Row(
          children: [
            Text(
              replyMessage!.sticker!.emoji! + 'sticker'.tr,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.3, color: AppColors.lightGray),
            )
          ],
        );
      case 'contact':
        return Row(
          children: [
            CachedNetworkImage(
              imageUrl: replyMessage!.shareContact!.avatar,
              width: 20,
              height: 20,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Image.asset(
                Assets.app_assetsIconsMyPofileAvatar,
                width: 20,
                height: 20,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'contact'.tr,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.3, color: AppColors.lightGray),
            ),
          ],
        );
      case 'media':
        return Row(
          children: [
            MediaHelper.checkIfMediaImage(replyMessage!.attachments![0])
                ? CachedNetworkImage(
                    imageUrl: replyMessage.attachments![0].url ?? '',
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Image.asset(
                      Assets.app_assetsIconsMyPofileAvatar,
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.file(
                    File(replyMessage.attachments![0].uploadPath ?? ''),
                    height: 20,
                    width: 20,
                    errorBuilder: ((context, error, stackTrace) => Image.asset(
                          Assets.app_assetsIconsMyPofileAvatar,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        )),
                  ),
            const SizedBox(width: 12),
            Text(
              replyMessage.message!.isNotEmpty
                  ? replyMessage.message!
                  : MediaHelper.checkIfMediaImage(replyMessage.attachments![0])
                      ? 'photo'.tr
                      : 'video'.tr,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.3, color: AppColors.lightGray),
            )
          ],
        );
      case 'file':
        return Expanded(
          child: Text(
            replyMessage!.attachments![0].originalName ?? '',
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.3, color: AppColors.lightGray),
          ),
        );
      case 'vows':
        return Expanded(
          child: Text(
            (replyMessage?.call?.isMissedCall ?? false) ? 'missed_audio_call'.tr : 'audio_call'.tr,
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.3, color: AppColors.lightGray),
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget buildTimeStamp(String timeStamp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        // color: Color(0xffE4E6EB),
        borderRadius: BorderRadius.circular(5),
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

  Widget pinnedMessages(
      BuildContext context, List<MessageModel> pinList, List<MessageModel> reversedList, int totalPins) {
    var controller = Get.find<ChatRoomMessageController>();
    int showCurrentPin = controller.selectedPinIndex < 0 ? 1 : controller.selectedPinIndex + 1;
    return InkWell(
      onTap: () async {
        var pinIndex = controller.selectedPinIndex == pinList.length - 1 ? -1 : controller.selectedPinIndex;
        _onSelectPinMessage(reversedList, pinList[pinIndex + 1], pinIndex + 1, true);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Row(
          children: [
            Image.asset(
              Assets.app_assetsIconsPinRight,
              width: 16.0,
              height: 16.0,
              color: AppColors.red,
            ),
            const SizedBox(width: 4),
            Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 70),
                  child: Text(
                    '${controller.selectedPinItem.sender?.name}',
                    style: const TextStyle(
                      color: AppColors.txtSeconddaryColor,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Text(
                  ': ',
                  style: TextStyle(
                    color: AppColors.txtSeconddaryColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (controller.selectedPinItem.id != null)
              Expanded(
                flex: 1,
                child: Text(
                  MessageHelper.checkPinMessageType(controller.selectedPinItem),
                  style: const TextStyle(
                    color: Color(0xFF787878),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(width: 10),
            InkWell(
              onTap: _onTogglePinMessages,
              child: Padding(
                padding: const EdgeInsets.only(right: 15, top: 5, bottom: 5),
                child: Row(
                  children: [
                    Text(
                      '${showCurrentPin.toString()} ${"of".tr} $totalPins',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 13,
                      ),
                    ),
                    Icon(openPinMessage ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTogglePinMessages() {
    setState(() {
      openPinMessage = !openPinMessage;
    });
  }

  void _onSelectPinMessage(List<MessageModel> reversedList, MessageModel data, int index, bool disabledOpenList) async {
    var controller = Get.find<ChatRoomMessageController>();
    controller.indexMessageForScroll = reversedList.indexWhere((element) => element.id == data.id);
    controller.selectedPinItem = data;
    controller.selectedPinIndex = index;
    controller.update();
    setState(() {
      openPinMessage = disabledOpenList ? false : !openPinMessage;
    });
    // found in list
    if (controller.indexMessageForScroll != -1) {
      await MessageHelper.onScrollToMessageIndex(controller, data.id!, isAnimatedMessage: false);
    } else {
      // BaseDialogLoading.show();
      controller.rootMessageDate = data.createdAt!.toIso8601String();
      controller.update();
      String? messageId = await controller.getMessagesBetweenDate();
      if (messageId != null) {
        await MessageHelper.onScrollToMessageIndex(controller, messageId, isAnimatedMessage: false);
      }
      // BaseDialogLoading.dismiss();
    }
  }

  Future<void> onListenScroll(ListViewObserveModel p0) async {
    var controller = Get.find<ChatRoomMessageController>();
    var messageLength = controller.listMessage.length;
    var scrollOffset = p0.firstChild?.scrollOffset ?? 0;
    var scrollIndex = p0.firstChild?.index ?? 0;
    var scrollLastIndex = p0.displayingChildIndexList.last;

    // show scroll to bottom button
    if (scrollOffset > 2000 && !controller.isShowScrollToBottom) {
      setState(() {
        controller.isShowScrollToBottom = true;
      });
    }
    if (scrollOffset < 2000 &&
        controller.isShowScrollToBottom &&
        controller.afterMessageCurrentPage >= controller.afterMessageTotalPage) {
      setState(() {
        controller.isShowScrollToBottom = false;
        controller.inRoomUnreadCountNumber = 0;
      });
    }

    // get more message data
    if (controller.isEnableScrollMore) {
      // trigger when reach top of the list
      if (scrollLastIndex >= messageLength - 3 &&
          !controller.isBeforeMessageLoadMore &&
          !controller.isDisableGetBeforeMessage) {
        controller.getMoreMessagesBeforeDate();
      }
      // trigger when reach bottom of the list
      if (scrollIndex <= 2 && !controller.isAfterMessageLoadMore && !controller.isDisableGetAfterMessage) {
        controller.getMoreMessagesAfterDate();
      }
    }
  }
}

class MessageCard extends StatelessWidget {
  final List<MessageModel> reversedList;
  final ChatRoomMessageController controller;
  final int index;

  const MessageCard({
    Key? key,
    required this.reversedList,
    required this.controller,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String timeStamp = reversedList[index].timeStamp ?? '';
    MessageModel? message = reversedList[index];
    var lastIndex = 0;

    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          if (timeStamp != '') MessageHelper.buildTimeStamp(timeStamp),
          //** */ unread message
          if (controller.unReadMessageCount > 0 && index + 1 == controller.unReadMessageCount)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  const Flexible(child: WidgetBindingSeperateLine()),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Text(
                        'unread_message'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11.3, color: Colors.black // Color(0xff787878),
                            ),
                      ),
                    ),
                  ),
                  const Flexible(child: WidgetBindingSeperateLine()),
                ],
              ),
            ),
          _buildMessage(message, controller, index, lastIndex),
        ],
      ),
    );
  }

  Widget _buildMessage(MessageModel message, ChatRoomMessageController controller, index, lastIndex) {
    var isAnimatedPin = controller.messageIdForAnimationPin == message.id;
    var isAnimatedMessage = controller.messageIdForAnimationMessage == message.id;

    //* not add friend yet
    if (index == lastIndex && message.status == 'reject' && message.rejectCode == 'notfriend') {
      return AnimatedEaseoutMessage(
        keyId: message.id!,
        child: Column(
          children: [
            MessageItem(
              isAnimatedMessage: isAnimatedMessage,
              isAnimatedPin: isAnimatedPin,
              isMulitSelect: controller.isMultiSelection,
              message: message,
              accountId: controller.accountId,
              isGroup: false,
            ),
            Text(
              '${controller.name} ${'hasn’t_added_you_to_contact_yet'.tr}',
              style: const TextStyle(
                fontSize: 13.3,
                color: Color(0xff787878),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'send_a_friend_request_now'.tr,
              style: const TextStyle(
                fontSize: 13.3,
                color: Color(0xff4882B8),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }
    //* block user
    if (index == lastIndex && message.status == 'reject' && message.rejectCode == 'blocked') {
      return AnimatedEaseoutMessage(
        keyId: message.id!,
        child: Column(
          children: [
            MessageItem(
              isAnimatedMessage: isAnimatedMessage,
              isAnimatedPin: isAnimatedPin,
              isMulitSelect: controller.isMultiSelection,
              message: message,
              accountId: controller.accountId,
              isGroup: false,
            ),
            Text(
              'the_message_is_rejected_by_the_receiver'.tr,
              style: const TextStyle(
                fontSize: 13.3,
                color: Color(0xff787878),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    return AnimatedEaseoutMessage(
      keyId: message.id!,
      isDisabledAnimation: index != lastIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MessageItem(
            isAnimatedMessage: isAnimatedMessage,
            isAnimatedPin: isAnimatedPin,
            isMulitSelect: controller.isMultiSelection,
            message: message,
            accountId: controller.accountId,
            isLastMessage: index == 0,
            isGroup: false,
          ),
          //* show message with status
          if (index == lastIndex)
            Transform.translate(
              offset: const Offset(0, -10),
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 12,
                  right: 6,
                ),
                child: _checkSeenSentStatus(
                  message,
                  controller.accountId,
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _checkSeenSentStatus(MessageModel message, String accountId) {
    if (message.isUploading ?? false) {
      return const SizedBox.shrink();
    }
    if (message.sender!.id == accountId) {
      if (message.status == 'sent' && message.isSeen == true) {
        return Text(
          'seen'.tr,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 11.11,
            color: Color(0xff787878),
          ),
        );
      }
      return Text(
        'sent'.tr,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 11.11,
          color: Color(0xff787878),
        ),
      );
    }
    return const SizedBox();
  }
}
