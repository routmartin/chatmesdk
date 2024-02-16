import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../util/helper/message_upload_helper.dart';
import '../view/widget/base_share_widget.dart';
import 'api_helper/base/base.dart';
import 'chat_room/chat_room.dart';
import 'chat_room/model/message_response_model.dart';
import 'image_controller.dart';

class UploadMessageController extends GetxController with WidgetsBindingObserver {
  late Socket _socket;
  List<MessageModel> uploadMessageList = [];
  List<Map<dynamic, dynamic>> uploadQueueFileList = [];
  String tempUploadMessageId = ''; // assign value when this message is uploading
  String tempRoomId = ''; // assign value when this message is uploading
  var imageController = Get.find<ImageController>();

  @override
  void onInit() async {
    super.onInit();
    _socket = await BaseSocket.initConnectWithHeader(SocketPath.message);
  }

  Future<void> onUploadMessageToRoom(
      {required List<File> files,
      required List<String> fileIds,
      required bool isSentAsFile,
      required bool isGroup,
      String? messageText}) async {
    dynamic controller = Get.find<ChatRoomMessageController>();

    final tempId = 'uploading${Random().nextInt(1000000000)}';

    // add upload file to message list
    MessageModel uploadMessage;
    if (controller.isOnReplying) {
      uploadMessage = MessageUploadHelper().messageUploadModel(
        files,
        tempId,
        isSentAsFile,
        messageText ?? '',
        isGroup,
        controller.roomId,
        controller.replyMessage,
      );
    } else {
      uploadMessage = MessageUploadHelper().messageUploadModel(
        files,
        tempId,
        isSentAsFile,
        messageText ?? '',
        isGroup,
        controller.roomId,
        null,
      );
    }

    uploadMessageList.add(uploadMessage);
    update();
    // add message to list
    controller.listMessage.add(uploadMessage);
    controller.isUploading = true;
    controller.scrollToBottom();
    controller.isOnReplying = false;
    controller.update();
    BaseDialogLoading.dismiss();
    Get.back();

    // Add data to queue process here
    if (tempUploadMessageId != '') {
      var map = {};
      map['files'] = files;
      map['fileIds'] = fileIds;
      map['isSentAsFile'] = isSentAsFile;
      map['messageText'] = messageText;
      uploadQueueFileList.add(map);

      return;
    }

    // set these value for current upload message
    tempRoomId = controller.roomId;
    tempUploadMessageId = tempId;

    // emit event
    MessageUploadHelper().emitUploadEventToRoomList(true, isGroup, tempRoomId); // local event
    await emitUploadingEvent(true); // server event

    // upload file to server first
    List<String> attachmentList = [];
    for (int i = 0; i < files.length; i++) {
      final fileId = fileIds[i];
      final file = files[i];
      final fileIndex = fileIds.indexWhere((id) => id == fileId);
      String path = file.path;
      String? extension = path.split('.').last;
      String fileType = path.isImageFileName ? 'image' : 'video';
      var attachmentId = await imageController.uploadAttachment(
        path,
        MediaType(fileType, extension),
        onUploadChange: (percentage) => _updatePersonPercentage(percentage, fileIndex),
        isCompress: !isSentAsFile,
      );
      if (attachmentId != null) {
        attachmentList.add(attachmentId);
      }
    }

    // remove sending file event
    if (attachmentList.isNotEmpty) {
      MessageUploadHelper().emitUploadEventToRoomList(false, isGroup, tempRoomId); // local event
      await emitUploadingEvent(false); // server event
    }

    var type = isSentAsFile ? 'file' : 'media';
    if (Get.isRegistered<ChatRoomMessageController>()) {
      controller.isUploading = false;
      controller.update();

      if (attachmentList.contains('status_error')) {
        controller.listMessage.removeWhere((element) => element.id == tempUploadMessageId);
        controller.selectFiles = [];
        controller.update();
        tempUploadMessageId = '';
        tempRoomId = '';
        uploadMessageList.clear();
        update();
        return;
      }
    }

    await _onSentMediaMessagePerson(attachmentList, type, tempRoomId,
        message: messageText, replyId: uploadMessage.ref?.id);
  }

