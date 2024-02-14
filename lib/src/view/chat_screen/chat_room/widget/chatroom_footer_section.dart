import 'dart:io';

import 'package:chatme/data/chat_room/chat_room_message_controller.dart';
import 'package:chatme/data/group_room/group_message_controller.dart';
import 'package:chatme/data/image_controller/image_controller.dart';
import 'package:chatme/data/upload_message/upload_message_controller.dart';
import 'package:chatme/util/constant/app_asset.dart';
import 'package:chatme/util/helper/message_upload_helper.dart';
import 'package:chatme/util/text_style.dart';
import 'package:chatme/widgets/cupertino/cupertino_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatroomFooterSection extends StatefulWidget {
  const ChatroomFooterSection({
    Key? key,
    required this.isGroup,
  }) : super(key: key);
  final bool isGroup;

  @override
  State<ChatroomFooterSection> createState() => _ChatroomFooterSectionState();
}

class _ChatroomFooterSectionState extends State<ChatroomFooterSection> with SingleTickerProviderStateMixin {
  String receiverRoomId = '';

  int initIndex = 1;
  int selectedIndex = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onSelectFile,
      child: Container(
        padding: EdgeInsets.only(left: 40),
        width: double.maxFinite,
        color: AppColors.txtSeconddaryColor,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                Assets.app_assetsIconsIconFile,
                scale: 4,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    'file'.tr,
                    style: AppTextStyle.extraSmallTextMediumWhite,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSelectFile() async {
    List<File>? files = await Get.find<ImageController>().pickFiles();

    if (files != null) {
      var hasOverSizeFile = files.any((element) => element.lengthSync() / (1024 * 1024) > 300);

      if (hasOverSizeFile) {
        cupertinoDialog(context,
            widget: Column(
              children: [
                Image.asset(
                  Assets.app_assetsIconsWarningSign,
                  scale: 4,
                ),
              ],
            ),
            content: 'file_too_large'.tr + '\n' + 'please_select_a_file_under_300mb.'.tr,
            buttonText: 'ok'.tr);
      } else {
        showSendDialog(context);
      }
    }
  }

  void showSendDialog(
    BuildContext context,
  ) async {
    TextEditingController textEditingController = TextEditingController();
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return GetBuilder<ImageController>(builder: (_controller) {
            List<File>? filesToShare = _controller.pickedFiles;
            return AlertDialog(
              insetPadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              titlePadding: EdgeInsets.zero,
              buttonPadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              // scrollable: true,
              content: Container(
                height: filesToShare.length == 1
                    ? 176
                    : filesToShare.length <= 12
                        ? 176 + filesToShare.length.toInt() * 35
                        : 176 + 13 * 35,
                width: Get.width * .9,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 24),
                        Flexible(
                          child: Container(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ...List.generate(
                                    filesToShare.length,
                                    (index) {
                                      String _fileName = MessageUploadHelper().getFileName(filesToShare[index]);
                                      String _extension = MessageUploadHelper().getFileExtension(filesToShare[index]);
                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 2.0),
                                        height: 58,
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          key: ValueKey(index),
                                          leading: Container(
                                            alignment: Alignment.center,
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Color(0xff4882B8),
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              _extension.toUpperCase(),
                                              style: AppTextStyle.regularBoldBlue.copyWith(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          title: Text(
                                            _fileName,
                                            style: AppTextStyle.normalTextMediumBlack,
                                            maxLines: 2,
                                          ),
                                          subtitle: Builder(builder: (context) {
                                            var _fileSize =
                                                MessageUploadHelper().getFileSize(filesToShare[index].lengthSync());

                                            return Text(_fileSize.toString(), style: AppTextStyle.smallTextRegularGray);
                                          }),
                                          trailing: Visibility(
                                            visible: filesToShare.length > 1,
                                            child: InkWell(
                                              onTap: () {
                                                _controller.pickedFiles.removeAt(index);
                                                _controller.update();
                                              },
                                              child: Image.asset(
                                                Assets.app_assetsIconsIconTrash,
                                                scale: 4,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Visibility(
                          visible: filesToShare.length > 10,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    Assets.app_assetsIconsWarningSign,
                                    scale: 8,
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '10_files_maximum._please_deselect_some_files_before_proceeding.'.tr +
                                          ' (${filesToShare.length}/10)',
                                      style: TextStyle(
                                        fontSize: 13.33,
                                        color: AppColors.red,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xFFE1E2E6),
                                    width: 0.33,
                                  ),
                                  color: Color(0xFFEBEBEB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                height: 40,
                                child: TextField(
                                  controller: textEditingController,
                                  autofocus: false,
                                  maxLength: 100,
                                  decoration: InputDecoration(
                                    counter: SizedBox(),
                                    contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                                    border: InputBorder.none,
                                    hintText: 'add_a_caption...'.tr,
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              child: Image.asset(
                                Assets.app_assetsIconsChatSentIcon,
                                scale: 4,
                                color: filesToShare.length > 10 ? AppColors.dartGray : null,
                              ),
                              onTap: () {
                                if (filesToShare.length <= 10) {
                                  onSendFileMessage(filesToShare, textEditingController.text);
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: -1,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Image.asset(
                          Assets.app_assetsIconsIconCancel,
                          scale: 4.5,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  void onSendFileMessage(
    List<File> filesToShare,
    String? caption,
  ) async {
    var pickedFiles = Get.find<ImageController>().pickedFiles;
    var tagRoomId =
        widget.isGroup ? Get.find<GroupMessageController>().roomId : Get.find<ChatRoomMessageController>().roomId;
    Get.lazyPut(() => UploadMessageController(), tag: tagRoomId);
    var uploadController = Get.find<UploadMessageController>(tag: tagRoomId);
    var fileIds = List<String>.generate(pickedFiles.length, (i) => '${i + 1}');
    await uploadController.onUploadMessageToRoom(
      fileIds: fileIds,
      files: filesToShare,
      messageText: caption,
      isSentAsFile: true,
      isGroup: widget.isGroup,
    );
  }
}
