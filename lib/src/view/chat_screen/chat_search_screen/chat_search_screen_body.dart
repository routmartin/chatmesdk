import 'package:chatme/data/chat_room/chat_room_message_controller.dart';
import 'package:chatme/data/chat_room/model/message_response_model.dart';
import 'package:chatme/data/group_room/group_message_controller.dart';
import 'package:chatme/data/group_room/group_setting_controller.dart';
import 'package:chatme/data/profile/controller/account_user_profile_controller.dart';
import 'package:chatme/data/search_chat/model/search_chat_contact_group_response_model/group_history_model.dart';
import 'package:chatme/data/search_chat/model/search_chat_history_response_model/chat_recent_search_model.dart';
import 'package:chatme/data/search_chat/search_chat_controller.dart';

import 'package:chatme/template/chat_screen/chat_search_screen/widget_binding_search_bar.dart';
import 'package:chatme/util/constant/app_asset.dart';

import 'package:chatme/util/helper/date_time.dart';
import 'package:chatme/util/helper/message_helper.dart';
import 'package:chatme/util/text_style.dart';
import 'package:chatme/widgets/fair_binding_widget/widget_binding_profile_radius.dart';
import 'package:debounce_builder/debounce_builder.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatSearchScreenBody extends StatefulWidget {
  const ChatSearchScreenBody({Key? key}) : super(key: key);

  @override
  State<ChatSearchScreenBody> createState() => _ChatSearchScreenBodyState();
}