  void onQueueUploadMessageToRoom(
      {required List<File> files,
      required List<String> fileIds,
      required bool isSentAsFile,
      required bool isGroup,
      String? messageText}) async {
    dynamic controller = Get.find<ChatRoomMessageController>();
    var uploadMessage = uploadMessageList.first;
    controller.isUploading = true;
    controller.update();

    // emit event
    MessageUploadHelper().emitUploadEventToRoomList(true, isGroup, tempRoomId); // local event
    await emitUploadingEvent(true); // server event

    // upload file to server first
    List<String> attachmentList = [];
    for (int i = 0; i < files.length; i++) {
      final fileId = fileIds[i];
      final file = files[i];
      final fileIndex = fileIds.indexWhere((id) => id == fileId);
      String path = file.path;
      String? extension = path.split('.').last;
      String fileType = path.isImageFileName ? 'image' : 'video';
      var attachmentId = await imageController.uploadAttachment(
        path,
        MediaType(fileType, extension),
        onUploadChange: (percentage) => _updatePersonPercentage(percentage, fileIndex),
        isCompress: !isSentAsFile,
      );
      if (attachmentId != null) {
        attachmentList.add(attachmentId);
      }
    }

    // remove file from tmp directory
    // Directory dir = await getTemporaryDirectory();
    // dir.deleteSync(recursive: true);
    // await dir.create();

    // remove sending file event
    if (attachmentList.isNotEmpty) {
      MessageUploadHelper().emitUploadEventToRoomList(false, isGroup, tempRoomId); // local event
      await emitUploadingEvent(false); // server event
    }

    var type = isSentAsFile ? 'file' : 'media';
    if (Get.isRegistered<ChatRoomMessageController>()) {
      controller.isUploading = false;
      controller.update();

      if (attachmentList.contains('status_error')) {
        controller.listMessage.removeWhere((element) => element.id == tempUploadMessageId);
        controller.selectFiles = [];
        controller.update();
        tempUploadMessageId = '';
        tempRoomId = '';
        uploadMessageList.clear();
        update();
        return;
      }
    }

    // send message after upload file success
    await _onSentMediaMessagePerson(attachmentList, type, tempRoomId,
        message: messageText, replyId: uploadMessage.ref?.id);
  }

  void _updatePersonPercentage(int percentage, int index) {
    if (Get.isRegistered<ChatRoomMessageController>()) {
      var controller = Get.find<ChatRoomMessageController>();
      // if it cannot find attachment, UploadAttachment() will cancel upload and respond null in catch
      if (controller.listMessage.isNotEmpty && controller.roomId == tempRoomId) {
        var attachment = controller.listMessage
            .firstWhere((element) => element.id == tempUploadMessageId)
            .attachments!
            .firstWhere((element) => element.id == '$tempUploadMessageId$index');
        attachment.uploadPercentage = percentage;
        controller.update();
      }
    }
  }

  Future<void> _onSentMediaMessagePerson(
    List attachments,
    String type,
    String roomId, {
    String? message,
    String? replyId,
  }) async {
    Map<String, Map<String, Object>> request;

    if (message != null) {
      if (replyId != null) {
        request = {
          'body': {
            'message': message,
            'room': roomId,
            'type': type,
            'attachments': attachments,
            'refType': 'reply',
            'ref': replyId
          }
        };
      } else {
        request = {
          'body': {'message': message, 'room': roomId, 'type': type, 'attachments': attachments}
        };
      }
    } else {
      if (replyId != null) {
        request = {
          'body': {'room': roomId, 'type': type, 'attachments': attachments, 'refType': 'reply', 'ref': replyId}
        };
      } else {
        request = {
          'body': {'room': roomId, 'type': type, 'attachments': attachments}
        };
      }
    }
    try {
      _socket.emitWithAck(
        SocketPath.sendMessage,
        request,
        ack: (result) async {
          if (Get.isRegistered<ChatRoomMessageController>()) {
            var controller = Get.find<ChatRoomMessageController>();
            controller.listMessage.removeWhere((element) => element.id == tempUploadMessageId);
            controller.mediaTextController.clear();
            controller.update();
          }
          await onMoveToNextUploadMessage(false);
        },
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<void> emitUploadingEvent(bool isUploading) async {
    var requestFalse = {
      'body': {'roomId': tempRoomId, 'isUploading': false}
    };
    var request = {
      'body': {'roomId': tempRoomId, 'isUploading': isUploading}
    };
    // not best practise (?)
    _socket = await BaseSocket.initConnectWithHeader(SocketPath.message);
    // send false first to clean upload event
    _socket.emitWithAck(SocketPath.onUploading, requestFalse, ack: (response) {
      if (isUploading) {
        _socket.emitWithAck(SocketPath.onUploading, request, ack: (response) {});
      }
    });
  }

  Future<void> onMoveToNextUploadMessage(bool isGroup) async {
    // return when list is empty because of error or remove
    if (uploadMessageList.isEmpty) {
      return;
    }
    uploadMessageList.removeAt(0);
    // if there are items in queue
    if (uploadMessageList.isNotEmpty) {
      tempUploadMessageId = uploadMessageList.first.id!;
      tempRoomId = uploadMessageList.first.roomId!;
      var queueItem = uploadQueueFileList.first;
      onQueueUploadMessageToRoom(
        files: queueItem['files'],
        fileIds: queueItem['fileIds'],
        isSentAsFile: queueItem['isSentAsFile'],
        messageText: queueItem['messageText'],
        isGroup: isGroup,
      );
      uploadQueueFileList.removeAt(0);
    } else {
      // if this is the last item
      tempUploadMessageId = '';
      tempRoomId = '';
    }
    update();
  }
}
