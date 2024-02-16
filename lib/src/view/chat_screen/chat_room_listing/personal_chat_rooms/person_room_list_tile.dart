import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/chat_room/chat_room.dart';
import '../../../../data/chat_room/model/chat_model/chat_room_model.dart';
import '../../../../util/constant/app_assets.dart';
import '../../../../util/text_style.dart';
import '../../../widget/widget_binding_profile_radius.dart';
import '../room_listing_function.dart';

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
              await navigateToChatMessage(widget.model, true);
            },
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                      SizedBox(
                        width: 30,
                        child: Row(
                          children: [
                            (widget.model.isOfficial ?? false)
                                ? Image.asset(
                                    Assets.app_assetsIconsOfficialTag,
                                    scale: 5,
                                  )
                                : const Offstage(),
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
                      ? const Offstage()
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
    final recordingIcon = Image.asset(
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
              recordingIcon,
              listenSubtypeActionWidget('${widget.model.whoRecording?.first.toString() ?? ''} ${'recording'.tr}...'),
            ],
          ),
        );
      }
      return Expanded(
        child: Row(
          children: [
            recordingIcon,
            Text(
              '${'recording'.tr}...',
              style: const TextStyle(
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
        return listenSubtypeActionWidget('${'you'.tr} ${'is_sending_file'.tr}...');
      }
      return listenSubtypeActionWidget('${'sending'.tr}...');
    }
    if (widget.model.isRecieving) {
      if (widget.model.type == 'g') {
        return listenSubtypeActionWidget('${widget.model.whoSending ?? ''} ${'is_sending_file'.tr}...');
      }
      return listenSubtypeActionWidget('sending_file...'.tr);
    }
    return Expanded(
      child: generateMessage(widget.model, widget.model.type == 'g'),
    );
  }
}
