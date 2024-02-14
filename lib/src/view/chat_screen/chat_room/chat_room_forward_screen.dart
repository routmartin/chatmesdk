import 'package:chatme/data/chat_room/chatroom_forward_controller.dart';
import 'package:chatme/data/share_contact/model/recent_share_respose_model.dart';
import 'package:chatme/template/profile/widgets/profile_appbar_widget.dart';
import 'package:chatme/template/profile/widgets/profile_scaffold_wrapper.dart';
import 'package:chatme/util/constant/app_assets.dart';
import 'package:chatme/util/helper/font_util.dart';
import 'package:chatme/util/helper/message_helper.dart';
import 'package:chatme/util/text_style.dart';
import 'package:chatme/widgets/container_button.dart';
import 'package:chatme/widgets/fair_binding_widget/widget_binding_profile_radius.dart';
import 'package:chatme/widgets/fair_binding_widget/widget_binding_selection.dart';
import 'package:chatme/widgets/fair_binding_widget/widget_binding_seperate_line.dart';
import 'package:chatme/widgets/loading/base_dialog_loading.dart';
import 'package:debounce_builder/debounce_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatroomForwardScreen extends StatefulWidget {
  const ChatroomForwardScreen({Key? key}) : super(key: key);

  @override
  State<ChatroomForwardScreen> createState() => _ChatroomForwardScreenState();
}

class _ChatroomForwardScreenState extends State<ChatroomForwardScreen> {
  bool isSearching = false;
  bool isMultiSelection = false;
  List<Map<String, dynamic>> selectedContacts = [];

