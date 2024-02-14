import 'package:chatme/data/profile/controller/account_user_profile_controller.dart';
import 'package:chatme/template/chat_screen/chat_room/widget/base_view_chat_me.dart';
import 'package:chatme/template/chat_screen/chat_room_listing/personal_chat_rooms/person_room_listing_body.dart';
import 'package:chatme/util/constant/app_assets.dart';
import 'package:chatme/widgets/chat/chatlist_update_loading_widget.dart';
import 'package:chatme/widgets/fair_binding_widget/widget_binding_search_button.dart';
import 'package:chatme/widgets/network_connection_text_widget%20copy.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PersonRoomListingScreen extends StatefulWidget {
  const PersonRoomListingScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<PersonRoomListingScreen> createState() => _PersonRoomListingScreen();
}

class _PersonRoomListingScreen extends State<PersonRoomListingScreen> {
  @override
  void initState() {
    super.initState();
    Get.put(AccountUserProfileController());
  }

  @override
  Widget build(BuildContext context) {
    return BaseViewChatMe(
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 14),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Image.asset(Assets.app_assetsImagesChatmeLogo, height: 35),
                    ),
                    Expanded(
                      flex: 2,
                      child: ChatListUpdateLoadingWidget(isFromGroup: false),
                    ),
                    Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            WidgetBindingSearchButton(
                              onTap: _navigateToSearchContact,
                            ),
                            SizedBox(width: 12),
                            InkWell(
                              onTap: _navigateToScanQRScreen,
                              child: Image.asset(
                                Assets.app_assetsIconsHomeQr,
                                scale: 4,
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            ),
            NetworkConnectionTextWidget(),
            Expanded(child: PersonRoomListingBody()),
          ],
        ),
      ),
    );
  }

  void _navigateToScanQRScreen() {
    Get.toNamed('/scan_qr_with_desktop');
  }

  void _navigateToSearchContact() {
    Get.toNamed('/chatSearch');
  }
}
