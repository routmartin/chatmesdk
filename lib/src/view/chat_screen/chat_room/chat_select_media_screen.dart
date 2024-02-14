import 'dart:async';
import 'dart:io';
import 'package:chatme/data/chat_room/chat_room_message_controller.dart';
import 'package:chatme/data/upload_message/upload_message_controller.dart';
import 'package:chatme/template/chat_screen/chat_room/widget/chat_select_media_slide.dart';
import 'package:chatme/util/constant/app_asset.dart';
import 'package:chatme/util/helper/message_upload_helper.dart';
import 'package:chatme/widgets/fair_binding_widget/widget_binding_selection.dart';
import 'package:chatme/widgets/loading/base_dialog_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                  padding: EdgeInsets.all(15),
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
                    SizedBox(width: 6),
                    InkWell(
                      onTap: _toggleSentAsFile,
                      child: Text(
                        'send_as_a_file'.tr,
                        style: TextStyle(
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
                          toolbarOptions: ToolbarOptions(
                            copy: true,
                            cut: true,
                            selectAll: true,
                            paste: true,
                          ),
                          enabled: true,
                          cursorColor: AppColors.primaryColor,
                          onChanged: (_) {},
                          decoration: InputDecoration(
                            counter: SizedBox(),
                            contentPadding: EdgeInsets.only(left: 16, top: 26),
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
                      SizedBox(width: 10),
                      InkWell(
                        onTap: _onSentMediaMessage,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 6),
                          height: 30,
                          width: 30,
                          child: Image.asset(
                            Assets.app_assetsIconsChatSentIcon,
                            color: Color(0xff4882B8),
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
                padding: EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
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
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
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
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1, color: Colors.grey),
          ),
        ),
        child: Row(
          children: [Image.asset(icon, height: 20, width: 20), const SizedBox(width: 8), Text(text.tr)],
        ),
      );
}
