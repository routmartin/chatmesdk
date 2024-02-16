import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../../data/chat_room/chat_room.dart';
import '../../data/chat_room/model/attachment_model.dart';
import '../../data/chat_room/model/chat_model/chat_room_model.dart';
import '../../data/chat_room/model/message_response_model.dart';
import '../../data/upload_controller.dart';

class MessageUploadHelper {
  MessageModel messageUploadModel(
    List<File> pickedFiles,
    String id,
    bool isSentAsFile,
    String caption,
    bool isGroup,
    String roomId,
    MessageModel? replyMessage,
  ) {
    List<AttachmentModel> attachments = [];
    for (int i = 0; i < pickedFiles.length; i++) {
      attachments.add(AttachmentModel(
          url: '',
          uploadPath: pickedFiles[i].path,
          originalName: getFileName(pickedFiles[i]),
          mimeType: getFileExtension(pickedFiles[i]),
          id: '$id$i',
          uploadPercentage: -1,
          fileSize: pickedFiles[i].lengthSync().toString()));
    }
    var senderId = Get.find<ChatRoomMessageController>().accountId;
    return MessageModel(
      roomId: roomId,
      isUploading: true,
      id: id,
      type: isSentAsFile ? 'file' : 'media',
      status: 'temporary',
      refType: replyMessage != null ? 'reply' : null,
      deleters: [],
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPinned: false,
      message: caption,
      args: {},
      attachments: attachments,
      sender: Sender(
        id: senderId,
        accountId: '',
        name: '',
        profileId: '',
      ),
      isSeen: false,
      ref: replyMessage,
    );
  }

  var senderId = Get.find<ChatRoomMessageController>().accountId;
  MessageModel messageVoiceUploadModel(
    String id,
    String pathVoiceFile,
    bool isGroup,
    String roomId,
    MessageModel? replyMessage,
  ) {
    return MessageModel(
      roomId: roomId,
      isUploading: true,
      id: id,
      type: 'voice',
      status: 'temporary',
      refType: replyMessage != null ? 'reply' : null,
      deleters: [],
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPinned: false,
      message: null,
      args: {},
      attachments: [
        AttachmentModel(
          url: '',
          uploadPath: pathVoiceFile,
          originalName: 'uploading_voice',
          mimeType: 'audio/m4a',
          id: '$id' '_voiceId',
          uploadPercentage: -1,
          fileSize: null,
        )
      ],
      sender: Sender(
        id: senderId,
        accountId: '',
        name: '',
        profileId: '',
      ),
      isSeen: false,
      ref: replyMessage,
    );
  }

  String getFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'Mb', 'Gb', 'Tb'];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(1)) + suffixes[i];
  }

  String getFileName(File file) {
    return file.path.split('/').last;
  }

  String getFileExtension(File file) {
    return file.path.split('.').last;
  }

  void cancelUpload(bool isUploading, AttachmentModel model, bool isGroup) {
    dynamic controller = Get.find<ChatRoomMessageController>();
    Get.lazyPut(() => UploadMessageController(), tag: controller.roomId);
    var uploadController = Get.find<UploadMessageController>(tag: controller.roomId);
    var uploadMessageItem =
        controller.listMessage.firstWhere((element) => element.id == uploadController.tempUploadMessageId);
    var attachmentFromMessageList = uploadMessageItem.attachments!;
    if (attachmentFromMessageList.length == 1) {
      // remove sending file event
      emitUploadEventToRoomList(false, isGroup, controller.roomId); // local event
      uploadController.emitUploadingEvent(false);

      controller.listMessage.removeWhere((element) => element.id == uploadController.tempUploadMessageId);
      controller.update();
      uploadController.onMoveToNextUploadMessage(isGroup);
    } else {
      attachmentFromMessageList.removeWhere((element) => element.id == model.id);
      controller.update();
    }
    if (isUploading && uploadController.uploadMessageList.isEmpty) {
      var imageController = uploadController.imageController;
      imageController.cancelToken.cancel();
      imageController.cancelToken = dio.CancelToken();
      imageController.update();
    }
  }

  double checkFileSize(File file) {
    int sizeInBytes = file.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    return sizeInMb;
  }

  Future<Map<String, dynamic>> onGetFilesAndCheckLarge(List<AssetEntity> list) async {
    bool isLarge = false;
    List<File> files = [];
    List<String> ids = [];
    for (var element in list) {
      File? file = await element.file;
      files.add(file!);
      ids.add(element.id);

      var sizeMb = checkFileSize(file);
      if (sizeMb > 300) {
        isLarge = true;
      }
    }
    var items = {'isLarge': isLarge, 'files': files, 'ids': ids};
    return items;
  }

  // for sending in local
  void emitUploadEventToRoomList(bool isUploading, bool isGroup, String controllerTag) {
    var chatRoomController = Get.find<ChatRoomController>();
    Get.lazyPut(() => UploadMessageController(), tag: controllerTag);
    var tempRoomId = Get.find<UploadMessageController>(tag: controllerTag).tempRoomId;
    var target = chatRoomController.chatRoomList.firstWhere((item) => item.id == tempRoomId);
    target.isUploading = isUploading;
    if (isGroup && chatRoomController.groupRoomList.isNotEmpty) {
      ChatRoomModel? target = chatRoomController.groupRoomList.firstWhereOrNull((item) => item.id == tempRoomId);
      if (target != null) {
        target.isUploading = isUploading;
      }
    }
    chatRoomController.update([tempRoomId, 'list', 'groupList']);
  }
}
