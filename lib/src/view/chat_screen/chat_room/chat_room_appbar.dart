import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/chat_room/chat_room.dart';
import '../../../util/constant/app_assets.dart';
import '../../../util/helper/message_helper.dart';
import '../../../util/text_style.dart';
import '../../../util/theme/app_color.dart';
import '../../widget/widget_binding_profile_radius.dart';
// import 'widget/message_popup_button.dart';

class ChatRoomAppBar extends StatefulWidget {
  const ChatRoomAppBar({Key? key}) : super(key: key);

  @override
  State<ChatRoomAppBar> createState() => _ChatRoomAppBarState();
}

class _ChatRoomAppBarState extends State<ChatRoomAppBar> {
  MenuOptionItem? selectedMenu;
  final controller = Get.put(ChatRoomMessageController());
  // final chatRoomController = Get.put(ChatRoomController());
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.scaffoldBackground,
      elevation: 0.3,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GetBuilder<ChatRoomMessageController>(
            init: ChatRoomMessageController(),
            id: 'appbar',
            builder: (controller) {
              return _buildChatAppbar();
              // return controller.isMultiSelection ? _buildMulitSelectAppbar() : _buildChatAppbar();
            }),
      ),
    );
  }

  Widget _buildChatAppbar() {
    return Row(
      children: [
        InkWell(
            onTap: _onBack,
            child: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.only(left: 8),
                color: Colors.transparent,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.seconderyColor,
                  size: 20,
                ))),
        WidgetBindingProfileRadius(
          borderRadius: 20,
          size: 40,
          avatarUrl: controller.avatar,
          isActive: controller.isOnline,
        ),
        const SizedBox(width: 12),
        const Spacer(),
        SizedBox(
          width: 40,
          child: InkWell(
            onTap: () async {
              _showConformClearChatHistory();
            },
            child: Image.asset(
              "packages/chatmesdk/assets/icons/icon_trash.png",
              width: 20,
              height: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMulitSelectAppbar() {
    return Row(
      children: [
        InkWell(
          onTap: _onCloseMulitSelect,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: SizedBox(
              height: 18,
              width: 18,
              child: Image.asset(
                Assets.app_assetsIconsSearchCloseButton,
              ),
            ),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: _showMulitSelectDialogOption,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: SizedBox(
              height: 24,
              width: 24,
              child: Image.asset(Assets.app_assetsIconsIconTrash),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTotalReadCount(ChatRoomController controller) {
    if (controller.totalMessageUnreadCount > 0) {
      return CircleAvatar(
        backgroundColor: const Color(0xffCD2525),
        radius: 9,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              controller.totalMessageUnreadCount.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFFDFFFD)),
            ),
          ),
        ),
      );
    } else {
      return const Offstage();
    }
  }

  Widget _checkOnlineStatus(bool isOnline, String lastOnline) {
    if (lastOnline == '') {
      return const SizedBox(width: 90);
    }
    if (isOnline) {
      return Text(
        'online'.tr,
        style: const TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w400,
          fontSize: 10,
        ),
      );
    }
    return Text(
      '${'last_online_at'.tr} ${MessageHelper.messageOnlineDateTimeFormat(lastOnline)}',
      style: const TextStyle(
        color: Color(0xff787878),
        fontWeight: FontWeight.w400,
        fontSize: 10,
      ),
    );
  }

  Widget _switchEventType() {
    const textStyle = TextStyle(
      color: Colors.green,
      fontWeight: FontWeight.w400,
      fontSize: 12,
    );
    return controller.isPartycipateReceiveReconding
        ? Row(
            children: [
              Image.asset(Assets.app_assetsIconsVoiceRecording, width: 16),
              const SizedBox(width: 4),
              Text(
                'recording'.tr,
                style: textStyle,
              )
            ],
          )
        : Text(
            controller.isPartycipateTyping
                ? 'typing...'.tr
                : controller.isPartycipateSending
                    ? 'sending_file...'.tr
                    : '',
            style: textStyle,
          );
  }

  void _onBack() {
    Navigator.pop(context);
  }

  void onMuteChat() {}

  void onClearChat() {
    controller.onClearChat();
    Get.back();
  }

  void onReport() {
    var contactId = controller.accountId;
    Get.toNamed('contact_report', arguments: ['User', contactId]);
  }

  void _onCloseMulitSelect() {
    controller.isMultiSelection = false;
    controller.update(['appbar']);
    controller.update();
  }

  void _onMulitpleDelete() {
    Get.back();
    controller.onMulitDelete();
  }

  void _showMulitSelectDialogOption() async {
    var isHaveMessageSelected = controller.listMessage.where((element) => element.isSelect == true).toList();
    if (isHaveMessageSelected.isEmpty) return;
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      context: context,
      builder: (BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 25, left: 16, right: 16),
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(height: .8, color: Colors.grey),
            InkWell(
              onTap: _onMulitpleDelete,
              child: Container(
                height: 60,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  'delete'.tr,
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 60,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  'cancel'.tr,
                  style: const TextStyle(
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

  Future _showConformClearChatHistory() {
    return showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Material(
                child: Container(
                  width: 300,
                  height: 120,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'do_you_want_to_clear_all_messages?'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.seconderyColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 13.3,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 150,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFFD6D6D6), width: 1),
                                right: BorderSide(color: Color(0xFFD6D6D6), width: 1),
                              ),
                            ),
                            child: TextButton(
                              child: Text(
                                'cancel'.tr,
                                style: AppTextStyle.normalTextMediumGrey,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          Container(
                            width: 150,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFFD6D6D6), width: 1),
                                left: BorderSide(color: Color(0xFFD6D6D6), width: 1),
                              ),
                            ),
                            child: TextButton(
                              child: Text(
                                'clear'.tr,
                                style: const TextStyle(
                                  color: AppColors.red,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: () => onClearChat(),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}

enum MenuOptionItem { mute, report, delete }