class _ChatSearchScreenBodyState extends State<ChatSearchScreenBody> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchChatController>(
        init: SearchChatController(),
        builder: (controller) {
          var chatContactList = controller.chatAndContactSearch;
          var groupSearchList = controller.groupSearch;
          var chatHistoryList = controller.chatHistoryList;
          var recentSearchHistoryList = controller.chatRecentSearchList;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    SizedBox(height: 14),
                    DebounceBuilder(
                        delay: const Duration(seconds: 1),
                        builder: (context, debounce) {
                          return WidgetBindingSearchBar(
                            hintText: 'search_chats',
                            searchController: searchController,
                            onChange: (_) => debounce(
                              () => _onSearch(controller),
                            ),
                            autofocus: true,
                          );
                        }),
                    Expanded(
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (chatHistoryList.isEmpty &&
                                    groupSearchList.isEmpty &&
                                    recentSearchHistoryList.isEmpty &&
                                    searchController.text.trim().isNotEmpty)
                                  Center(
                                    child: Text(
                                      'chat_not_found'.tr,
                                      style: const TextStyle(
                                        color: Color(0xff787878),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                else
                                //**recently chat section */
                                if (recentSearchHistoryList.isNotEmpty) ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'recent_searches'.tr,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _clearRecentSearch,
                                        child: Text(
                                          'clear_all'.tr,
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    height: 75,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: recentSearchHistoryList.length,
                                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (BuildContext context, int index) {
                                        ChatRecentSearchModel _model = recentSearchHistoryList[index];
                                        return _recentSearchCard(_model);
                                      },
                                    ),
                                  )
                                ],
                                //*chats and contact
                                if (chatContactList.isNotEmpty) ...[
                                  const SizedBox(height: 18),
                                  Text(
                                    'chats_and_contacts'.tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  ...List.generate(
                                    chatContactList.length,
                                    (index) {
                                      var _model = chatContactList[index];
                                      return GestureDetector(
                                        onTap: () {
                                          var chatArugment = [_model.id];
                                          _onSaveHistory(controller, _model.id!);
                                          _navigateToChatMessage(chatArugment);
                                        },
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 18),
                                            ColoredBox(
                                              color: Colors.transparent,
                                              child: Row(
                                                children: chatAvatar(
                                                  title: _model.name,
                                                  subTitle: 'id:'.tr + (' ${_model.accountId}'),
                                                  imagePath: _model.avatar,
                                                  isActive: false,
                                                  mentions: [],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                                //*Group Chat
                                if (groupSearchList.isNotEmpty) ...[
                                  const SizedBox(height: 18),
                                  Text('group_chat'.tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                      )),
                                  ...List.generate(
                                    groupSearchList.length,
                                    (index) {
                                      GroupHistoryModal _model = groupSearchList[index];
                                      return GestureDetector(
                                        onTap: () {
                                          var chatArugment = [
                                            _model.id,
                                          ];
                                          _onSaveHistory(controller, _model.id);
                                          _navigateToGroupChatMessage(chatArugment);
                                        },
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 18),
                                            ColoredBox(
                                              color: Colors.transparent,
                                              child: Row(
                                                children: chatAvatar(
                                                  title: _model.name,
                                                  subTitle: '${FontUtil.tr('members')}: ${_model.memberName}',
                                                  imagePath: _model.avatar,
                                                  isActive: false,
                                                  isGroup: true,
                                                  mentions: [],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                                //**Chat history section */
                                if (chatHistoryList.isNotEmpty) ...[
                                  const SizedBox(height: 18),
                                  Text('chat_history'.tr, style: TextStyle(fontSize: 16)),
                                  ...List.generate(
                                    chatHistoryList.length,
                                    (index) {
                                      var _model = chatHistoryList[index];
                                      print('_model $_model');
                                      String? userId = Get.find<AccountUserProfileController>().profile?.id;
                                      bool senderIsMe = userId == _model.sender;
                                      String? message = _model.messageType == 'activity'
                                          ? MessageHelper.findActivityMessage(_model.message!, _model.args!)
                                          : _model.message;
                                      print('_model $_model');
                                      return GestureDetector(
                                        onTap: () {
                                          var chatArugment = [_model.room, _model.createdAt!.toIso8601String()];
                                          _onSaveHistory(controller, _model.room!);
                                          if (_model.type == 'g') {
                                            _navigateToGroupChatMessage(chatArugment);
                                          } else {
                                            _navigateToChatMessage(chatArugment);
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 18),
                                            ColoredBox(
                                              color: Colors.transparent,
                                              child: Row(
                                                children: chatAvatar(
                                                  title: _model.name,
                                                  subTitle: '${senderIsMe ? '${FontUtil.tr('you:')}' : ''}$message',
                                                  imagePath: _model.avatar,
                                                  isActive: _model.isOnline,
                                                  timeStamp: (_model.createdAt),
                                                  isGroup: _model.type == 'g',
                                                  mentions: _model.mentions,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                                SizedBox(height: 35),
                              ],
                            ),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: GetBuilder<SearchChatController>(
                                  id: 'loading',
                                  builder: (ctl) {
                                    return Center(
                                      child: ctl.isLoading ? CircularProgressIndicator.adaptive() : Offstage(),
                                    );
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _clearRecentSearch() {
    Get.find<SearchChatController>().clearRecentSearchHistory();
  }

  Widget _recentSearchCard(ChatRecentSearchModel _model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.5),
      child: GestureDetector(
        onTap: () {
          var chatArugment = [
            _model.roomId,
          ];
          if (_model.roomType == 'g') {
            _navigateToGroupChatMessage(chatArugment);
          } else {
            _navigateToChatMessage(chatArugment);
          }
        },
        child: Column(
          children: [
            WidgetBindingProfileRadius(
              avatarUrl: _model.avatar ?? 'n/a',
              isActive: _model.isOnline ?? false,
              size: 46,
              isGroupProfile: _model.roomType == 'g',
              groupName: _model.name ?? '',
            ),
            SizedBox(
              height: 6,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 60),
              child: Text(
                _model.name ?? '',
                style: TextStyle(fontSize: 13, color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> chatAvatar({
    String? title,
    String? subTitle,
    String? imagePath,
    bool? isActive,
    DateTime? timeStamp,
    bool isGroup = false,
    List<Mention>? mentions,
  }) {
    final textStyle = AppTextStyle.smallTextMessage;
    return [
      WidgetBindingProfileRadius(
        avatarUrl: imagePath ?? 'n/a',
        isActive: isActive ?? false,
        isGroupProfile: isGroup,
        groupName: title ?? '',
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title ?? 'n/a',
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            if (mentions!.isNotEmpty) ...[
              MessageHelper.messageTextParser(
                subTitle ?? '',
                textStyle,
                mentions,
                true,
                onClickMention: (id) => print(id),
                mentionStyle: textStyle,
              ),
            ] else ...[
              Text(
                '${subTitle ?? 'n/a'}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF787878)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            ]
          ],
        ),
      ),
      if (timeStamp != null) SizedBox(width: 10),
      Text(
        DateTimeHelper.timeStamp(timeStamp),
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF374957),
        ),
      ),
    ];
  }

  void _onSearch(SearchChatController controller) {
    if (searchController.text.isNotEmpty) {
      controller.searchAll(searchController.text.trim());
    } else {
      controller.chatAndContactSearch = [];
      controller.groupSearch = [];
      controller.chatHistoryList = [];
      controller.update();
    }
  }

  void _onSaveHistory(SearchChatController controller, String roomId) {
    var req = {
      'body': {'module': 'recentSearch', 'data': roomId}
    };
    if (roomId.isNotEmpty) {
      controller.saveSearchHistory(req);
    }
  }

  Future<void> _navigateToGroupChatMessage(List<dynamic> chatArugments) async {
    Get.lazyPut(() => GroupSettingController());
    await Get.toNamed('/group_chat_room_message', arguments: chatArugments)?.then((_) async {
      //  await ChatHelper.onTrackRoomOFF();
      await Get.find<GroupMessageController>().saveDraftMessage();
    });
  }

  Future<void> _navigateToChatMessage(List<dynamic> chatArugments) async {
    await Get.toNamed('/chat_room_message', arguments: chatArugments)?.then((_) async {
      // await ChatHelper.onTrackRoomOFF();
      await Get.find<ChatRoomMessageController>().saveDraftMessage();
    });
  }
}
