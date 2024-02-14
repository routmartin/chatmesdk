import 'package:chatme/data/chat_room/chatroom_share_media_controller.dart';
import 'package:chatme/data/search_chat/search_chat_controller.dart';
import 'package:chatme/data/share_contact/model/recent_share_respose_model.dart';
import 'package:chatme/template/profile/widgets/profile_appbar_widget.dart';
import 'package:chatme/template/profile/widgets/profile_scaffold_wrapper.dart';
import 'package:chatme/util/constant/app_assets.dart';
import 'package:chatme/util/helper/font_util.dart';
import 'package:chatme/util/text_style.dart';
import 'package:chatme/widgets/container_button.dart';
import 'package:chatme/widgets/cupertino/icon_dialog.dart';
import 'package:chatme/widgets/fair_binding_widget/widget_binding_profile_radius.dart';
import 'package:chatme/widgets/fair_binding_widget/widget_binding_selection.dart';
import 'package:chatme/widgets/fair_binding_widget/widget_binding_seperate_line.dart';
import 'package:chatme/widgets/loading/base_dialog_loading.dart';
import 'package:debounce_builder/debounce_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatroomShareMediaScreen extends StatefulWidget {
  const ChatroomShareMediaScreen({Key? key}) : super(key: key);

  @override
  State<ChatroomShareMediaScreen> createState() => _ChatroomShareMediaScreenState();
}

class _ChatroomShareMediaScreenState extends State<ChatroomShareMediaScreen> {
  bool isSearching = false;
  bool isMultiSelection = false;
  List<Map<String, dynamic>> selectedContacts = [];

  @override
  Widget build(BuildContext context) {
    return ProfileScaffoldWrapper(
      color: Colors.white,
      padding: 22,
      child: SafeArea(
        child: GetBuilder<ChatroomShareMediaController>(
            init: ChatroomShareMediaController(),
            builder: (controller) {
              bool recentShareEmpty = controller.resultForRecentShare.isEmpty;
              bool recentChatEmpty = controller.resultForRecentChat.isEmpty;
              var selectedContactLen = selectedContacts.isEmpty ? '' : '(${selectedContacts.length})';
              return Column(
                children: [
                  ProfileAppbarWidget(
                    title: FontUtil.tr('share_photo'),
                    onBack: () {
                      isMultiSelection
                          ? onTapClose(controller.resultForRecentChat, controller.resultForRecentShare)
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
                            onTap: () => _shareConfirmationDialog(selectedContacts),
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
                    child: SingleChildScrollView(
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
                          SizedBox(height: 15),
                          ((recentShareEmpty && recentChatEmpty) ||
                                  (isSearching && controller.resultForSearchRoom.isEmpty))
                              ? Center(
                                  child: Text(
                                    'user_not_found'.tr,
                                    style: AppTextStyle.normalTextMediumGrey,
                                  ),
                                )
                              : isSearching
                                  ? Column(
                                      children: [
                                        ...buildAvatar(
                                          controller.resultForSearchRoom,
                                          false,
                                        )
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Visibility(
                                          visible: !recentShareEmpty,
                                          child: Text(
                                            'recent_share'.tr,
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
                                                  ...buildAvatar(
                                                    controller.resultForRecentShare,
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
                                              // Text(
                                              //   'new_chat'.tr,
                                              //   style: AppTextStyle
                                              //       .smallTextMediumGreen,
                                              // ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        ...buildAvatar(
                                          controller.resultForRecentChat,
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

  List<Widget> buildAvatar(
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
                child: Column(
                  children: [
                    Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            if (isMultiSelection) {
                              _onRadioButtonSelect(_contact);
                            } else {
                              onSelected(roomId: _contact.roomId);
                            }
                          },
                          child: WidgetBindingProfileRadius(
                            avatarUrl: _contact.avatar ?? '',
                            isActive: false,
                            isGroupProfile: _contact.roomType == 'g',
                            groupName: _contact.fullName ?? '',
                          ),
                        ),
                        Positioned(
                          bottom: 3,
                          right: -8,
                          child: _selectionRadioWidget(_contact, true),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 60),
                      child: Text(
                        _contact.fullName ?? '',
                        style: TextStyle(fontSize: 13, color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  SizedBox(height: 6),
                  Row(
                    children: [
                      _selectionRadioWidget(_contact, false),
                      Expanded(
                        child: ListTile(
                          onTap: () {
                            if (isMultiSelection) {
                              _onRadioButtonSelect(_contact);
                            } else {
                              onSelected(roomId: _contact.roomId);
                            }
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

  Widget _selectionRadioWidget(RecentShareResponseModel _contact, bool isRecentItem) {
    return WidgetBindngSelection(
      isSelected: _contact.selected,
      onChanged: () => _onRadioButtonSelect(_contact),
      isWidgetShow: isMultiSelection,
      borderColor: isRecentItem ? Colors.white : Colors.grey,
    );
  }

  void _onRadioButtonSelect(RecentShareResponseModel _contact) {
    if (_contact.radioButtonSelectValue.isEmpty) {
      _contact.radioButtonSelectValue = _contact.roomId;
      _contact.selected = true;
      selectedContacts.add({_contact.roomId: _contact.roomId});
    } else {
      _contact.selected = false;
      _contact.radioButtonSelectValue = '';
      selectedContacts.removeWhere(((element) => element.entries.first.key == _contact.roomId));
    }
    setState(() {});
  }

  void onSelected({required String roomId}) {
    if (!isMultiSelection) {
      // TODO
      selectedContacts.add({roomId: roomId});
      _shareConfirmationDialog(selectedContacts);
    }
  }

  void _shareConfirmationDialog(
    List<Map<String, dynamic>> listContact,
  ) async {
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
                                'share_now'.tr,
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
                                'share'.tr,
                                style: AppTextStyle.normalTextGreen,
                              ),
                              onPressed: () {
                                onShareMessageSubmit(
                                  textEditingController.text.trim(),
                                  listContact,
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

  void onShareMessageSubmit(String message, List contactList) async {
    Get.back();
    BaseDialogLoading.show();
    String sharedImageId = Get.find<ChatroomShareMediaController>().imageId;
    if (sharedImageId.isNotEmpty && contactList.isNotEmpty) {
      contactList.toSet().toList();
      final searchController = Get.put(SearchChatController());
      List<bool> isShareSuccess = await Future.wait(contactList.map((contact) async {
        var roomId = contact.entries.first.value;
        var req = {
          'body': {'module': 'recentShare', 'data': roomId}
        };
        var success = await Get.find<ChatroomShareMediaController>().onSentMediaMessage([sharedImageId], 'media',
            message: message.trim() != '' ? message : null, sharedRoomId: roomId);
        await searchController.saveSearchHistory(req);
        return success;
      }));
      if (isShareSuccess.isNotEmpty) {
        Get.back();
        Future.delayed(Duration(milliseconds: 1000), () {
          Get.back();
        });
        await showDialog(
            barrierDismissible: false,
            context: Get.context!,
            builder: (ctx) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: CupertinoDialogIcon(text: 'shared'.tr),
                ),
              );
            });
      }
    }
    BaseDialogLoading.dismiss();
  }

  void onTapSelect() {
    setState(() {
      isMultiSelection = !isMultiSelection;
    });
  }

  void onTapClose(
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
