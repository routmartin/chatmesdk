import 'package:chatmesdk/src/data/chat_room/model/chat_model/chat_room_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../../../../data/chat_room/chat_room.dart';
import '../../../../util/constant/call_enum.dart';
import '../../../../util/text_style.dart';
import '../room_listing_function.dart';
import 'person_room_list_tile.dart';

class PersonRoomListingBody extends StatefulWidget {
  const PersonRoomListingBody({
    Key? key,
  }) : super(key: key);

  @override
  State<PersonRoomListingBody> createState() => _PersonRoomListBodyState();
}

class _PersonRoomListBodyState extends State<PersonRoomListingBody> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatRoomController>(
        id: 'list',
        init: ChatRoomController(),
        builder: (controller) {
          if (controller.isPersonalListLoading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          } else {
            int length = controller.chatRoomList.length;
            var key = controller.listTileKey;
            if (length > 0) {
              return SlidableAutoCloseBehavior(
                child: AnimatedList(
                  key: key,
                  initialItemCount: length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index, animation) {
                    ChatRoomModel chatModel = controller.chatRoomList[index];
                    return slidableRoomItems(
                      index,
                      controller,
                      context,
                      key,
                      animation,
                      chatModel,
                      ChatType.all,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6.0),
                        child: PersonRoomListTile(
                          model: chatModel,
                          controller: controller,
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image.asset('assets/icons/group_people.png', scale: 4),
                    Text(
                      'no_chat'.tr,
                      style: AppTextStyle.h4BoldBlack,
                    ),
                  ],
                ),
              );
            }
          }
        });
  }
}
