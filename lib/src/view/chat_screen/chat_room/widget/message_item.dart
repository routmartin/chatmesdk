// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatme/data/add_friend/controller/add_friend_by_search_controller.dart';
import 'package:chatme/data/chat_room/chat_room_controller.dart';
import 'package:chatme/data/chat_room/chat_room_message_controller.dart';
import 'package:chatme/data/chat_room/model/attachment_model.dart';
import 'package:chatme/data/chat_room/model/message_response_model.dart';
import 'package:chatme/data/group_room/group_message_controller.dart';
import 'package:chatme/data/profile/controller/account_user_profile_controller.dart';
import 'package:chatme/data/sticker_controlller/sticker_controller.dart';
import 'package:chatme/routes/app_routes.dart';
import 'package:chatme/template/chat_screen/chat_room/chat_room_forward_screen.dart';
import 'package:chatme/template/chat_screen/chat_room/chat_room_view_media_screen.dart';
import 'package:chatme/template/chat_screen/chat_room/view_file_screen.dart';
import 'package:chatme/template/chat_screen/chat_room/widget/message_popup_button.dart';
import 'package:chatme/util/constant/app_asset.dart';
import 'package:chatme/util/helper/cache_mananger_helper.dart';
import 'package:chatme/util/helper/chat_helper.dart';
import 'package:chatme/util/helper/date_time.dart';
import 'package:chatme/util/helper/media_helper.dart';
import 'package:chatme/util/helper/message_helper.dart';
import 'package:chatme/util/helper/message_upload_helper.dart';
import 'package:chatme/util/helper/util.dart';
import 'package:chatme/util/text_style.dart';
import 'package:chatme/widgets/cupertino/icon_dialog.dart';
import 'package:chatme/widgets/custom_button/custom_button2.dart';
import 'package:chatme/widgets/fair_binding_widget/widget_binding_profile_radius.dart';
import 'package:chatme/widgets/fair_binding_widget/widget_binding_selection.dart';
import 'package:chatme/widgets/highlight_text.dart';
import 'package:chatme/widgets/loading/base_dialog_loading.dart';
import 'package:chatme/widgets/voice_chat_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:mime/mime.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:dio/dio.dart' as dio;

import '../../../../util/helper/link_helper.dart';

class MessageItem extends StatefulWidget {
  final MessageModel message;
  final isMulitSelect;
  final String accountId;
  final bool isLastMessage;
  final bool isGroup;
  final bool isAnimatedPin;
  final bool isAnimatedMessage;

  MessageItem({
    Key? key,
    required this.message,
    required this.accountId,
    required this.isGroup,
    this.isLastMessage = false,
    this.isMulitSelect,
    this.isAnimatedPin = false,
    this.isAnimatedMessage = false,
  }) : super(key: key);

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  // CustomPopupMenuController? contextMenuController;
  var sendingFail = true;
  var messageStatus = 'sent'.tr;
  double animatedPinIcon = 1.0;
  double animatedMessageOpacity = 1;

  bool _isShowGroupSeenUser = false;

  final leftMediaWidthSize = Get.width / 1.5;
  final rightMediaWidthSize = Get.width / 1.5;

  List<MessageOptionMenu> menuItems = [
    MessageOptionMenu('select'.tr, Icons.check_circle_outline, ContextMenu.select),
    MessageOptionMenu('copy'.tr, Icons.content_copy, ContextMenu.copy),
    MessageOptionMenu('reply'.tr, Icons.undo_outlined, ContextMenu.reply),
    MessageOptionMenu('forward'.tr, Icons.redo_outlined, ContextMenu.forward),
    MessageOptionMenu('delete'.tr, Icons.delete_outline, ContextMenu.delete),
  ];

  @override
  void initState() {
    super.initState();
    // contextMenuController = CustomPopupMenuController();
    if (widget.message.isPinned == false) {
      menuItems.insert(2, MessageOptionMenu('pin'.tr, Icons.push_pin, ContextMenu.pin));
    } else {
      menuItems.insert(2, MessageOptionMenu('unpin'.tr, Icons.push_pin, ContextMenu.unpin));
    }
    _checkIfSentFaild();
  }

  @override
  void dispose() {
    super.dispose();
    // contextMenuController!.dispose();
  }

