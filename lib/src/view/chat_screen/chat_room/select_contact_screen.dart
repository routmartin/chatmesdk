import 'dart:io';

import 'package:chatme/data/chat_room/chat_room_message_controller.dart';
import 'package:chatme/data/contact/contact_controller.dart';
import 'package:chatme/data/contact/model/contact_model.dart';
import 'package:chatme/data/profile/controller/account_user_profile_controller.dart';
import 'package:chatme/template/contact/contact_screen/widgets/contact_section_listview.dart';
import 'package:chatme/template/profile/widgets/profile_appbar_widget.dart';
import 'package:chatme/template/profile/widgets/profile_scaffold_wrapper.dart';
import 'package:chatme/util/constant/app_asset.dart';
import 'package:chatme/util/text_style.dart';
import 'package:chatme/widgets/fair_binding_widget/widget_binding_profile_radius.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectContactScreen extends StatefulWidget {
  final String? contentType;
  final String? imagePath;

  const SelectContactScreen({
    required this.contentType,
    this.imagePath,
    Key? key,
  }) : super(key: key);

  @override
  State<SelectContactScreen> createState() => _SelectContactScreenState();
}

class _SelectContactScreenState extends State<SelectContactScreen> {
  // TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ProfileScaffoldWrapper(
      color: Colors.white,
      child: Column(
        children: [
          ProfileAppbarWidget(title: 'select_contact_'),
          Expanded(
              child: GetBuilder<ContactController>(
                  init: ContactController(),
                  builder: (controller) {
                    return ListView(
                      physics: BouncingScrollPhysics(),
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: SectionListView(
                            key: UniqueKey(),
                            numberOfSection: controller.contactList.length,
                            numberOfRowsInSection: (section) {
                              return controller.contactList[section].result.length;
                            },
                            headerWidget: (section) {
                              return Container(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    controller.contactList[section].id,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 19.2,
                                    ),
                                  ),
                                ),
                              );
                            },
                            bodyWidget: (section, indexRow) {
                              var _contact = controller.contactList[section].result[indexRow];
                              return ListTile(
                                onTap: () => _onViewContact(_contact, context),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 7,
                                  horizontal: 16,
                                ),
                                leading: WidgetBindingProfileRadius(
                                  borderRadius: 8,
                                  isActive: false,
                                  avatarUrl: _contact.avatar ??
                                      'https://st3.depositphotos.com/6672868/13701/v/600/depositphotos_137014128-stock-illustration-user-profile-icon.jpg',
                                ),
                                dense: true,
                                title: Text(
                                  _contact.fullName,
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    );
                  })),
        ],
      ),
    );
  }

  void _onViewContact(Contact selectContact, BuildContext context) async {
    var profile = Get.find<AccountUserProfileController>().profile;

    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0.0,
            backgroundColor: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              width: 100,
              // height: 100,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    'send_to'.tr,
                    style: AppTextStyle.h4BoldBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    WidgetBindingProfileRadius(
                      avatarUrl: profile?.avatar ?? '',
                    ),
                    const SizedBox(width: 16),
                    Text(profile?.fullName ?? ''),
                  ],
                ),
                const SizedBox(height: 12),
                generateContentToSent(widget.contentType, selectContact),
                // FairbindingTextInput(
                //   textController,
                //   hintText: 'leave_a_message'.tr,
                //   textEditingKey: '',
                //   typeOfKeyboard: TextInputType.text,
                // ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text('cancel'.tr),
                    ),
                    TextButton(
                      onPressed: () => sendContactCard(selectContact),
                      child: Text('send'.tr),
                    ),
                  ],
                ),
              ]),
            ),
          );
        });
  }

  void sendContactCard(Contact selectedContact) {
    //todo send my profile QR
    var roomId = Get.find<ChatRoomMessageController>().roomId;
    // var chatController = Get.find<ChatRoomMessageController>()
    //     .onSentContact(selectedContact.contactId, roomId);
  }

  Widget generateContentToSent(String? contentType, Contact selectContact) {
    switch (contentType) {
      case 'qrCode':
        return widget.imagePath == null
            ? Text('qr_image_not_available'.tr)
            : Align(
                alignment: Alignment.center,
                child: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Image.file(
                      File(widget.imagePath!),
                      height: 150,
                      errorBuilder: ((context, error, stackTrace) => Text('err')),
                    )),
              );
      case 'contact':
        return Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Row(
            children: [
              Text('contact_card'.tr),
              Text(' : ' + selectContact.fullName),
            ],
          ),
        );

      default:
        return Offstage();
    }
  }
}