  @override
  Widget build(BuildContext context) {
    return ProfileScaffoldWrapper(
      color: Colors.white,
      padding: 22,
      child: SafeArea(
        child: GetBuilder<ChatroomForwardController>(
            init: ChatroomForwardController(),
            builder: (controller) {
              bool recentShareEmpty = controller.recentlyForwardList.isEmpty;
              bool recentChatEmpty = controller.recentlyChatList.isEmpty;
              var selectedContactLen = selectedContacts.isEmpty ? '' : '(${selectedContacts.length})';
              return Column(
                children: [
                  ProfileAppbarWidget(
                    title: FontUtil.tr('forward'),
                    onBack: () {
                      isMultiSelection
                          ? _onTapClose(
                              controller.recentlyChatList,
                              controller.recentlyForwardList,
                            )
                          : Get.back();
                    },
                    leading: Text(
                      isMultiSelection ? 'close'.tr : 'cancel'.tr,
                      style: AppTextStyle.normalBoldGrey,
                    ),
                    trailing: isMultiSelection
                        ? ContainerButton(
                            text: 'done'.tr + ' $selectedContactLen',
                            buttonWidth: 66,
                            buttonHeight: 26,
                            isActive: selectedContacts.isNotEmpty,
                            textStyle: AppTextStyle.extraSmallTextBoldWhite,
                            onTap: _forwardConfirmationDialog,
                          )
                        : InkWell(
                            onTap: onTapSelect,
                            child: Text(
                              'select'.tr,
                              style: AppTextStyle.normalBold,
                            ),
                          ),
                  ),
                  Expanded(
                    child: controller.isLoading
                        ? Center(child: CircularProgressIndicator.adaptive())
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xFFE1E2E6),
                                      width: 0.33,
                                    ),
                                    color: Color(0xFFEBEBEB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DebounceBuilder(
                                      delay: const Duration(milliseconds: 300),
                                      builder: (context, debounce) {
                                        return TextField(
                                          controller: controller.textEditingController,
                                          autofocus: false,
                                          onChanged: (value) => debounce(() {
                                            if (controller.textEditingController.text.isEmpty) {
                                              setState(() {
                                                isSearching = false;
                                              });
                                            }
                                            if (controller.textEditingController.text.isNotEmpty) {
                                              setState(() {
                                                isSearching = true;
                                              });
                                              controller.getRoomBySearchChat(value);
                                            }
                                          }),
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.search),
                                            contentPadding: EdgeInsets.fromLTRB(0, 14, 12, 0),
                                            suffixIcon: Offstage(
                                              offstage: !isSearching,
                                              child: InkWell(
                                                onTap: () {
                                                  controller.textEditingController.clear();
                                                  setState(() {
                                                    isSearching = false;
                                                  });
                                                },
                                                child: Image.asset(
                                                  Assets.app_assetsIconsSearchCloseButton,
                                                  scale: 2.5,
                                                ),
                                              ),
                                            ),
                                            border: InputBorder.none,
                                            hintText: 'search'.tr,
                                            hintStyle: TextStyle(color: Colors.grey),
                                          ),
                                        );
                                      }),
                                ),
                                SizedBox(height: 18),
                                isSearching
                                    ? Column(
                                        children: [
                                          ...buildSelectionForwardItem(
                                            controller.searchRoomList,
                                            false,
                                          )
                                        ],
                                      )
                                    : (!controller.isLoading & recentShareEmpty && recentChatEmpty)
                                        ? Center(
                                            child: Text(
                                              'user_not_found'.tr,
                                              style: AppTextStyle.normalTextMediumGrey,
                                            ),
                                          )
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Visibility(
                                                visible: !recentShareEmpty,
                                                child: Text(
                                                  'recent_forward'.tr,
                                                  style: AppTextStyle.normalBold,
                                                ),
                                              ),
                                              Visibility(
                                                visible: !recentShareEmpty,
                                                child: const SizedBox(height: 16),
                                              ),
                                              Visibility(
                                                visible: !recentShareEmpty,
                                                child: SizedBox(
                                                  height: 85,
                                                  child: ListView(
                                                      padding: EdgeInsets.zero,
                                                      scrollDirection: Axis.horizontal,
                                                      physics: BouncingScrollPhysics(),
                                                      children: [
                                                        ...buildSelectionForwardItem(
                                                          controller.recentlyForwardList,
                                                          true,
                                                        ),
                                                      ]),
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              Visibility(
                                                visible: !recentChatEmpty,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'recent_chat'.tr,
                                                      style: AppTextStyle.normalBold,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              ...buildSelectionForwardItem(
                                                controller.recentlyChatList,
                                                false,
                                              ),
                                            ],
                                          )
                              ],
                            ),
                          ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  List<Widget> buildSelectionForwardItem(
    List<RecentShareResponseModel> contactList,
    bool radioOnAvatar,
  ) {
    return List.generate(
      contactList.length,
      (index) {
        var _contact = contactList[index];
        return radioOnAvatar
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: InkWell(
                  onTap: () {
                    onItemSelect(_contact);
                  },
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          WidgetBindingProfileRadius(
                            avatarUrl: _contact.avatar ?? '',
                            isActive: false,
                            isGroupProfile: _contact.roomType == 'g',
                            groupName: _contact.fullName ?? '',
                          ),
                          Positioned(
                            bottom: 3,
                            right: -8,
                            child: _selectionRadioWidget(_contact),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 60),
                        child: Text(
                          _contact.fullName ?? '',
                          style: AppTextStyle.smallTextMediumBlack,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  SizedBox(height: 6),
                  Row(
                    children: [
                      _selectionRadioWidget(_contact),
                      Expanded(
                        child: ListTile(
                          onTap: () {
                            onItemSelect(_contact);
                          },
                          leading: WidgetBindingProfileRadius(
                            avatarUrl: _contact.avatar ?? '',
                            isActive: false,
                            isGroupProfile: _contact.roomType == 'g',
                            groupName: _contact.fullName ?? '',
                          ),
                          title: Text(
                            _contact.fullName ?? '',
                            style: AppTextStyle.normalTextMediumBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  WidgetBindingSeperateLine(),
                ],
              );
      },
    );
  }

  void onItemSelect(_contact) {
    if (isMultiSelection) {
      _onRadioButtonSelect(_contact);
    } else {
      onSelected(roomId: _contact.roomId);
    }
  }

  Widget _selectionRadioWidget(RecentShareResponseModel _contact) {
    return WidgetBindngSelection(
      isSelected: _contact.selected,
      onChanged: () => _onRadioButtonSelect(_contact),
      isWidgetShow: isMultiSelection,
    );
  }

  void _onRadioButtonSelect(RecentShareResponseModel _contact) {
    var controller = Get.find<ChatroomForwardController>();

    if (_contact.radioButtonSelectValue.isEmpty) {
      _contact.radioButtonSelectValue = _contact.roomId;
      _contact.selected = true;
      // var indexRecentChat = controller.recentlyChatList
      //     .indexWhere((element) => element.roomId == _contact.roomId);
      // controller.recentlyChatList[indexRecentChat].radioButtonSelectValue =
      //     _contact.roomId;
      // controller.recentlyChatList[indexRecentChat].selected = true;
      // var indexRecentForward = controller.recentlyForwardList
      //     .indexWhere((element) => element.roomId == _contact.roomId);
      // controller.recentlyForwardList[indexRecentForward]
      //     .radioButtonSelectValue = _contact.roomId;
      // controller.recentlyForwardList[indexRecentForward].selected = true;
      selectedContacts.add({_contact.roomId: _contact.roomId});
    } else {
      _contact.selected = false;
      _contact.radioButtonSelectValue = '';
      // var indexRecentChat = controller.recentlyChatList
      //     .indexWhere((element) => element.roomId == _contact.roomId);
      // controller.recentlyChatList[indexRecentChat].radioButtonSelectValue = '';
      // controller.recentlyChatList[indexRecentChat].selected = false;
      // var indexRecentForward = controller.recentlyForwardList
      //     .indexWhere((element) => element.roomId == _contact.roomId);
      // controller
      //     .recentlyForwardList[indexRecentForward].radioButtonSelectValue = '';
      // controller.recentlyForwardList[indexRecentForward].selected = false;
      selectedContacts.add({_contact.roomId: _contact.roomId});
      selectedContacts.removeWhere(((element) => element.entries.first.key == _contact.roomId));
    }
    setState(() {});
  }

  void onSelected({required String roomId}) {
    if (!isMultiSelection) {
      selectedContacts.add({roomId: roomId});
      _forwardConfirmationDialog();
    }
  }

  void _forwardConfirmationDialog() async {
    TextEditingController textEditingController = TextEditingController();
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 300,
                height: 150,
                decoration: BoxDecoration(color: Colors.white),
                child: Material(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Text(
                                'forward_now'.tr,
                                style: AppTextStyle.normalBold,
                              ),
                              Spacer(),
                              Material(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xFFE1E2E6),
                                      width: 0.33,
                                    ),
                                    color: Color(0xFFEBEBEB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextField(
                                    controller: textEditingController,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                      border: InputBorder.none,
                                      hintText: 'leave_a_message'.tr,
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                            decoration: BoxDecoration(
                              border: const Border(
                                top: BorderSide(color: Color(0xFFD6D6D6), width: 1),
                                left: BorderSide(color: Color(0xFFD6D6D6), width: 1),
                              ),
                            ),
                            child: TextButton(
                              child: Text(
                                'forward'.tr,
                                style: AppTextStyle.normalTextGreen,
                              ),
                              onPressed: () {
                                onForwardMessageSubmit(
                                  textEditingController.text.trim(),
                                  selectedContacts,
                                );
                              },
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

  void onForwardMessageSubmit(String message, List contactList) async {
    Get.back();
    BaseDialogLoading.show();
    var controller = Get.find<ChatroomForwardController>();
    String _forwardMessageId = controller.forwardMessageId;
    if (_forwardMessageId.isNotEmpty && contactList.isNotEmpty) {
      contactList.toSet().toList();
      //* need to forward one by one
      List<bool> isForwardSuccess = await Future.wait(
        contactList.map((contact) => controller
                .onForwardMessage(
              contact.entries.first.value,
              message,
              _forwardMessageId,
            )
                .then((_) {
              MessageHelper.playMessageSentSound();
              return true;
            })),
      );

      if (isForwardSuccess.isNotEmpty) {
        Get.back();
      }
    }
    BaseDialogLoading.dismiss();
  }

  void onTapSelect() {
    setState(() {
      selectedContacts.clear();
      isMultiSelection = !isMultiSelection;
    });
  }

  void _onTapClose(
    List<RecentShareResponseModel> recentList,
    List<RecentShareResponseModel> recentShared,
  ) {
    selectedContacts.clear();
    for (var i in recentList) {
      i.selected = false;
    }
    for (var i in recentShared) {
      i.selected = false;
    }
    setState(() {
      isMultiSelection = false;
    });
  }
}