  @override
  void didUpdateWidget(covariant MessageItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimatedPin != oldWidget.isAnimatedPin) {
      _onPinIconBounce();
    }
    if (widget.isAnimatedMessage != oldWidget.isAnimatedMessage) {
      _onAnimatedOpacityMessage();
    }
    if (widget.message.isPinned == oldWidget.message.isPinned) {
      if (widget.message.isPinned == false) {
        menuItems[2] = MessageOptionMenu('pin'.tr, Icons.push_pin, ContextMenu.pin);
      } else {
        menuItems[2] = MessageOptionMenu('unpin'.tr, Icons.push_pin, ContextMenu.unpin);
      }
    }
  }

  void _onPinIconBounce() async {
    for (int i = 0; i < 6; i++) {
      setState(() {
        animatedPinIcon = animatedPinIcon == 1 ? 1.5 : 1;
      });
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  void _onAnimatedOpacityMessage() async {
    for (int i = 0; i < 4; i++) {
      setState(() {
        animatedMessageOpacity = animatedMessageOpacity == 1 ? 0 : 1;
      });
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  bool _checkIfSentByMe() {
    if (widget.message.sender!.id == widget.accountId) return true;
    return false;
  }

  bool _checkIfMessageReplyByMe() {
    if (widget.message.ref!.sender!.id == widget.accountId) return true;
    return false;
  }

  String _checkMessageType() {
    if (widget.message.status == 'unsent') return 'unsent';
    if (widget.message.refType == null) return 'message';
    if (widget.message.refType == 'reply') return 'reply';
    if (widget.message.refType == 'forward') return 'forward';
    return 'message';
  }

  bool _checkIfSentFaild() {
    if (widget.message.status == 'reject') return true;
    return false;
  }

  dynamic _checkIfMessageInGroup() {
    if (widget.isGroup) return Get.find<GroupMessageController>();
    return Get.find<ChatRoomMessageController>();
  }

  void _onTapOnReplyMessage() async {
    dynamic controller = widget.isGroup ? Get.find<GroupMessageController>() : Get.find<ChatRoomMessageController>();
    List<MessageModel> reversedList = List.from(controller.listMessage.reversed);
    controller.indexMessageForScroll = reversedList.indexWhere((element) => element.id == widget.message.ref!.id);
    controller.update();
    // found in list
    if (controller.indexMessageForScroll != -1) {
      await MessageHelper.onScrollToMessageIndex(controller, widget.message.ref!.id!,
          isAnimatedPin: false, isJumpTo: false);
    } else {
      BaseDialogLoading.show();
      controller.rootMessageDate = widget.message.ref!.createdAt!.toIso8601String();
      controller.update();
      String? messageId = await controller.getMessagesBetweenDate();
      if (messageId != null) {
        await MessageHelper.onScrollToMessageIndex(controller, messageId, isAnimatedPin: false, isJumpTo: false);
      }
      BaseDialogLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 15,
        bottom: 16,
      ),
      child: widget.isMulitSelect
          ? InkWell(
              onTap: () {
                if (widget.isMulitSelect) {
                  _onRadioButtonSelect(widget.message.id);
                }
              },
              child: _musicRow(),
            )
          : _musicRow(),
    );
  }

  Widget _musicRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetBindngSelection(
          isWidgetShow: widget.isMulitSelect,
          isSelected: widget.message.isSelect!,
          onChanged: () => _onRadioButtonSelect(widget.message.id),
        ),
        _buildMessageSwitcher(),
      ],
    );
  }

  Widget _buildMessageSwitcher() {
    return _checkIfSentByMe() ? _checkRightMessage() : _checkLeftMessage();
  }

  //* Open Left message section
  Widget _checkLeftMessage() {
    switch (_checkMessageType()) {
      case 'unsent':
        return Expanded(child: Row(children: [_buildUnsentMessage(isLeftMessage: true)]));
      case 'reply':
        return _buildLeftReplyMessage();
      case 'forward':
        return _buildLeftForwardMessage();
      case 'message':
      default:
        return _buildLeftMessageWidget();
    }
  }

  Widget leftMessageUserName() {
    if (!widget.isGroup) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(
        left: 46.0,
        bottom: 4.0,
      ),
      child: Text(
        widget.message.sender?.name ?? '',
        style: TextStyle(color: Color(0xFF787878), fontSize: 12),
      ),
    );
  }

  Widget _animatedOpacityWidget(Widget child) {
    return AnimatedOpacity(
      // opacity: animatedMessageOpacity,
      opacity: 1,
      duration: const Duration(milliseconds: 500),
      child: child,
    );
  }

  Widget _pinIconWidget(bool isLeftMessage) {
    var isPinned = widget.message.isPinned ?? false;
    return Visibility(
      visible: isPinned,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AnimatedScale(
          scale: animatedPinIcon,
          duration: const Duration(milliseconds: 500),
          child: Transform.scale(
            scaleX: isLeftMessage ? -1 : 1,
            child: Image.asset(
              Assets.app_assetsIconsPinRight,
              width: 30,
              height: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftMessageWidget() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leftMessageUserName(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _navigateToViewContact(widget.message.sender!.profileId!),
                child: WidgetBindingProfileRadius(
                  borderRadius: 8,
                  size: 40,
                  avatarUrl: widget.message.sender!.avatar ?? '',
                  isActive: false,
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: MessagePopupButton(
                          direction: PopupDirection.top,
                          offset: Offset.zero,
                          child: _animatedOpacityWidget(_checkLeftMessageType(widget.message)),
                          builder: (context, onClose) {
                            return Material(
                                elevation: 0.01, child: FittedBox(child: _buildLongPressMenu(false, onClose)));
                          },
                        ),
                      ),
                    ),
                    _pinIconWidget(true)
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeftReplyMessage() {
    bool isForwardRef = widget.message.ref?.refType == 'forward';
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.app_assetsIconsReplyIcon,
                      width: 12,
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Row(
                        children: [
                          Text(
                            widget.message.sender!.name! + ' ',
                            style: TextStyle(
                              fontSize: 13.3,
                              color: Color(0xffACACAC),
                            ),
                          ),
                          Text(
                            'replied_to'.tr + ' ',
                            style: TextStyle(
                              fontSize: 13.3,
                              color: Color(0xffACACAC),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // TODO: check reply to themselve
                    Text(
                      _checkIfMessageReplyByMe()
                          ? 'you'.tr
                          : widget.isGroup
                              ? widget.message.ref?.sender?.name ?? ''
                              : 'themself'.tr,
                      style: TextStyle(
                        fontSize: 13.3,
                        color: Color(0xffACACAC),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: _onTapOnReplyMessage,
                  child: Opacity(
                      opacity: .6,
                      child: Stack(
                        children: [
                          _checkLeftReplyMessageType(isForwardRef ? widget.message.ref?.ref : widget.message.ref),
                          Positioned.fill(
                              child: ColoredBox(
                            color: Colors.transparent,
                          ))
                        ],
                      )),
                ),
                Transform.translate(
                  offset: Offset(0, -3),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => _navigateToViewContact(widget.message.sender!.profileId!),
                          child: WidgetBindingProfileRadius(
                            borderRadius: 8,
                            size: 40,
                            avatarUrl: widget.message.sender!.avatar ?? '',
                            isActive: false,
                          ),
                        ),
                        Flexible(
                          child: MessagePopupButton(
                            direction: PopupDirection.top,
                            offset: Offset.zero,
                            child: Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: _animatedOpacityWidget(_checkLeftMessageType(widget.message)),
                            ),
                            builder: (context, onClose) {
                              return Material(
                                  elevation: 0.01, child: FittedBox(child: _buildLongPressMenu(false, onClose)));
                            },
                          ),
                        ),
                        _pinIconWidget(true),
                      ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftForwardMessage() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Visibility(
            visible: _checkIfSentFaild(),
            child: Image.asset(
              Assets.app_assetsIconsExclamationmark,
              width: 20,
              height: 20,
              scale: 2,
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.app_assetsIconsForwardIcon,
                      width: 12,
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        'forwarded_from'.tr,
                        style: TextStyle(color: Color(0xffACACAC)),
                      ),
                    ),
                    Text(
                      widget.message.ref!.sender!.name!,
                      style: TextStyle(
                        color: Color(0xffACACAC),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leftMessageUserName(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => _navigateToViewContact(
                              widget.message.sender!.profileId!,
                            ),
                            child: WidgetBindingProfileRadius(
                              borderRadius: 8,
                              size: 40,
                              avatarUrl: widget.message.sender!.avatar ?? '',
                              isActive: false,
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: MessagePopupButton(
                                direction: PopupDirection.top,
                                offset: Offset.zero,
                                child: _animatedOpacityWidget(_checkLeftMessageType(widget.message.ref!)),
                                builder: (context, onClose) {
                                  return Material(
                                      elevation: 0.01, child: FittedBox(child: _buildLongPressMenu(false, onClose)));
                                },
                              ),
                            ),
                          ),
                          _pinIconWidget(true),
                        ]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkLeftMessageType(MessageModel messageModel) {
    switch (messageModel.type) {
      case 'text':
        if (MessageHelper.messageEmojiTwo(messageModel.message!)) {
          return Text(
            messageModel.message!,
            style: TextStyle(fontSize: 40),
          );
        }
        return Container(
          padding: EdgeInsets.all(10),
          constraints: BoxConstraints(maxWidth: Get.width * .66),
          decoration: BoxDecoration(
            color: Color(0xffe4e6eb),
            borderRadius: BorderRadius.circular(8),
          ),
          child: MessageHelper.messageTextParser(
            messageModel.message ?? '',
            AppTextStyle.smallTextRegularBlack,
            messageModel.mentions,
            false,
            onClickMention: (id) => _onMentionClick(id),
            mentionStyle: AppTextStyle.chatTextBoldBlack,
          ),
        );
      case 'voice':
        return VoiceChatWidget(
          path: messageModel.attachments!.first.url!,
          isSender: false,
        );
      // return VoiceMessageWidget(
      //     urlPath: messageModel.attachments!.first.url!, isSender: false);
      case 'html':
        return Container(
          constraints: BoxConstraints(minWidth: 100),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Color(0xffe4e6eb),
            borderRadius: BorderRadius.circular(8),
          ),
          child: HtmlWidget(
            messageModel.htmlContent ?? '',
            customStylesBuilder: (element) {
              if (element.localName == 'p') {
                return {'margin': '0', 'padding': '0'};
              }
              return null;
            },
          ),
        );
      case 'link':
        return MessageUrlContainer(
          url: messageModel.message!,
          isReply: false,
          isLeftMessage: true,
        );
      case 'sticker':
        return MessageStickerContainer(
          isGroup: widget.isGroup,
          url: messageModel.sticker!.url ?? '',
          groupId: messageModel.sticker!.groupId ?? '',
        );
      case 'contact':
        return MessageShareContactCard(
          isleftMessage: true,
          shareContact: messageModel.shareContact!,
          isGroup: widget.isGroup,
        );

      ///MediaLeft
      case 'media':
        if (messageModel.message!.isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: leftMediaWidthSize - MediaQuery.of(context).size.width * 0.12,
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MessageMediaGrid(
                    isGroup: widget.isGroup,
                    message: messageModel,
                    isLeftMessage: true,
                    isWithMessage: true,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    width: leftMediaWidthSize - MediaQuery.of(context).size.width * 0.12,
                    decoration: BoxDecoration(
                      color: Color(0xffe4e6eb),
                    ),
                    child: Text(
                      messageModel.message!,
                      style: AppTextStyle.smallTextRegularBlack,
                    ),
                  )
                ],
              ),
            ),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: rightMediaWidthSize - MediaQuery.of(context).size.width * 0.12,
            ),
            child: MessageMediaGrid(
              isGroup: widget.isGroup,
              message: messageModel,
              isLeftMessage: true,
            ),
          ),
        );
      case 'file':
        return MessageSendFileCard(
          widget: widget,
          isRightMessage: false,
        );
      case 'vows':
        return MessageCallWidget(
          call: messageModel.call,
        );
      default:
        return SizedBox();
    }
  }

  Widget _checkLeftReplyMessageType(MessageModel? _ref) {
    switch (_ref!.type) {
      case 'text':
        return Container(
          padding: EdgeInsets.all(10),
          constraints: BoxConstraints(maxWidth: Get.width * .65),
          decoration: BoxDecoration(
            color: Color(0xffe4e6eb),
            borderRadius: BorderRadius.circular(8),
          ),
          child: MessageHelper.messageTextParser(
            _ref.message ?? '',
            AppTextStyle.smallTextRegularBlack,
            _ref.mentions,
            true,
            onClickMention: (id) => _onMentionClick(id),
            mentionStyle: AppTextStyle.chatTextBoldBlack,
          ),
        );
      case 'voice':
        return Container(
          constraints: BoxConstraints(maxWidth: Get.width * .7),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xffF3F3F3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('<<${'voice'.tr}>>'),
        );
      case 'link':
        return MessageUrlContainer(
          url: _ref.message!,
          isReply: true,
          isLeftMessage: false,
        );
      case 'sticker':
        return MessageStickerContainer(
          isGroup: widget.isGroup,
          url: _ref.sticker!.url!,
          groupId: _ref.sticker!.groupId ?? '',
        );
      case 'contact':
        return MessageShareContactReplyCard(
          isleftMessage: true,
          shareContact: _ref.shareContact!,
        );
      case 'media':
        // if (_ref.message!.isNotEmpty) {
        //   return ClipRRect(
        //     borderRadius: BorderRadius.circular(8),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         MessageReplyMedia(
        //           isLeftMessage: true,
        //           urlPath: _ref.attachments![0].url!,
        //           isDropped: _ref.attachments![0].isDropped ?? false,
        //         ),
        //         Container(
        //           padding: const EdgeInsets.all(12.0),
        //           color: Color(0xffe4e6eb),
        //           width: Get.width / 2.4,
        //           child: Text(
        //             widget.message.message!,
        //             textAlign: TextAlign.left,
        //             style: AppTextStyle.chatTextBlack,
        //           ),
        //         )
        //       ],
        //     ),
        //   );
        // }
        return MessageReplyMedia(
          isLeftMessage: true,
          urlPath: _ref.attachments![0].url!,
          isDropped: _ref.attachments![0].isDropped ?? false,
        );
      case 'file':
        return MessageSendFileCard(
          widget: widget,
          isRightMessage: false,
          isReplyMessage: true,
        );
      case 'vows':
        return MessageCallWidget(
          call: _ref.call,
        );
      default:
        return SizedBox();
    }
  }

  //* Close Left message section

  //*Open Right message section

  Widget _checkRightMessage() {
    switch (_checkMessageType()) {
      case 'unsent':
        return Expanded(
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [_buildUnsentMessage()]),
        );
      case 'reply':
        return _buildRightReplyMessage();
      case 'forward':
        return _buildRightForwardMessage();
      case 'message':
      default:
        return _buildRightMessageWidget();
    }
  }

  Widget _buildRightMessageWidget() {
    var isUploading = widget.message.isUploading ?? false;
    var isPinned = widget.message.isPinned ?? false;
    return Expanded(
      child: Row(
        crossAxisAlignment: isPinned ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible: _checkIfSentFaild(),
            child: Image.asset(
              Assets.app_assetsIconsExclamationmark,
              width: 20,
              height: 20,
              scale: 2,
            ),
          ),
          _pinIconWidget(false),
          Flexible(
            child: MessagePopupButton(
              enabled: isUploading == false,
              direction: PopupDirection.top,
              offset: Offset.zero,
              child: _animatedOpacityWidget(_checkRightMessageType(widget.message)),
              builder: (context, onClose) {
                return Material(elevation: 0.01, child: FittedBox(child: _buildLongPressMenu(false, onClose)));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightReplyMessage() {
    bool isForwardRef = widget.message.ref?.refType == 'forward';
    var isUploading = widget.message.isUploading ?? false;
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: _checkIfSentFaild(),
            child: Image.asset(
              Assets.app_assetsIconsExclamationmark,
              width: 20,
              height: 20,
              scale: 2,
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.app_assetsIconsReplyIcon,
                      width: 12,
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        children: [
                          Text(
                            'you'.tr + ' ',
                            style: TextStyle(
                              fontSize: 13.3,
                              color: Color(0xffACACAC),
                            ),
                          ),
                          Text(
                            'replied_to'.tr,
                            style: TextStyle(
                              fontSize: 13.3,
                              color: Color(0xffACACAC),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _checkIfMessageReplyByMe() ? 'yourself'.tr : widget.message.ref!.sender!.name!,
                      style: TextStyle(
                        fontSize: 13.3,
                        color: Color(0xffACACAC),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: _onTapOnReplyMessage,
                  child: Opacity(
                    opacity: .6,
                    child: Stack(
                      children: [
                        _checkRightReplyMessageType(isForwardRef ? widget.message.ref?.ref : widget.message.ref),
                        Positioned.fill(
                          child: ColoredBox(
                            color: Colors.transparent,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -3),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _pinIconWidget(false),
                        Flexible(
                          child: MessagePopupButton(
                            enabled: isUploading == false,
                            direction: PopupDirection.top,
                            offset: Offset.zero,
                            child: _animatedOpacityWidget(_checkRightMessageType(widget.message)),
                            builder: (context, onClose) {
                              return Material(
                                  elevation: 0.01, child: FittedBox(child: _buildLongPressMenu(false, onClose)));
                            },
                          ),
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightForwardMessage() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: _checkIfSentFaild(),
            child: Image.asset(
              Assets.app_assetsIconsExclamationmark,
              width: 20,
              height: 20,
              scale: 2,
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.app_assetsIconsForwardIcon,
                      width: 12,
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        'forwarded_from'.tr,
                        style: TextStyle(color: Color(0xffACACAC)),
                      ),
                    ),
                    Text(
                      widget.message.ref?.sender?.name ?? '',
                      style: TextStyle(
                        fontSize: 13.3,
                        color: Color(0xffACACAC),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _pinIconWidget(false),
                    MessagePopupButton(
                      direction: PopupDirection.top,
                      offset: Offset.zero,
                      child: _animatedOpacityWidget(_checkRightMessageType(widget.message.ref!)),
                      builder: (context, onClose) {
                        return Material(elevation: 0.01, child: FittedBox(child: _buildLongPressMenu(false, onClose)));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkRightMessageType(MessageModel messageModel) {
    switch (messageModel.type) {
      case 'text':
        if (MessageHelper.messageEmojiTwo(messageModel.message!)) {
          return Text(
            messageModel.message!,
            style: TextStyle(fontSize: 40),
          );
        }
        return Container(
          padding: EdgeInsets.all(10),
          constraints: BoxConstraints(maxWidth: Get.width * .7),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: MessageHelper.messageTextParser(
            messageModel.message ?? '',
            AppTextStyle.smallTextMediumWhite,
            messageModel.mentions,
            false,
            onClickMention: (id) => _onMentionClick(id),
            mentionStyle: AppTextStyle.chatTextBoldWhite,
          ),
        );
      case 'link':
        return MessageUrlContainer(
          url: messageModel.message!,
          isReply: false,
          isLeftMessage: false,
        );
      case 'voice':
        return VoiceChatWidget(
          path: messageModel.attachments?.first.url ?? '',
          isSender: true,
          uploadPath: messageModel.attachments?.first.uploadPath,
        );
      // return VoiceMessageWidget(
      //     urlPath: messageModel.attachments!.first.url!, isSender: true);
      case 'sticker':
        return MessageStickerContainer(
          isGroup: widget.isGroup,
          url: messageModel.sticker!.url!,
          groupId: messageModel.sticker!.groupId ?? '',
        );
      case 'contact':
        return MessageShareContactCard(
          isleftMessage: false,
          shareContact: messageModel.shareContact!,
          isGroup: widget.isGroup,
        );

      case 'media':
        if (messageModel.message!.isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: rightMediaWidthSize - MediaQuery.of(context).size.width * 0.12,
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MessageMediaGrid(
                    isGroup: widget.isGroup,
                    message: messageModel,
                    isLeftMessage: false,
                    isWithMessage: true,
                  ),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    color: AppColors.primaryColor,
                    width: double.infinity,
                    child: Text(
                      messageModel.message!,
                      textAlign: TextAlign.left,
                      style: AppTextStyle.smallTextMediumWhite,
                    ),
                  )
                ],
              ),
            ),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: rightMediaWidthSize - MediaQuery.of(context).size.width * 0.12,
            ),
            child: MessageMediaGrid(
              isGroup: widget.isGroup,
              message: messageModel,
              isLeftMessage: false,
            ),
          ),
        );

      case 'file':
        return MessageSendFileCard(
          widget: widget,
          isRightMessage: true,
        );
      case 'vows':
        return MessageCallWidget(
          call: messageModel.call,
        );

      default:
        return SizedBox();
    }
  }

  Widget _checkRightReplyMessageType(MessageModel? _ref) {
    switch (_ref!.type) {
      case 'text':
        return Container(
          constraints: BoxConstraints(maxWidth: Get.width * .7),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xffF3F3F3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: MessageHelper.messageTextParser(
            _ref.message ?? '',
            AppTextStyle.chatTextBlack,
            _ref.mentions,
            true,
            onClickMention: (id) => _onMentionClick(id),
            mentionStyle: AppTextStyle.chatTextBoldBlack,
          ),
        );
      case 'voice':
        return Container(
          constraints: BoxConstraints(maxWidth: Get.width * .7),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xffF3F3F3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('<<${'voice'.tr}>>'),
        );
      case 'link':
        return MessageUrlContainer(
          url: _ref.message!,
          isReply: true,
          isLeftMessage: false,
        );
      case 'sticker':
        return MessageStickerContainer(
          isGroup: widget.isGroup,
          url: _ref.sticker?.url ?? '',
          groupId: _ref.sticker?.groupId ?? '',
        );
      case 'contact':
        return MessageShareContactReplyCard(isleftMessage: false, shareContact: _ref.shareContact!);
      case 'media':
        // if (_ref.message!.isNotEmpty) {
        //   return ClipRRect(
        //     ///chReply
        //     borderRadius: BorderRadius.circular(8),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         MessageReplyMedia(
        //           isLeftMessage: false,
        //           urlPath: _ref.attachments![0].url!,
        //           isDropped: _ref.attachments![0].isDropped ?? false,
        //         ),
        //         Container(
        //           width: Get.width / 2.4,
        //           padding: EdgeInsets.all(10),
        //           decoration: BoxDecoration(
        //             color: Color(0xffe4e6eb),
        //           ),
        //           child: Text(
        //             _ref.message!,
        //             style: AppTextStyle.smallTextRegularBlack,
        //           ),
        //         )
        //       ],
        //     ),
        //   );
        // }
        return MessageReplyMedia(
          isLeftMessage: false,
          urlPath: _ref.attachments![0].url!,
          isDropped: _ref.attachments![0].isDropped ?? false,
        );
      case 'file':
        return MessageSendFileCard(
          widget: widget,
          isRightMessage: true,
          isReplyMessage: true,
        );
      case 'vows':
        return MessageCallWidget(
          call: _ref.call,
        );
      default:
        return SizedBox();
    }
  }

  //*Close Right message section
  void _onRadioButtonSelect(selectValue) {
    if (widget.message.radioButtonSelectValue!.isEmpty) {
      widget.message.radioButtonSelectValue = selectValue.toString();
      widget.message.isSelect = true;
    } else {
      widget.message.isSelect = false;
      widget.message.radioButtonSelectValue = '';
    }
    setState(() {});
  }

  bool isDisableOption(int index) {
    String message = widget.message.message ?? '';
    if (widget.message.ref?.type == 'vows' || widget.message.type == 'vows') {
      return index == 1 || index == 2 || index == 4;
    } else if (index == 1) {
      if (widget.message.refType == 'forward') {
        String refMessage = widget.message.ref?.message ?? '';
        if (refMessage != '') {
          return false;
        }
      }
      if (message != '') {
        return false;
      }
      return true;
    }
    return false;
  }

  Widget _buildLongPressMenu(bool isNeedRef, Function onClosePopUp) {
    // FocusScopeNode currentFocus = FocusScope.of(context);
    // if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    //   FocusManager.instance.primaryFocus!.unfocus();
    // }
    if (widget.isGroup) {
      Get.find<GroupMessageController>().getListSeenMessageUser(widget.message.id);
    }

    return StatefulBuilder(
      builder: (context, setState) => AnimatedCrossFade(
        crossFadeState: _isShowGroupSeenUser ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: Duration(milliseconds: 250),
        secondCurve: Curves.easeIn,
        firstCurve: Curves.easeOut,
        firstChild: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            width: 230,
            color: const Color(0xff343434),
            child: Column(
              children: [
                GridView.count(
                  padding: EdgeInsets.zero,
                  crossAxisCount: 3,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    ...List.generate(
                      menuItems.length,
                      (index) {
                        var item = menuItems[index];
                        return InkWell(
                          onTap: () {
                            onClosePopUp();
                            if (!isDisableOption(index)) {
                              generateFunctionOnContextMenu(item.type, isNeedRef);
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 0.125,
                                color: Color(0xff4f4f4f),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  item.icon,
                                  size: 24,
                                  color: isDisableOption(index) ? Colors.grey : Colors.white,
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 2),
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      color: isDisableOption(index) ? Colors.grey : Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ]..addIf(
                  widget.isGroup,
                  GetBuilder<GroupMessageController>(
                      id: 'seenUserListBuilder',
                      builder: (controller) {
                        return Visibility(
                          visible: _checkIfSentByMe(),
                          child: controller.isGetSeenLoading
                              ? Container(
                                  margin: EdgeInsets.all(8),
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 1.8,
                                  ),
                                )
                              : Visibility(
                                  visible: controller.userSeenMessageList.isNotEmpty,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isShowGroupSeenUser = true;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      alignment: Alignment.center,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                if (controller.userSeenMessageList.length > 3) SizedBox(width: 28),
                                                ...List.generate(
                                                  controller.userSeenMessageList.take(5).length,
                                                  (index) => Transform.translate(
                                                    offset: Offset(
                                                      -(index * 12).toDouble(),
                                                      0,
                                                    ),
                                                    child: Container(
                                                      width: 35,
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(
                                                          width: 2,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(7),
                                                        child: CachedNetworkImage(
                                                          imageUrl: controller.userSeenMessageList[index].avatar ?? '',
                                                          fit: BoxFit.cover,
                                                          placeholder: (context, url) => SizedBox(
                                                            width: 15,
                                                            height: 15,
                                                            child: CircularProgressIndicator.adaptive(),
                                                          ),
                                                          errorWidget: (context, url, error) => Image.asset(
                                                            Assets.app_assetsIconsMyPofileAvatar,
                                                            width: 35,
                                                            height: 35,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ]),
                                          SizedBox(height: 4),
                                          Text(
                                            '${controller.userSeenMessageList.length} ' + 'seens'.tr,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        );
                      }),
                ),
            ),
          ),
        ),
        secondChild: widget.isGroup
            ? ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 230),
                  color: const Color(0xff343434),
                  child: GetBuilder<GroupMessageController>(
                      id: 'seenUserListBuilder',
                      builder: (controller) {
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isShowGroupSeenUser = false;
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    Text(
                                      'back'.tr,
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 1,
                              color: Colors.white,
                            ),
                            SizedBox(height: 12),
                            Container(
                              constraints: BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: controller.userSeenMessageList.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () => _navigateToViewContact(
                                      controller.userSeenMessageList[index].profileId,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                        left: 12,
                                        right: 12,
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: CachedNetworkImage(
                                              imageUrl: controller.userSeenMessageList[index].avatar ?? '',
                                              width: 35,
                                              height: 35,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => SizedBox(
                                                width: 15,
                                                height: 15,
                                                child: CircularProgressIndicator.adaptive(),
                                              ),
                                              errorWidget: (context, url, error) => Image.asset(
                                                Assets.app_assetsIconsMyPofileAvatar,
                                                width: 35,
                                                height: 35,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              controller.userSeenMessageList[index].name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13.3,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                ),
              )
            : SizedBox(),
      ),
    );
  }

  Widget _buildUnsentMessage({bool isLeftMessage = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(visible: !_checkIfSentByMe(), child: leftMessageUserName()),
        Row(
          children: [
            Visibility(
              visible: !_checkIfSentByMe(),
              child: InkWell(
                onTap: () => _navigateToViewContact(
                  widget.message.sender!.profileId ?? '',
                ),
                child: WidgetBindingProfileRadius(
                  borderRadius: 8,
                  size: 40,
                  avatarUrl: widget.message.sender!.avatar ?? '',
                  isActive: false,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: .8,
                  color: Color(0XFFD9D9D9),
                ),
              ),
              child: isLeftMessage
                  ? Text(
                      '${widget.message.sender!.name} ' + 'unsent_message'.tr,
                      style: TextStyle(
                        color: Color(0XFFD9D9D9),
                        fontSize: 13.3,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : Text(
                      'you_unsent_a_message'.tr,
                      style: TextStyle(
                        color: Color(0xffACACAC),
                        fontSize: 13.3,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _onCopy(bool isNeedRef) async {
    if (isNeedRef) {
      var refType = widget.message.ref!.type;
      if (refType == 'media' || refType == 'file') {
        var message = widget.message.ref!.message;
        if (message == null || message == '') {
          return;
        }
        await Clipboard.setData(ClipboardData(
          text: message,
        ));
      } else if (widget.message.ref!.type != 'text' && widget.message.ref!.type != 'link') {
        return;
      }
    } else if (widget.message.type == 'html') {
      var copy = isNeedRef ? widget.message.ref!.htmlContent : widget.message.htmlContent;
      await Clipboard.setData(ClipboardData(text: copy!.replaceAll(RegExp(r'<[^>]*>'), '')));
    } else if (widget.message.type == 'media' || widget.message.type == 'file') {
      var message = widget.message.message;
      if (message == null || message == '') {
        return;
      }
      await Clipboard.setData(ClipboardData(
        text: message,
      ));
    } else if (widget.message.type != 'text' && widget.message.type != 'link') {
      return;
    } else {
      await Clipboard.setData(ClipboardData(
        text: isNeedRef ? widget.message.ref?.message ?? '' : widget.message.message ?? '',
      ));
    }

    Future.delayed(Duration(milliseconds: 1000), () {
      Navigator.of(context).pop();
    });
    await showCupertinoDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: CupertinoDialogIcon(text: 'copied'),
            ),
          );
        });
  }

  void _onForwardMessage(bool isNeedRef) {
    Get.to(
      () => ChatroomForwardScreen(),
      arguments: isNeedRef ? widget.message.ref?.id : widget.message.id,
    );
  }

  void _onConfirmDelete() {
    Get.back();
    _checkIfMessageInGroup().onDeleteMessage([widget.message.id]);
  }

  void _onReplyMessage() {
    _checkIfMessageInGroup().onSelectReplyMessage(widget.message);
  }

  void _navigateToViewContact(String profileId) {
    // contextMenuController!.hideMenu();
    if (widget.isGroup) {
      Get.find<GroupMessageController>().navigateToViewContactFromGroupProfile(profileId);
    } else {
      Get.find<ChatRoomMessageController>().navigateToViewContactFromAppBarTap(profileId);
    }
  }

  void _onMentionClick(String userId) {
    _navigateToViewContact('g_$userId');
  }

  void _unsendMessage() {
    Get.back();
    _checkIfMessageInGroup().onUnsendMessage(widget.message.id, _unableToUnsentDialog);
  }

  void _onMultiSlect() {
    _checkIfMessageInGroup().onMulitSelect();
  }

  void _onPinMessage() {
    _checkIfMessageInGroup().onPinMessage(widget.message.id);
  }

  void _onUnpinMessage() {
    _checkIfMessageInGroup().onUnpinMessage(widget.message.id);
  }

  void _showDeleteAndUnsendMessageDialog() async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      context: context,
      builder: (BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 25, left: 16, right: 16),
        child: ListView(
          shrinkWrap: true,
          children: [
            Visibility(
              visible: _checkIfSentByMe(),
              child: InkWell(
                onTap: _unsendMessage,
                child: Container(
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    'unsend'.tr,
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Container(height: .8, color: Colors.grey),
            InkWell(
              onTap: _onConfirmDelete,
              child: Container(
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  'delete'.tr,
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  'cancel'.tr,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _unableToUnsentDialog() async {
    await showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => Dialog(
        child: Material(
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  FontUtil.tr('this_message_can’t_be_unsent_after_being_seen_by_others.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Container(height: .8, color: Colors.grey),
              InkWell(
                onTap: Get.back,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    'ok'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void generateFunctionOnContextMenu(ContextMenu type, isNeedRef) {
    // contextMenuController!.hideMenu();
    switch (type) {
      case ContextMenu.select:
        _onMultiSlect();
        break;
      case ContextMenu.copy:
        _onCopy(isNeedRef);
        break;
      case ContextMenu.pin:
        _onPinMessage();
        break;
      case ContextMenu.unpin:
        _onUnpinMessage();
        break;
      case ContextMenu.reply:
        _onReplyMessage();
        break;
      case ContextMenu.forward:
        _onForwardMessage(isNeedRef);
        break;
      case ContextMenu.delete:
        _showDeleteAndUnsendMessageDialog();
        break;
      default:
    }
  }
}

class MessageSendFileCard extends StatelessWidget {
  const MessageSendFileCard({
    Key? key,
    required this.widget,
    required this.isRightMessage,
    this.isReplyMessage = false,
    this.isForwardMessage = false,
    this.highlightText = '',
  }) : super(key: key);

  final String highlightText;
  final MessageItem widget;
  final bool isRightMessage;
  final bool isReplyMessage;
  final bool isForwardMessage;

  @override
  Widget build(BuildContext context) {
    var attachments = widget.message.attachments;
    var attachmentsRef = widget.message.ref?.attachments;
    var ref = widget.message.ref;
    bool isForward = widget.message.refType == 'forward';
    bool isForwardRef = widget.message.ref?.refType == 'forward';
    var caption = isForward || isReplyMessage ? widget.message.ref?.message : widget.message.message;
    var _isDropped = checkIfDrop(isForwardRef, isForward);

    return FittedBox(
      child: Column(
        children: [
          if (isReplyMessage) fileCard(isForwardRef ? ref?.ref?.attachments : ref?.attachments, caption!),
          if (!isReplyMessage) fileCard(isForward ? attachmentsRef : attachments, caption!),
          if (_isDropped) ...[
            SizedBox(height: 7),
            Row(
              mainAxisAlignment: isRightMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Color(0xFFACACAC),
                  size: 16,
                ),
                SizedBox(width: 5),
                Text(
                  'this_file_is_no_longer_available'.tr,
                  style: TextStyle(fontSize: 11.11, color: Color(0x993C3C43)),
                ),
              ],
            ),
            if (isReplyMessage) SizedBox(height: 7),
          ]
        ],
      ),
    );
  }

  Align fileCard(List<AttachmentModel>? attachments, [String caption = '']) {
    bool isMessageHasCaption = caption.isNotEmpty;

    return Align(
      alignment: isRightMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * .65),
        decoration: BoxDecoration(
          color: isReplyMessage
              ? Color.fromARGB(255, 223, 222, 222)
              : isRightMessage
                  ? Colors.green
                  : Color(0xFFE4E6EB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: isRightMessage ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMessageHasCaption || !isReplyMessage)
              ...List.generate(
                attachments?.length ?? 0,
                (index) {
                  return FileCacheProgress(
                    attachment: attachments![index],
                    isRightMessage: isRightMessage,
                    isReplyMessage: isReplyMessage,
                    highlightText: highlightText,
                    isGroup: widget.isGroup,
                  );
                },
              ),
            if (isMessageHasCaption)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isReplyMessage)
                    Divider(
                      color: Colors.white,
                      height: 0,
                      indent: 0,
                      thickness: 1,
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 14),
                    child: Text(
                      caption,
                      style: isRightMessage && !isReplyMessage
                          ? AppTextStyle.smallTextRegularWhite
                          : TextStyle(
                              color: Color(0xff000000),
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                    ),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  bool checkIfDrop(bool isForwardRef, bool isForward) {
    bool isDropped = false;

    bool checkfirstItem(MessageModel _model) {
      if (_model.attachments!.isNotEmpty) {
        return _model.attachments!.first.isDropped ?? false;
      }
      return false;
    }

    if (isReplyMessage) {
      if (isForwardRef) {
        isDropped = checkfirstItem(widget.message.ref!.ref!);
      } else {
        isDropped = checkfirstItem(widget.message.ref!);
      }
    } else {
      if (isForward) {
        isDropped = checkfirstItem(widget.message.ref!);
      } else {
        isDropped = checkfirstItem(widget.message);
      }
    }
    return isDropped;
  }
}

class FileCacheProgress extends StatefulWidget {
  final AttachmentModel attachment;
  final bool isRightMessage;
  final bool isReplyMessage;
  final String highlightText;
  final bool isGroup;

  FileCacheProgress({
    Key? key,
    required this.attachment,
    required this.isRightMessage,
    required this.isReplyMessage,
    required this.highlightText,
    required this.isGroup,
  }) : super(key: key);
  @override
  _FileCacheProgressState createState() => _FileCacheProgressState();
}

class _FileCacheProgressState extends State<FileCacheProgress> {
  bool _isPaused = false;
  bool _isShowDefault = false;
  bool _isLoad = true;
  int percentage = 0;
  dio.CancelToken cancelToken = dio.CancelToken();

  @override
  void initState() {
    super.initState();
    if (widget.attachment.isDropped == false) {
      // CacheManagerHelper.instance.emptyCache();
      _checkFile();
    } else {
      setState(() {
        _isShowDefault = true;
        _isLoad = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _progressBuilder(String fileType) {
    //show empty
    if (_isLoad) {
      return SizedBox();
    }

    // show default
    if (_isShowDefault) {
      return Text(
        fileType,
        style: TextStyle(
          color: Color(0xff4882B8),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    // show download icon
    if (_isPaused) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0x334FB848),
        ),
        child: Center(
          child: Image.asset(
            Assets.app_assetsIconsDownloadArrow,
            width: 13,
            height: 13,
            color: AppColors.primaryColor,
          ),
        ),
      );
    }

    // show download progress
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFF343434).withOpacity(.1),
            child: Icon(
              Icons.close,
              color: AppColors.primaryColor,
              size: 13,
            ),
          ),
          CircularProgressIndicator(
              strokeWidth: 2,
              value: percentage == 0 ? null : percentage / 100,
              valueColor: AlwaysStoppedAnimation(AppColors.primaryColor))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String fileName = widget.attachment.originalName ?? '';

    String fileType = fileName.split('.').last.toUpperCase();

    String fileSize = MessageUploadHelper().getFileSize(int.parse(widget.attachment.fileSize ?? '0'));

    String fileId = widget.attachment.id ?? '';
    String uploadPath = widget.attachment.uploadPath ?? '';
    int uploadPercentage = widget.attachment.uploadPercentage ?? 0;
    String url = widget.attachment.url ?? '';
    bool isDropped = widget.attachment.isDropped ?? false;
    return Container(
      padding: EdgeInsets.all(12),
      child: InkWell(
        onTap: url == '' || isDropped
            ? () {}
            : () {
                openFile(
                  url,
                  fileType,
                  fileSize,
                  fileName,
                  fileId,
                );
              },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (!widget.isRightMessage)
              InkWell(
                onTap: _isShowDefault ? null : _toggleDownloadData,
                child: Container(
                    alignment: Alignment.center,
                    width: 40,
                    height: 40,
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _progressBuilder(fileType)),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HighlightText(
                    text: fileName,
                    highlightText: widget.highlightText,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: widget.isReplyMessage
                        ? AppTextStyle.smallTextRegularGray
                        : widget.isRightMessage
                            ? AppTextStyle.smallTextMediumWhite
                            : AppTextStyle.chatTextBlack,
                  ),
                  const SizedBox(height: 8),
                  if (!widget.isReplyMessage)
                    Text(
                      fileSize,
                      style: widget.isRightMessage
                          ? AppTextStyle.extraSmallTextBoldWhite
                          : AppTextStyle.extraSmallTextBoldBlack,
                    ),
                ],
              ),
            ),
            if (widget.isRightMessage)
              Container(
                alignment: Alignment.center,
                width: 40,
                height: 40,
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: uploadPath != '' && url == ''
                    ? InkWell(
                        onTap: () =>
                            MessageUploadHelper().cancelUpload(uploadPercentage > 0, widget.attachment, widget.isGroup),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Color(0xFF343434).withOpacity(.1),
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.primaryColor,
                                  size: 13,
                                ),
                              ),
                              CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: uploadPercentage <= 0 ? null : uploadPercentage / 100,
                                  valueColor: AlwaysStoppedAnimation(AppColors.primaryColor))
                            ],
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: _isShowDefault ? null : _toggleDownloadData,
                        child: _progressBuilder(fileType),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  void _checkFile() async {
    var file = await CacheManagerHelper.instance.getFileFromCache(widget.attachment.url!);
    if (file != null) {
      // show default
      if (mounted) {
        setState(() {
          _isShowDefault = true;
          _isLoad = false;
        });
      }
    } else {
      // show download
      if (mounted) {
        setState(() {
          _isPaused = true;
          _isLoad = false;
        });
      }
    }
  }

  void openFile(String path, String fileType, String fileSize, String fileName, String fileId) async {
    await Get.to(() =>
        ViewFileScreen(fileName: fileName, fileSize: fileSize, fileType: fileType, fileUrl: path, fileId: fileId));
  }

  void downloadFile() async {
    cancelToken = dio.CancelToken();
    CacheManagerHelper.downloadFileToCacheManager(cancelToken, widget.attachment.url!,
        onDownloadChange: (int _percent) {
      setState(() {
        percentage = _percent;
        if (_percent == 100) {
          _isShowDefault = true;
        }
      });
    });
  }

  void _toggleDownloadData() {
    if (_isPaused) {
      setState(() {
        _isPaused = false;
      });
      downloadFile();
    } else {
      setState(() {
        _isPaused = true;
      });
      cancelToken.cancel();
      setState(() {
        percentage = 0;
      });
    }
  }
}

class MessageShareContactCard extends StatelessWidget {
  const MessageShareContactCard({
    Key? key,
    required this.shareContact,
    required this.isleftMessage,
    required this.isGroup,
  }) : super(key: key);
  final ShareContact shareContact;
  final bool isleftMessage;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: Get.width * .65),
      padding: EdgeInsets.symmetric(vertical: 11, horizontal: 16),
      // margin: EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: isleftMessage ? Color(0xffe4e6eb) : AppColors.primaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: WidgetBindingProfileRadius(
              borderRadius: 8,
              size: 45,
              avatarUrl: shareContact.avatar,
              isActive: false,
            ),
            title: Text(
              shareContact.fullName,
              style: isleftMessage ? AppTextStyle.smallTextRegularBlack : AppTextStyle.smallTextRegularWhite,
            ),
            subtitle: Text(
              shareContact.country,
              style: isleftMessage ? AppTextStyle.smallTextRegularBlack : AppTextStyle.smallTextRegularWhite,
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () => _viewShareContact(shareContact.profileId),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: isleftMessage ? Colors.grey.shade500 : Colors.white,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'view_contact'.tr,
                style: isleftMessage ? AppTextStyle.smallTextRegularBlack : AppTextStyle.smallTextRegularWhite,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _viewShareContact(id) {
    var _accountId = Get.find<AccountUserProfileController>().profile?.id;
    if (_accountId == shareContact.id) return;
    Get.lazyPut(() => AddFriendBySearchController());
    Get.find<AddFriendBySearchController>().onInit();
    Get.find<AddFriendBySearchController>().profileId = id;
    Get.find<AddFriendBySearchController>().getUserProfile(id);
    Get.toNamed(Routes.searchFriendResult, preventDuplicates: false);
  }
}

class MessageShareContactReplyCard extends StatelessWidget {
  const MessageShareContactReplyCard({
    Key? key,
    required this.shareContact,
    required this.isleftMessage,
  }) : super(key: key);
  final ShareContact shareContact;
  final bool isleftMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: Get.width * .35),
      padding: EdgeInsets.symmetric(vertical: 11, horizontal: 12),
      foregroundDecoration: BoxDecoration(
        color: Color(0xffFDFFFD).withOpacity(.5),
      ),
      decoration: BoxDecoration(
        color: isleftMessage ? Color(0xffE4E6EB) : AppColors.primaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              WidgetBindingProfileRadius(
                borderRadius: 4,
                size: 30,
                avatarUrl: shareContact.avatar,
                isActive: false,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shareContact.fullName,
                    style: isleftMessage
                        ? AppTextStyle.smallTextRegularBlack.copyWith(fontSize: 12)
                        : AppTextStyle.smallTextRegularWhite.copyWith(fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    shareContact.country,
                    style: isleftMessage
                        ? AppTextStyle.smallTextRegularBlack.copyWith(fontSize: 12)
                        : AppTextStyle.smallTextRegularWhite.copyWith(fontSize: 12),
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 6),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: isleftMessage ? Colors.grey.shade500 : Colors.white,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'view_contact'.tr,
              style: isleftMessage
                  ? AppTextStyle.smallTextRegularBlack.copyWith(fontSize: 12)
                  : AppTextStyle.smallTextRegularWhite.copyWith(fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}

class MessageReplyMedia extends StatelessWidget {
  const MessageReplyMedia({
    Key? key,
    required this.urlPath,
    required this.isLeftMessage,
    required this.isDropped,
  }) : super(key: key);

  final String urlPath;
  final bool isLeftMessage;
  final bool isDropped;

  Widget _expiredMediaWidget() {
    return Align(
      alignment: isLeftMessage ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFE3E5E3),
          borderRadius: BorderRadius.circular(8),
        ),
        height: 100,
        width: 150,
        child: Icon(
          Icons.error_outline,
          color: Color(0xFF9A9A9A),
          size: 26.67,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
          width: Get.width / 2,
          // foregroundDecoration: BoxDecoration(
          //   color: Color(0xffFDFFFD).withOpacity(.5),
          // ),
          child: isDropped
              ? _expiredMediaWidget()
              : urlPath.isImageFileName
                  ? Wrap(
                      alignment: isLeftMessage ? WrapAlignment.start : WrapAlignment.end,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxHeight: 100),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: urlPath,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => CircularProgressIndicator.adaptive(),
                              errorWidget: (context, url, error) => MediaHelper.brokenfile(scale: 5),
                            ),
                          ),
                        ),
                      ],
                    )
                  : MessageVideoContainer(urlPath: urlPath, fileUploadPath: '')),
    );
  }
}

class MessageStickerContainer extends StatelessWidget {
  const MessageStickerContainer({
    Key? key,
    required this.url,
    required this.groupId,
    required this.isGroup,
  }) : super(key: key);

  final String url;
  final String groupId;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => onStickerClick(
          id: groupId,
          isGroup: isGroup,
        ),
        child: CachedNetworkImage(
          width: 100,
          height: 100,
          imageUrl: url,
          placeholder: (context, url) => Center(child: SizedBox()),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }

  void onStickerClick({required String id, required bool isGroup}) {
    final stickerController = Get.find<StickerController>();
    stickerController.viewEachSticker(groupId);
    showModalBottomSheet<void>(
      context: Get.context!,
      isScrollControlled: true,
      builder: (BuildContext context) {
        // Get.find<StickerController>().viewEachSticker(groupId);
        return Container(
          height: Get.height * .55,
          padding: const EdgeInsets.all(16),
          child: GetBuilder<StickerController>(builder: (controller) {
            var isStickerAdded = controller.stickersInDetail?.data?.isAdded ?? false;
            return Column(
              children: [
                SizedBox(
                  height: 30,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      InkWell(
                        onTap: Get.back,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'cancel'.tr,
                            style: AppTextStyle.normalTextMediumGrey,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          ChatHelper.stickerNameAndDescription(controller.stickersInDetail?.data?.name),
                          style: AppTextStyle.normalBold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: controller.stickersInDetail?.data?.stickers?.length ?? 0,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 30,
                      crossAxisCount: 3,
                      crossAxisSpacing: 2.0,
                      childAspectRatio: 4 / 3,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final sticker = controller.stickersInDetail?.data?.stickers?[index];
                      return InkWell(
                        onTap: () => _sentSticker(stickerId: sticker?.id ?? '', isGroup: isGroup),
                        child: SizedBox(
                          width: 10,
                          height: 10,
                          child: CachedNetworkImage(
                            imageUrl: sticker?.image ?? '',
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: CustomDefaultButton(
                    enableColor: isStickerAdded ? Colors.red : Colors.green,
                    title: isStickerAdded ? 'remove_sticker'.tr : 'add_sticker'.tr,
                    onTap: () {
                      if (isStickerAdded) {
                        Get.back();
                        controller.removeSticker(groupId);
                      } else {
                        Get.back();
                        controller.addStickerToMySticker(groupId);
                      }
                    },
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  void _sentSticker({required String stickerId, bool isGroup = false}) {
    Get.back();
    if (isGroup) {
      Get.find<GroupMessageController>().onSentSticker(stickerId);
    } else {
      Get.find<ChatRoomMessageController>().onSentSticker(stickerId);
    }
  }
}

class MessageUrlContainer extends StatefulWidget {
  const MessageUrlContainer({
    Key? key,
    required this.url,
    required this.isReply,
    required this.isLeftMessage,
  }) : super(key: key);
  final String url;
  final bool isReply;
  final bool isLeftMessage;

  @override
  State<MessageUrlContainer> createState() => _MessageUrlContainerState();
}

class _MessageUrlContainerState extends State<MessageUrlContainer> with AutomaticKeepAliveClientMixin {
  WebInfo? _preview;

  void _fetchData() async {
    bool isDownloadable =
        await LinkHelper.isDownloadable(widget.url.startsWith('http') ? widget.url : 'https://${widget.url}');
    if (!isDownloadable) {
      WebInfo item =
          await LinkPreview.scrapeFromURL(widget.url.startsWith('http') ? widget.url : 'https://${widget.url}');
      if (mounted) {
        setState(() {
          _preview = item;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InkWell(
      onTap: () => Util.launchWebUrl(widget.url),
      child: widget.isReply
          ? Container(
              padding: EdgeInsets.all(10),
              constraints: BoxConstraints(maxWidth: Get.width * .65),
              decoration: BoxDecoration(
                color: Color(0xffe4e6eb),
                borderRadius: BorderRadius.circular(8),
              ),
              width: (Get.width / 1.5) - MediaQuery.of(context).size.width * 0.12,
              child: Text('${widget.url}'),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: BoxConstraints(maxWidth: Get.width * .65),
                color: widget.isLeftMessage ? Color(0xffe4e6eb) : AppColors.primaryColor,
                padding: EdgeInsets.all(10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  MessageHelper.messageTextParser(
                    widget.url,
                    AppTextStyle.smallTextRegularBlack,
                    [],
                    false,
                    mentionStyle: AppTextStyle.chatTextBoldBlack,
                  ),
                  if (_preview?.title.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _preview!.title,
                        style: TextStyle(
                          fontSize: 14.33,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: widget.isLeftMessage ? Colors.black : Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (_preview?.description.isNotEmpty ?? false)
                    Text(
                      _preview!.description,
                      style: TextStyle(
                        fontSize: 14.33,
                        height: 1.4,
                        color: widget.isLeftMessage ? Colors.black : Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (_preview?.image.isNotEmpty ?? false)
                    Container(
                      padding: const EdgeInsets.only(top: 8.0),
                      constraints: BoxConstraints(maxHeight: 120),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: _preview!.image,
                          memCacheWidth: Get.width.toInt(),
                          width: double.maxFinite,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => SizedBox(
                            height: 15,
                            child: Center(
                              child: SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => SizedBox.shrink(),
                        ),
                      ),
                    )
                ]),
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MessageMediaGrid extends StatelessWidget {
  const MessageMediaGrid({
    Key? key,
    required this.isGroup,
    required this.message,
    required this.isLeftMessage,
    this.isWithMessage = false,
  }) : super(key: key);
  final bool isGroup;
  final MessageModel message;
  final bool isLeftMessage;
  final bool isWithMessage;

  bool _checkIfMediaImage(AttachmentModel _model) {
    var _url = _model.url ?? '';
    var isImageByMimeType = _model.mimeType?.startsWith('image/') ?? false;
    return _url.isImageFileName || isImageByMimeType;
  }

  Widget _mediaSwitchWidget(AttachmentModel _model, int index) {
    var uploadPath = _model.uploadPath;
    var url = _model.url ?? '';
    // is upload file
    if (uploadPath != null && url == '') {
      final mimeType = lookupMimeType(uploadPath);
      final isImage = mimeType!.startsWith('image/');
      var uploadPercentage = _model.uploadPercentage ?? 0;
      return Stack(
        fit: message.attachments!.length == 1 ? StackFit.loose : StackFit.expand,
        alignment: Alignment.center,
        children: [
          (isImage
              ? Image.file(
                  File(uploadPath),
                  fit: BoxFit.cover,
                  cacheWidth: (Get.width * 0.8).toInt(),
                  // width: double.maxFinite,
                  errorBuilder: ((context, error, stackTrace) => MediaHelper.brokenfile()),
                )
              : MessageVideoContainer(urlPath: url, fileUploadPath: uploadPercentage == 100 ? '' : uploadPath)),
          if (uploadPercentage < 100)
            InkWell(
              onTap: () => MessageUploadHelper().cancelUpload(uploadPercentage > 0, _model, isGroup),
              child: SizedBox(
                width: 43,
                height: 43,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFFFDFFFD).withOpacity(.7),
                      child: Icon(
                        Icons.close,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    CircularProgressIndicator(
                        strokeWidth: 3.5,
                        value: uploadPercentage <= 0 ? null : uploadPercentage / 100,
                        valueColor: AlwaysStoppedAnimation(AppColors.primaryColor))
                  ],
                ),
              ),
            )
        ],
      );
    }

    // file from url
    ///TODO
    return _checkIfMediaImage(_model)
        ? Builder(
            builder: (context) => CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              memCacheWidth: Get.width.toInt(),
              // width: double.maxFinite,
              fadeInDuration: Duration(milliseconds: 100),
              fadeOutDuration: Duration(milliseconds: 100),
              placeholder: (context, url) =>
                  uploadPath != null // replace loading with image from path after upload success
                      ? Image.file(
                          File(uploadPath),
                          fit: BoxFit.cover,
                          errorBuilder: ((context, error, stackTrace) => Text('err')),
                        )
                      : Container(
                          width: 100,
                          height: 150,
                          color: Colors.grey[200],
                          child: Center(
                            child: SizedBox(
                              height: 20,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
                                ),
                              ),
                            ),
                          ),
                        ),
              errorWidget: (context, url, error) => MediaHelper.brokenfile(scale: 5),
            ),
          )
        : MessageVideoContainer(
            urlPath: url,
            fileUploadPath: uploadPath ?? '',
          );
  }

  Widget _expiredMediaWidget() {
    return Container(
      width: double.maxFinite,
      height: 116,
      decoration: BoxDecoration(
          color: Color(0xffe4e6eb),
          border: Border(bottom: BorderSide(color: Colors.white, width: message.message!.isEmpty ? 0 : 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Color(0xFFACACAC),
            size: 16,
          ),
          SizedBox(width: 5),
          Text(
            'this_image_is_no_longer_available'.tr,
            style: TextStyle(fontSize: 11.11, color: Color(0x993C3C43)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (message.attachments!.isEmpty || message.attachments?.first.isDropped == true) {
      return _expiredMediaWidget();
    }
    return message.attachments!.length == 1
        ? InkWell(
            // disabled if upload
            onTap: () => message.attachments![0].url == '' ? {} : _navigateToChatViewMedia(0),
            child: Container(
                constraints: BoxConstraints(
                  maxHeight: 300,
                  minWidth: 100,
                  maxWidth: Get.width * .55,
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(isWithMessage ? 0 : 8),
                    child: _mediaSwitchWidget(message.attachments![0], 0))),
          )
        : GridView.custom(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                SliverQuiltedGridDelegate(crossAxisCount: 2, mainAxisSpacing: 1, crossAxisSpacing: 1, pattern: [
              if (message.attachments!.length == 2) ...[
                QuiltedGridTile(1, 1),
                QuiltedGridTile(1, 1),
              ] else if (message.attachments!.length == 1) ...[
                QuiltedGridTile(1, 2),
              ] else ...{
                QuiltedGridTile(1, 2),
                QuiltedGridTile(1, 1),
                QuiltedGridTile(1, 1),
                QuiltedGridTile(1, 2),
                QuiltedGridTile(1, 1),
                QuiltedGridTile(1, 1),
              }
            ]),
            childrenDelegate: SliverChildBuilderDelegate(
              (context, index) => InkWell(
                // disabled if upload
                onTap: () => message.attachments![index].url == '' ? {} : _navigateToChatViewMedia(index),
                child: _mediaSwitchWidget(message.attachments![index], index),
              ),
              childCount: message.attachments!.length,
            ),
          );
  }

  void _navigateToChatViewMedia(int selectIndex) async {
    // var mediaFileWithQr =
    //     message.attachments!.first.originalName?.contains('shareqr');
    // if (mediaFileWithQr ?? false) {
    //   hasQrcode = true;
    // }
    final isFromSearch = false;
    await Get.to(
      () => ChatRoomViewMediaScreen(),
      arguments: [message.attachments!, selectIndex, isGroup, isFromSearch, message],
      opaque: false,
      transition: Transition.fadeIn,
      duration: Duration(milliseconds: 200),
    );
  }
}

class MessageVideoContainer extends StatefulWidget {
  const MessageVideoContainer({Key? key, required this.urlPath, required this.fileUploadPath}) : super(key: key);

  final String urlPath;
  final String fileUploadPath;

  @override
  State<MessageVideoContainer> createState() => _MessageVideoContainerState();
}

class _MessageVideoContainerState extends State<MessageVideoContainer> {
  late Future<Uint8List?> data;

  @override
  void initState() {
    super.initState();
    data = VideoThumbnail.thumbnailData(
      video: widget.fileUploadPath != '' ? widget.fileUploadPath : widget.urlPath,
      maxWidth: Get.width.toInt(),
      quality: 10,
      timeMs: 1000,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: data,
      builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
        if (snapshot.hasData) {
          return Stack(
            children: [
              Image.memory(
                snapshot.data!,
                width: double.maxFinite,
                height: 150,
                fit: BoxFit.cover,
              ),
              if (widget.fileUploadPath == '')
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          );
        } else if (snapshot.hasError) {
          return MediaHelper.brokenfile();
        }
        return Container(
          width: double.maxFinite,
          height: 150,
          color: Colors.grey[200],
          child: Center(
            child: SizedBox(
              height: 20,
              child: FittedBox(
                fit: BoxFit.cover,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MessageCallWidget extends StatelessWidget {
  const MessageCallWidget({Key? key, required this.call}) : super(key: key);

  final Call? call;

  Color _onCheckIconBackground(isMissedCall) {
    var _accountId = Get.find<AccountUserProfileController>().profile?.id;
    var _isMyMessage = _accountId == call?.userId;
    return isMissedCall && !_isMyMessage ? AppColors.red : Color(0xFF3C3C43).withOpacity(.6);
  }

  String _onCheckIconAsset() {
    if (call?.isMissedCall ?? false) {
      return Assets.app_assetsIconsMissedCall;
    } else if (call?.name == 'outgoing') {
      return Assets.app_assetsIconsCallOut;
    } else if (call?.name == 'incoming') {
      return Assets.app_assetsIconsCallIn;
    }
    return Assets.app_assetsIconsCall;
  }

  String _onCheckCallTitle(isMissedCall) {
    var _accountId = Get.find<AccountUserProfileController>().profile?.id;
    var _isMyMessage = _accountId == call?.userId;
    // if (data['type'] == 'audio') {
    return isMissedCall && !_isMyMessage ? 'missed_audio_call'.tr : 'audio_call'.tr;
    // } else {
    //   return data['isMissed']! ? 'missed_video_call'.tr : 'video_call'.tr;
    // }
  }

  String _onCheckCallSubtitle() {
    if (call?.isMissedCall ?? false) {
      if (call?.name == 'outgoing') {
        return 'tap_to_call_again'.tr;
      } else {
        return 'tap_to_call_back'.tr;
      }
    }
    if (call?.endAt != null) {
      return DateTimeHelper.timeDurationBetweenDate(call?.receivedAt, call?.endAt);
    }
    if (call?.receivedAt != null) {
      return 'started_at'.tr + ' ' + DateTimeHelper.getShortTimer(call!.receivedAt!);
    }
    return '';
  }

  void _handleCallAgain() async {
    Get.back();
    final controller = Get.find<ChatRoomController>();
    await controller.onAudioCall(roomId: controller.currentRoomId);
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: InkWell(
        onTap: _showMessCallOptionDialog,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xffe4e6eb),
          ),
          height: 72.5,
          padding: EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: _onCheckIconBackground(call?.isMissedCall ?? false),
                child: Image.asset(
                  _onCheckIconAsset(),
                  width: 33,
                  height: 33,
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _onCheckCallTitle(call?.isMissedCall ?? false),
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5),
                    ),
                  ),
                  Flexible(child: Text(_onCheckCallSubtitle()))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showMessCallOptionDialog() async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      context: Get.context!,
      builder: (BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 25, left: 16, right: 16),
        child: ListView(
          shrinkWrap: true,
          children: [
            InkWell(
              onTap: _handleCallAgain,
              child: ItemModalBottomSheet(
                lableTitle: 'audio_call',
                topLeft: 4.0,
                topRight: 4.0,
              ),
            ),
            Container(height: .8, color: Colors.grey),
            InkWell(
              onTap: () {
                // _handleCallAgain
              },
              child: ItemModalBottomSheet(
                lableTitle: 'video_call',
                bottomLeft: 4.0,
                bottomRight: 4.0,
              ),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: ItemModalBottomSheet(
                bottomLeft: 4.0,
                bottomRight: 4.0,
                topLeft: 4.0,
                topRight: 4.0,
                lableTitle: 'cancel',
                colorLable: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemModalBottomSheet extends StatelessWidget {
  final double? bottomLeft;
  final double? bottomRight;
  final double? topLeft;
  final double? topRight;
  final String? lableTitle;
  final Color? colorLable;

  const ItemModalBottomSheet({
    Key? key,
    this.bottomLeft,
    this.bottomRight,
    this.topLeft,
    this.topRight,
    this.lableTitle,
    this.colorLable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(bottomLeft ?? 0.0),
          bottomRight: Radius.circular(bottomRight ?? 0.0),
          topLeft: Radius.circular(topLeft ?? 0.0),
          topRight: Radius.circular(topRight ?? 0.0),
        ),
      ),
      child: Text(
        lableTitle?.tr ?? 'N/A'.tr,
        style: TextStyle(
          color: colorLable ?? AppColors.seconderyColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

enum ContextMenu { select, copy, pin, unpin, reply, forward, delete }

class MessageOptionMenu {
  String title;
  IconData icon;
  ContextMenu type;
  MessageOptionMenu(this.title, this.icon, this.type);
}

class ImageDetail {
  final int width;
  final int height;
  final Uint8List? bytes;
  ImageDetail({required this.width, required this.height, this.bytes});
}
