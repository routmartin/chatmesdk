import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/chat_room/chat_room.dart';
import '../../../data/upload_controller.dart';
import '../../../util/constant/app_assets.dart';
import '../../../util/helper/font_util.dart';
import '../../../util/helper/message_upload_helper.dart';
import '../../../util/theme/app_color.dart';
import '../../widget/base_share_widget.dart';
import '../../widget/binding_selection.dart';
import 'widget/chat_select_media_slide.dart';

class ChatSelectMediaScreen extends StatefulWidget {
  const ChatSelectMediaScreen({Key? key}) : super(key: key);

  @override
  State<ChatSelectMediaScreen> createState() => _ChatSelectMediaScreenState();
}

class _ChatSelectMediaScreenState extends State<ChatSelectMediaScreen> {
  bool _isSentAsFile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.seconderyColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: SizedBox(
          height: kToolbarHeight,
          child: Row(
            children: [
              InkWell(
                onTap: _onBack,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Image.asset(
                    Assets.app_assetsIconsSearchBackButton,
                    color: Colors.white,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: GetBuilder<ChatRoomMessageController>(
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: ChatSelectMediaSlide(images: controller.selectFiles!),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    WidgetBindngSelection(
                      isSelected: _isSentAsFile,
                      onChanged: _toggleSentAsFile,
                      isWidgetShow: true,
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: _toggleSentAsFile,
                      child: Text(
                        'send_as_a_file'.tr,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 16, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.send,
                          textCapitalization: TextCapitalization.sentences,
                          controller: controller.mediaTextController,
                          style: const TextStyle(color: Colors.black),
                          showCursor: true,
                          autofocus: false,
                          maxLines: null,
                          maxLength: 100,
                          toolbarOptions: const ToolbarOptions(
                            copy: true,
                            cut: true,
                            selectAll: true,
                            paste: true,
                          ),
                          enabled: true,
                          cursorColor: AppColors.primaryColor,
                          onChanged: (_) {},
                          decoration: InputDecoration(
                            counter: const SizedBox(),
                            contentPadding: const EdgeInsets.only(left: 16, top: 26),
                            hintText: 'add_a_caption'.tr,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: _onSentMediaMessage,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          height: 30,
                          width: 30,
                          child: Image.asset(
                            Assets.app_assetsIconsChatSentIcon,
                            color: const Color(0xff4882B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _onBack() {
    Get.find<ChatRoomMessageController>().mediaTextController.text = '';
    Get.back();
  }

  void _toggleSentAsFile() {
    _isSentAsFile = !_isSentAsFile;
    setState(() {});
  }

  Future _onSentMediaMessage() async {
    final ChatRoomMessageController controller = Get.find<ChatRoomMessageController>();
    try {
      BaseDialogLoading.show();
      var items = await MessageUploadHelper().onGetFilesAndCheckLarge(controller.selectFiles!);
      var isLargerThan300MB = items['isLarge'];
      List<File> files = items['files'];
      List<String> fileIds = items['ids'];
      var messageText = controller.mediaTextController.text.trim();

      if (isLargerThan300MB) {
        Get.back();
        BaseDialogLoading.dismiss();
        _fileToLargeDialog();
        return;
      } else {
        Get.lazyPut(() => UploadMessageController(), tag: controller.roomId);
        var uploadController = Get.find<UploadMessageController>(tag: controller.roomId);
        await uploadController.onUploadMessageToRoom(
          fileIds: fileIds,
          files: files,
          messageText: messageText,
          isSentAsFile: _isSentAsFile,
          isGroup: false,
        );
      }
    } catch (_) {
      BaseDialogLoading.dismiss();
      rethrow;
    }
  }

  void _fileToLargeDialog() async {
    await showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => Dialog(
        child: Material(
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      Assets.app_assetsIconsExclamationmark,
                      width: 30,
                      height: 30,
                    ),
                    Text(
                      FontUtil.tr('file_too_large'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.txtSeconddaryColor,
                      ),
                    ),
                    Text(
                      FontUtil.tr('please_select_a_file_under_300mb'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.txtSeconddaryColor,
                      ),
                    )
                  ],
                ),
              ),
              Container(height: .8, color: Colors.grey),
              InkWell(
                onTap: Get.back,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    'ok'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget popMenuItem(String icon, String text) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1, color: Colors.grey),
          ),
        ),
        child: Row(
          children: [Image.asset(icon, height: 20, width: 20), const SizedBox(width: 8), Text(text.tr)],
        ),
      );
}
