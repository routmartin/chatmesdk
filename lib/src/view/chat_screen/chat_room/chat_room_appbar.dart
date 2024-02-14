import 'package:chatme/data/chat_room/chat_room_controller.dart';
import 'package:chatme/data/chat_room/chat_room_message_controller.dart';
import 'package:chatme/routes/app_routes.dart';
import 'package:chatme/template/chat_screen/chat_room/widget/message_popup_button.dart';
import 'package:chatme/util/constant/app_asset.dart';
import 'package:chatme/util/helper/chat_helper.dart';
import 'package:chatme/util/helper/message_helper.dart';
import 'package:chatme/util/text_style.dart';
import 'package:chatme/widgets/fair_binding_widget/widget_binding_profile_radius.dart';
import 'package:chatme/widgets/widget_view_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatRoomAppBar extends StatefulWidget {
  const ChatRoomAppBar({Key? key}) : super(key: key);

  @override
  State<ChatRoomAppBar> createState() => _ChatRoomAppBarState();
}

class _ChatRoomAppBarState extends State<ChatRoomAppBar> {
  MenuOptionItem? selectedMenu;
  final controller = Get.put(ChatRoomMessageController());
  final ChatRoomController chatRoomController = Get.put(ChatRoomController());
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
              return controller.isMultiSelection
                  ? _buildMulitSelectAppbar()
                  : _buildChatAppbar();
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
            width: Get.width * .14,
            color: Colors.transparent,
            height: 40,
            alignment: Alignment.center,
            child: GetBuilder<ChatRoomController>(
                id: 'totalCount',
                builder: (_roomController) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment:
                        _roomController.totalMessageUnreadCount > 0
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        Assets.app_assetsIconsSearchBackButton,
                        color: Colors.black,
                        height: 16,
                        width: 16,
                      ),
                      buildTotalReadCount(_roomController),
                      SizedBox(width: 10),
                    ],
                  );
                }),
          ),
        ),
        InkWell(
          onTap: controller.avatar.isEmpty
              ? null
              : () async =>
                  await Get.to(() => ViewProfilePhotos(url: controller.avatar)),
          child: GestureDetector(
            onTap: controller.avatar == ''
                ? null
                : () => _navigateToViewProfile(controller.avatar),
            child: WidgetBindingProfileRadius(
              borderRadius: 8,
              size: 45,
              avatarUrl: controller.avatar,
              isActive: controller.isOnline,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: controller.isOfficial
                ? null
                : () => controller
                    .navigateToViewContactFromAppBarTap(controller.profileId),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (!controller.isOfficial)
                      ? Row(
                          children: [
                            Flexible(
                              child: Text(
                                controller.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            AnimatedOpacity(
                              opacity: controller.isMute ? 1 : 0,
                              duration: Duration(milliseconds: 400),
                              child: Image.asset(
                                Assets.app_assetsIconsChatMuteIcon,
                                width: 12,
                                height: 12,
                              ),
                            ),
                            SizedBox(width: 4),
                          ],
                        )
                      : Row(
                          children: [
                            Text(
                              controller.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 4),
                            Image.asset(
                              Assets.app_assetsIconsOfficialTag,
                              scale: 4,
                            ),
                            SizedBox(width: 6),
                            AnimatedOpacity(
                              opacity: controller.isMute ? 1 : 0,
                              duration: Duration(milliseconds: 400),
                              child: Image.asset(
                                Assets.app_assetsIconsChatMuteIcon,
                                width: 12,
                                height: 12,
                              ),
                            ),
                            SizedBox(width: 4),
                          ],
                        ),
                  SizedBox(height: 2),
                  if (!controller.isOfficial)
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedCrossFade(
                            crossFadeState: controller.isPartycipateTyping ||
                                    controller.isPartycipateSending ||
                                    controller.isPartycipateReceiveReconding
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: Duration(milliseconds: 400),
                            firstChild: _switchEventType(),
                            secondChild: AnimatedContainer(
                              duration: Duration(milliseconds: 400),
                              padding: EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: controller.isOnline
                                    ? Colors.green.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: controller.isShowOffline
                                  ? Text(
                                      'offline'.tr,
                                      style: TextStyle(
                                          color: Color(0xff787878),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10,
                                          overflow: TextOverflow.ellipsis),
                                      maxLines: 1,
                                    )
                                  : _checkOnlineStatus(
                                      controller.isOnline,
                                      controller.lastOnlineAt,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        /*
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50.0),
          child: InkWell(
            onTap: controller.onPersonalAudioCall,
            child: Container(
              padding: EdgeInsets.only(),
              alignment: Alignment.center,
              child: Image.asset(
                Assets.app_assetsIconsIcPhoneCall,
                width: 24,
                height: 24,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50.0),
          child: InkWell(
            onTap: () {
              /*
              Get.to(
                () => VideoCallScreen(),
                transition: Transition.fadeIn,
              );
              */
            },
            child: Container(
              alignment: Alignment.center,
              child: Image.asset(
                Assets.app_assetsIconsTurnOnVideo,
                width: 28,
                height: 28,
                color: AppColors.buttonVideoBackground,
              ),
            ),
          ),
        ),
        */
        Container(
          color: Colors.transparent,
          width: 45,
          child: MessagePopupButton(
            pressType: PressType.tap,
            isShowArrow: false,
            direction: PopupDirection.top,
            offset: Offset(0, -10),
            child: Icon(Icons.more_vert, color: Colors.black),
            builder: (context, onClose) {
              return Material(
                elevation: 2,
                child: FittedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      PopupMenuItem<MenuOptionItem>(
                        value: MenuOptionItem.mute,
                        child: InkWell(
                          onTap: () {
                            onClose();
                            onMuteChat();
                          },
                          child: SizedBox(
                            width: 120,
                            child: controller.isMute
                                ? popMenuItem(
                                    Assets.app_assetsIconsChatMuteIcon,
                                    'ummute')
                                : popMenuItem(
                                    Assets.app_assetsIconsChatUnmuteIcon,
                                    'mute'),
                          ),
                        ),
                      ),
                      PopupMenuItem<MenuOptionItem>(
                        value: MenuOptionItem.report,
                        child: InkWell(
                            onTap: () {
                              onClose();
                              onReport();
                            },
                            child: popMenuItem(
                                Assets.app_assetsIconsIconInfo, 'report')),
                      ),
                      PopupMenuItem<MenuOptionItem>(
                        value: MenuOptionItem.delete,
                        child: InkWell(
                          onTap: () {
                            onClose();
                            _showConformClearChatHistory();
                          },
                          child: popMenuItem(
                              Assets.app_assetsIconsIconTrash, 'clear_chat'),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        padding: EdgeInsets.only(top: 6.0, bottom: 8.0),
                        height: 48.0,
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onClose();
                            Get.toNamed(
                              Routes.search_chat_message,
                              arguments: [controller.roomId, false],
                            );
                          },
                          child: Row(
                            children: [
                              SizedBox(width: 20.0),
                              Image.asset(
                                Assets.app_assetsIconsHomeSearchButton,
                                width: 20.0,
                                height: 20.0,
                              ),
                              SizedBox(width: 6.0),
                              Text(
                                'search'.tr,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
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
        Spacer(),
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
        backgroundColor: Color(0xffCD2525),
        radius: 9,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              controller.totalMessageUnreadCount.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFFDFFFD)),
            ),
          ),
        ),
      );
    } else {
      return Offstage();
    }
  }

  Widget _checkOnlineStatus(bool isOnline, String lastOnline) {
    if (lastOnline == '') {
      return SizedBox(width: 90);
    }
    if (isOnline) {
      return Text(
        'online'.tr,
        style: TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w400,
          fontSize: 10,
        ),
      );
    }
    return Text(
      'last_online_at'.tr +
          ' ' +
          MessageHelper.messageOnlineDateTimeFormat(lastOnline),
      style: TextStyle(
        color: Color(0xff787878),
        fontWeight: FontWeight.w400,
        fontSize: 10,
      ),
    );
  }

  Widget popMenuItem(String icon, String text) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
        child: Row(
          children: [
            Image.asset(icon, scale: 4),
            const SizedBox(width: 8),
            Text(text.tr),
          ],
        ),
      );

  Widget _switchEventType() {
    final _textStyle = TextStyle(
      color: Colors.green,
      fontWeight: FontWeight.w400,
      fontSize: 12,
    );
    return controller.isPartycipateReceiveReconding
        ? Row(
            children: [
              Image.asset(Assets.app_assetsIconsVoiceRecording, width: 16),
              SizedBox(width: 4),
              Text(
                'recording'.tr,
                style: _textStyle,
              )
            ],
          )
        : Text(
            controller.isPartycipateTyping
                ? 'typing...'.tr
                : controller.isPartycipateSending
                    ? 'sending_file...'.tr
                    : '',
            style: _textStyle,
          );
  }

  void _onBack() {
    Get.back();
    ChatHelper.onTrackRoomOFF();
  }

  void onMuteChat() {
    controller.onMuteChat();
  }

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

  void _navigateToViewProfile(String? _profileUrl) {
    Get.to(() => ViewProfilePhotos(url: _profileUrl ?? ''),
        transition: Transition.fadeIn, duration: Duration(milliseconds: 200));
  }

  void _showMulitSelectDialogOption() async {
    var _isHaveMessageSelected = controller.listMessage
        .where((element) => element.isSelect == true)
        .toList();
    if (_isHaveMessageSelected.isEmpty) return;
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      context: context,
      builder: (BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 25, left: 16, right: 16),
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(height: .8, color: Colors.grey),
            InkWell(
              onTap: _onMulitpleDelete,
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

  void _showConformClearChatHistory() async {
    return await showCupertinoDialog(
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
                            style: TextStyle(
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
                            decoration: BoxDecoration(
                              border: const Border(
                                top: BorderSide(
                                    color: Color(0xFFD6D6D6), width: 1),
                                right: BorderSide(
                                    color: Color(0xFFD6D6D6), width: 1),
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
                            decoration: BoxDecoration(
                              border: const Border(
                                top: BorderSide(
                                    color: Color(0xFFD6D6D6), width: 1),
                                left: BorderSide(
                                    color: Color(0xFFD6D6D6), width: 1),
                              ),
                            ),
                            child: TextButton(
                              child: Text(
                                'clear'.tr,
                                style: TextStyle(
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
