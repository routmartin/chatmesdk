import 'package:chatme/data/chat_room/chat_room_controller.dart';
import 'package:chatme/data/chat_room/model/chat_model/chat_room_model.dart';
import 'package:chatme/template/chat_screen/chat_room_listing/room_listing_function.dart';
import 'package:chatme/util/constant/app_assets.dart';
import 'package:chatme/util/text_style.dart';
import 'package:chatme/widgets/fair_binding_widget/widget_binding_profile_radius.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PersonRoomListTile extends StatefulWidget {
  const PersonRoomListTile({
    Key? key,
    required this.model,
    required this.controller,
  }) : super(key: key);
  final ChatRoomModel model;
  final ChatRoomController controller;

  @override
  State<PersonRoomListTile> createState() => _PersonalChatListBodyState();
}

class _PersonalChatListBodyState extends State<PersonRoomListTile> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatRoomController>(
        id: widget.model.id ?? 'official',
        builder: (controller) {
          return ListTile(
            onTap: () async {
              if (widget.model.type == 'g') {
                await navigateToGroupChatMessage(widget.model, true);
              } else {
                await navigateToChatMessage(widget.model, true);
              }
            },
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            leading: WidgetBindingProfileRadius(
              isActive: widget.model.statusOnline,
              borderRadius: 8,
              avatarUrl: widget.model.avatar ?? '',
              isGroupProfile: widget.model.type == 'g',
              groupName: widget.model.name,
            ),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.model.name,
                          style: AppTextStyle.normalTextMediumBlackRoomTitle,
                        ),
                      ),
                      Container(
                        width: 30,
                        child: Row(
                          children: [
                            (widget.model.isOfficial ?? false)
                                ? Image.asset(
                                    Assets.app_assetsIconsOfficialTag,
                                    scale: 5,
                                  )
                                : Offstage(),
                            const SizedBox(width: 2),
                            Flexible(
                              flex: 1,
                              child: Visibility(
                                visible: widget.model.isMuted,
                                child: Image.asset(
                                  Assets.app_assetsIconsIconMuted,
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                generateTimeStamp(widget.model),
              ],
            ),
            subtitle: SizedBox(
              height: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _generateActivityMessage(),
                  widget.model.lastMessage == null
                      ? Offstage()
                      : Container(
                          alignment: Alignment.centerRight,
                          child: generateLowerTrailing(widget.model),
                        )
                ],
              ),
            ),
          );
        });
  }

  Widget _generateActivityMessage() {
    final _recordingIcon = Image.asset(
      Assets.app_assetsIconsVoiceRecording,
      width: 15,
      height: 15,
    );
    if (widget.model.isTyping) {
      return listenSubtypeActionWidget('typing...'.tr, widget.model);
    }
    if (widget.model.isRecording) {
      if (widget.model.type == 'g') {
        return Expanded(
          child: Row(
            children: [
              _recordingIcon,
              listenSubtypeActionWidget(
                  '${widget.model.whoRecording?.first.toString() ?? ''} ' + 'recording'.tr + '...'),
            ],
          ),
        );
      }
      return Expanded(
        child: Row(
          children: [
            _recordingIcon,
            Text(
              'recording'.tr + '...',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w400,
                fontSize: 13.33,
              ),
            ),
          ],
        ),
      );
    }
    if (widget.model.isUploading) {
      if (widget.model.type == 'g') {
        return listenSubtypeActionWidget('you'.tr + ' ' + 'is_sending_file'.tr + '...');
      }
      return listenSubtypeActionWidget('sending'.tr + '...');
    }
    if (widget.model.isRecieving) {
      if (widget.model.type == 'g') {
        return listenSubtypeActionWidget('${widget.model.whoSending ?? ''} ' + 'is_sending_file'.tr + '...');
      }
      return listenSubtypeActionWidget('sending_file...'.tr);
    }
    return Expanded(
      child: generateMessage(widget.model, widget.model.type == 'g'),
    );
  }
}
