import 'package:chatme/data/chat_room/chat_room_controller.dart';
import 'package:chatme/data/confirm_friend/confirm_friend_controller.dart';
import 'package:chatme/routes/app_routes.dart';
import 'package:chatme/template/chat_screen/chat_room_listing/personal_chat_rooms/person_room_list_tile.dart';
import 'package:chatme/util/constant/call_enum.dart';
import 'package:chatme/util/text_style.dart';
import 'package:chatme/widgets/base_scroll_to_top.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../../../../util/constant/app_assets.dart';
import '../room_listing_function.dart';

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
        builder: (controller) {
          if (controller.isPersonalListLoading) {
            return Center(
              child: CircularProgressIndicator.adaptive(),
            );
          } else {
            int length = controller.chatRoomList.length;
            var key = controller.listTileKey;
            if (length > 0) {
              return BaseScrollToTop(
                scrollController: controller.funcBaseScrollToTop.scrollController,
                children: [
                  SlidableAutoCloseBehavior(
                    child: AnimatedList(
                      key: key,
                      initialItemCount: length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index, animation) {
                        var chatModel;
                        try {
                          chatModel = controller.chatRoomList[index];
                        } catch (e) {
                          print(e);
                        }
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
                  ),
                  const SizedBox(height: 8),
                  //TODO:improve this block
                  InkWell(
                    onTap: () async {
                      await Get.toNamed(Routes.invite_friend_by)?.then((_) {
                        Get.find<ConfirmFriendController>().fetchAllRequestFriendList();
                        Get.find<ChatRoomController>().getAllPersonRoom();
                      });
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'invite_friend_to_register_>'.tr,
                        style: AppTextStyle.normalTextGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            } else {
              return Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.app_assetsIconsGroupPeople,
                      scale: 4,
                    ),
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
