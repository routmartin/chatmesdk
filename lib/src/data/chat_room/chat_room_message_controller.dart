import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../util/constant/app_constant.dart';
import '../../util/helper/crash_report.dart';
import '../../util/helper/message_helper.dart';
import '../../util/helper/util.dart';
import '../../view/widget/widget_share.dart';
import '../api_helper/base/base.dart';
import '../model/listen_room_model.dart';
import '../model/message_response_model.dart';
import 'chat_room_controller.dart';

class ChatRoomMessageController extends GetxController with WidgetsBindingObserver {
  // animatino
  late Socket _messageSokcet;
  late Socket _roomSocket;
  List<MessageModel> listMessage = [];
  List<MessageModel> listPinMessage = [];
  String roomId = '';
  String avatar = '';
  String name = '';
  String testName = 'N/A';
  String lastOnlineAt = '';
  String accountId = '';
  String profileId = '';
  int unReadMessageCount = 0;
  bool isOfficial = false;
  bool isLoading = true;

  bool isMultiSelection = false;
  bool isPartycipateTyping = false;
  bool isPartycipateSending = false;
  bool isPartycipateReceiveReconding = false;
  bool isEverEmitTypingEvent = false;
  bool isOnReplying = false;
  bool isOnline = false;
  bool isMute = false;
  bool isHaveDraft = false;
  bool isSelectMedia = false;
  bool isShowOffline = false;
  MessageModel? replyMessage;
  List<AssetEntity>? selectFiles = [];
  DateTime? draftCreatedAt;
  bool isCancelUpload = false;
  bool isAllowIncomingCall = true;

  // pagination
  bool isEnableScrollMore = true;
  bool isBeforeMessageLoadMore = false;
  int beforeMessageTotalPage = 0;
  int beforeMessageCurrentPage = 1;
  bool isAfterMessageLoadMore = false;
  int afterMessageTotalPage = 0;
  int afterMessageCurrentPage = 1;
  String rootMessageDate = '';
  int listPinMessageTotal = 0;
  bool isPinMessageLoadMore = false;
  int pinMessageCurrentPage = 1;
  bool pinMessageLoading = false;
  bool isDisableGetBeforeMessage = false;
  bool isDisableGetAfterMessage = false;

  bool isShowScrollToBottom = false;
  int inRoomUnreadCountNumber = 0;
  double currentScrollPosition = 0.0;
  String? selectedAudioMessageKey;

  TextEditingController msgTextController = TextEditingController();
  TextEditingController mediaTextController = TextEditingController();
  var chatRoomController = Get.find<ChatRoomController>();

  bool isUploading = false;
  bool isMessageSenting = false;
  String messageIdForAnimationPin = '';
  String messageIdForAnimationMessage = '';
  int indexMessageForScroll = -1;
  MessageModel selectedPinItem = MessageModel();
  int selectedPinIndex = -1;
  ScrollController scrollListController = ScrollController();
  late ListObserverController observerController = ListObserverController(controller: scrollListController)
    ..cacheJumpIndexOffset = false;

  //* chat textfield state
  bool showFooter = false;
  bool isShowActionIcons = false;
  bool shouldHaveButtonPadding = true;
  String callId = '';
  // bool isJoinCall = false;
  String roomType = '';

  @override
  void onInit() async {
    super.onInit();
    _messageSokcet = await BaseSocket.initConnectWithHeader(SocketPath.message);
    _roomSocket = await BaseSocket.initConnectWithHeader(SocketPath.room);
    WidgetsBinding.instance.addObserver(this);
    _mapChatArgument(Get.arguments);
    await _getChatRoomDetail();
    await _checkGetMessage();
    _initAllEventListener();
    observerController.controller?.addListener(_scrollListener);
  }

  void _initAllEventListener() async {
    _listenReceiveMessage();
    _listenTypingEvent();
    _listenSeenMessage();
    _listenOnlineStatus();
    _listenOnReconding();
  }

  Future<void> _checkGetMessage() async {
    if (rootMessageDate != '') {
      String? messageId = await getMessagesBetweenDate();
      if (messageId != null) {
        await Future.delayed(const Duration(milliseconds: 100));
        await MessageHelper.onScrollToMessageIndex(this, messageId, isJumpTo: true, isAnimatedPin: false);
      }
    } else {
      _getMessage();
    }
  }

  void onSentMessage(String message) {
    if (Util.onCheckIfUrl(message)) {
      onSentLinkMessage(message);
    } else {
      _onSentTextMessage(message);
    }
  }

  Future<void> _onSentTextMessage(String message) async {
    var splitMessage = [];
    Map<String, Map<String, String?>> request;
    var messageLength = message.length;
    //* validate message
    if (messageLength > 1000) {
      splitMessage = MessageHelper.messageSplitStringByLength(message, 1000);
      for (String message in splitMessage) {
        if (isOnReplying) {
          request = {
            'body': {
              'message': message.trim(),
              'room': roomId,
              'type': 'text',
              'refType': 'reply',
              'ref': replyMessage!.id
            }
          };
        } else {
          request = {
            'body': {'message': message.trim(), 'room': roomId, 'type': 'text'}
          };
        }
        await _submitMessageToSever(request);
      }
    } else {
      if (isOnReplying) {
        request = {
          'body': {
            'message': message.trim(),
            'room': roomId,
            'type': 'text',
            'refType': 'reply',
            'ref': replyMessage!.id
          }
        };
      } else {
        request = {
          'body': {'message': message.trim(), 'room': roomId, 'type': 'text'}
        };
      }
      await _submitMessageToSever(request);
    }
  }

  Future<bool> onSentFileMessage(List attachments, {String? message}) async {
    Map<String, Map<String, Object?>> request;
    if (message != null) {
      if (isOnReplying) {
        request = {
          'body': {
            'message': message,
            'room': roomId,
            'type': 'file',
            'attachments': attachments,
            'refType': 'reply',
            'ref': replyMessage!.id,
          }
        };
      } else {
        request = {
          'body': {'message': message, 'room': roomId, 'type': 'file', 'attachments': attachments}
        };
      }
    } else {
      if (isOnReplying) {
        request = {
          'body': {
            'room': roomId,
            'type': 'file',
            'attachments': attachments,
            'refType': 'reply',
            'ref': replyMessage!.id,
          }
        };
      }
      request = {
        'body': {
          'room': roomId,
          'type': 'file',
          'attachments': attachments,
        }
      };
    }

    bool uploadSuccess = await _submitMessageToSever(request);
    if (uploadSuccess) {
      return true;
    } else {
      update();
      return false;
    }
  }

  void cancelUploadFile() {
    isCancelUpload = true;
    update();
  }

  void onSentLinkMessage(urlLink) async {
    Map<String, Map<String, dynamic>> request;
    if (isOnReplying) {
      request = {
        'body': {
          'message': urlLink.trim(),
          'room': roomId,
          'type': 'link',
          'refType': 'reply',
          'ref': replyMessage!.id,
        }
      };
    } else {
      request = {
        'body': {'message': urlLink.trim(), 'room': roomId, 'type': 'link'}
      };
    }

    await _submitMessageToSever(request);
  }

  void onSentVoiceMessage(String attachments) async {
    Map<String, Map<String, Object?>> request;
    if (replyMessage?.id != null) {
      request = {
        'body': {
          'room': roomId,
          'type': 'voice',
          'attachments': [attachments],
          'refType': 'reply',
          'ref': replyMessage!.id,
        },
      };
      replyMessage = null;
      update();
    } else {
      request = {
        'body': {
          'room': roomId,
          'type': 'voice',
          'attachments': [attachments]
        },
      };
    }
    await _submitMessageToSever(request);
  }

  void onSentSticker(stickerId) {
    Map<String, Map<String, dynamic>> request;
    if (isOnReplying) {
      request = {
        'body': {
          'sticker': stickerId,
          'room': roomId,
          'type': 'sticker',
          'refType': 'reply',
          'ref': replyMessage!.id,
        }
      };
    } else {
      request = {
        'body': {
          'sticker': stickerId,
          'room': roomId,
          'type': 'sticker',
        }
      };
    }
    _submitMessageToSever(request);
  }

  void onSelectReplyMessage(MessageModel message) async {
    replyMessage = message;
    isOnReplying = true;
    update(['replying']);
  }

  void onCloseReply() {
    replyMessage = null;
    isOnReplying = false;
    update(['replying']);
  }

  void onUnsendMessage(messageId, VoidCallback dialog) {
    var request = {
      'body': {'messageId': messageId, 'roomId': roomId}
    };

    try {
      _messageSokcet.emitWithAck(
        SocketPath.unsendMessage,
        request,
        ack: (result) async {
          if (result['data'] != null) {
            for (var message in listMessage) {
              if (message.id == messageId) {
                message.status = 'unsent';
              }
            }
            update();
            // message already seen can not unsent
          } else if (result['errorCode'] == 40026) {
            dialog.call();
          }
        },
      );
    } catch (e) {
      final message = e.toString();
      CrashReport.send(ReportModel(message: message));
      log(e.toString());
    }
  }

  Future<bool> onDeleteMessage(messages) async {
    final completer = Completer<bool>();
    var request = {
      'body': {'messageIds': messages, 'roomId': roomId}
    };
    try {
      _messageSokcet.emitWithAck(
        SocketPath.deleteOwnMessage,
        request,
        ack: (result) async {
          Map response = result;
          if (response['data'] != null) {
            listMessage.removeWhere((message) => messages.contains(message.id));
            update();
            completer.complete(true);
          } else {
            completer.complete(false);
          }
        },
      );
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      log(e.toString());
      completer.complete(false);
    }
    return completer.future;
  }

  void onMulitDelete() {
    var deleteArray = [];
    var filterSelectList = listMessage.where((message) => message.isSelect == true);
    filterSelectList.forEach((deleteMessage) {
      deleteArray.add(deleteMessage.id);
    });

    onDeleteMessage(deleteArray);
    isMultiSelection = false;
    update(['appbar']);
  }

  void onMulitSelect() {
    isMultiSelection = !isMultiSelection;
    update();
    update(['appbar']);
  }

  void onTypingEvent() async {
    if (isEverEmitTypingEvent) {
      MessageHelper.debounceAction(_emitTypingEvent);
    } else {
      _emitTypingEvent();
      isEverEmitTypingEvent = true;
    }
  }

  Future<bool> saveDraftMessage() async {
    final completer = Completer<bool>();
    Map<String, Map<String, String?>> request;
    var tmpRoomId = roomId; // use tmp for store data after controller destroyed

    try {
      if (msgTextController.text.trim().isNotEmpty) {
        if (isOnReplying) {
          request = {
            'body': {
              'message': msgTextController.text..trim(),
              'roomId': roomId,
              'refType': 'reply',
              'ref': replyMessage!.id,
            }
          };
        } else {
          request = {
            'body': {'message': msgTextController.text.trim(), 'roomId': roomId}
          };
        }
        _roomSocket.emitWithAck(
          SocketPath.saveDraft,
          request,
          ack: (result) async {
            var chatRoomController = Get.find<ChatRoomController>();
            Draft? draft = result?['data']?['draft'] == null ? null : Draft.fromJson(result?['data']?['draft']);
            int indexList = chatRoomController.chatRoomList.indexWhere((element) => element.id == tmpRoomId);
            int indexGroupList = chatRoomController.groupRoomList.indexWhere((element) => element.id == tmpRoomId);
            if (indexList != -1) {
              chatRoomController.chatRoomList[indexList].draft = draft;
            }
            if (indexGroupList != -1) {
              chatRoomController.groupRoomList[indexList].draft = draft;
            }
            chatRoomController.update(['totalCount', 'list', 'groupList']);
            return completer.complete(true);
          },
        );
      } else {
        if (isHaveDraft) {
          await deleteDraftMessage();
        }
        completer.complete(false);
      }
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      log(e.toString());
      completer.complete(false);
    }
    return completer.future;
  }

  Future deleteDraftMessage() async {
    var tmpRoomId = roomId;
    try {
      var request = {
        'body': {'roomId': roomId}
      };
      _roomSocket.emitWithAck(
        SocketPath.deleteDraft,
        request,
        ack: (result) async {
          log(result.toString());

          int indexList = chatRoomController.chatRoomList.indexWhere((element) => element.id == tmpRoomId);
          int indexGroupList = chatRoomController.groupRoomList.indexWhere((element) => element.id == tmpRoomId);
          if (indexList != -1) {
            chatRoomController.chatRoomList[indexList].draft = null;
          }
          if (indexGroupList != -1) {
            chatRoomController.groupRoomList[indexGroupList].draft = null;
          }
          chatRoomController.update(['totalCount', 'list', 'groupList']);
        },
      );
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      log(e.toString());
    }
  }

  void _emitSeenMessage() async {
    try {
      var request = {
        'body': {'roomId': roomId}
      };
      _messageSokcet.emitWithAck(
        SocketPath.seenMessage,
        request,
        ack: (result) async {},
      );
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
    }
  }

  void _emitTypingEvent() {
    var request = {
      'body': {'roomId': roomId}
    };
    _messageSokcet.emitWithAck(SocketPath.onTyping, request, ack: (result) {});
  }

  void emitRecondingOnEvent() {
    var request = {
      'body': {'roomId': roomId, 'isRecording': true}
    };
    _messageSokcet.emitWithAck(SocketPath.onRecording, request, ack: (result) {});
  }

  void emitRecondingOffEvent() {
    var request = {
      'body': {'roomId': roomId, 'isRecording': false}
    };
    _messageSokcet.emitWithAck(SocketPath.onRecording, request, ack: (result) {
      log(result.toString(), name: 'emitoff');
    });
  }

  void _getMessage() async {
    try {
      var request = {
        'query': {'page': beforeMessageCurrentPage, 'limit': AppConstants.defaultLimit},
        'body': {'roomId': roomId}
      };
      _messageSokcet.emitWithAck(
        SocketPath.getMessages,
        request,
        ack: (result) async {
          try {
            isLoading = false;
            var res = BaseApiResponse.generateResponse(
                response: result, parseData: (data) => ChatMessageResponeModel.fromMap(result));
            if (res.success) {
              var rawData = res.result?.data ?? [];
              List<MessageModel> uploadList = [];
              listMessage = MessageHelper.onGetMessageListWithTimeStamp(rawData + uploadList);
              beforeMessageTotalPage = res.result!.pagination!.totalPages;
              isDisableGetBeforeMessage = rawData.isEmpty;
            } else {
              isDisableGetBeforeMessage = true;
            }
            isDisableGetAfterMessage = true;
            update();
          } catch (e) {
            final message = e.toString();
            await CrashReport.send(ReportModel(message: message));
            rethrow;
          }
          _emitSeenMessage();
          scrollToBottom();
        },
      );
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      rethrow;
    }
  }

  Future<String?> getMessagesBetweenDate() async {
    try {
      isDisableGetBeforeMessage = false;
      isDisableGetAfterMessage = false;
      isEnableScrollMore = false;
      isBeforeMessageLoadMore = false;
      beforeMessageTotalPage = 0;
      beforeMessageCurrentPage = 1;
      isAfterMessageLoadMore = false;
      afterMessageTotalPage = 0;
      afterMessageCurrentPage = 1;
      update();
      var data = await Future.wait([_getMessagesBeforeDate(), _getMessagesAfterDate()]);
      var newlist = [...data[0], ...data[1]];
      var messageId = data[1][0].id ?? '';
      listMessage = MessageHelper.onGetMessageListWithTimeStamp(newlist);

      isLoading = false;
      // set index for scroll
      indexMessageForScroll = List.from(newlist.reversed).indexWhere((element) => element.id == messageId);
      update();
      return messageId;
    } catch (e) {
      final message = e.toString();
      // BaseDialogLoading.dismiss();
      await CrashReport.send(ReportModel(message: message));
      return null;
    }
  }

  Future<List<MessageModel>> _getMessagesBeforeDate() async {
    final completer = Completer<List<MessageModel>>();
    try {
      var request = {
        'query': {'page': 1, 'limit': AppConstants.defaultLimit, 'beforeDate': rootMessageDate},
        'body': {'roomId': roomId}
      };
      List<MessageModel> beforePin = [];
      _messageSokcet.emitWithAck(
        SocketPath.getMessages,
        request,
        ack: (result) async {
          var res = BaseApiResponse.generateResponse(
              response: result, parseData: (data) => ChatMessageResponeModel.fromMap(result));
          if (res.success && res.result!.data!.isNotEmpty) {
            beforePin = res.result!.data!;
            // remove duplicate message
            beforePin.removeLast();
            beforeMessageTotalPage = res.result!.pagination!.totalPages;
            completer.complete(beforePin);
          } else {
            completer.complete([]);
            isDisableGetBeforeMessage = true;
          }
        },
      );
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      completer.complete([]);
    }
    return completer.future;
  }

  void getMoreMessagesBeforeDate() async {
    try {
      if (beforeMessageCurrentPage > beforeMessageTotalPage || beforeMessageTotalPage == 1) {
        isBeforeMessageLoadMore = false;
        isDisableGetBeforeMessage = true;
        update();
        return;
      }
      beforeMessageCurrentPage++;
      isBeforeMessageLoadMore = true;
      update();
      Map<String, Map<String, dynamic>> request;
      if (rootMessageDate != '') {
        request = {
          'query': {
            'page': beforeMessageCurrentPage,
            'limit': AppConstants.defaultLimit,
            'beforeDate': rootMessageDate,
          },
          'body': {'roomId': roomId}
        };
      } else {
        request = {
          'query': {
            'page': beforeMessageCurrentPage,
            'limit': AppConstants.defaultLimit,
          },
          'body': {'roomId': roomId}
        };
      }
      _messageSokcet.emitWithAck(
        SocketPath.getMessages,
        request,
        ack: (result) async {
          var res = BaseApiResponse.generateResponse(
              response: result, parseData: (data) => ChatMessageResponeModel.fromMap(result));
          if (res.success && res.result!.data!.isNotEmpty) {
            var addedBeforeData = res.result!.data!;
            listMessage = MessageHelper.onGetMessageListWithTimeStamp([...addedBeforeData, ...listMessage]);
          }
          isBeforeMessageLoadMore = false;
          update();
        },
      );
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
    }
  }

  Future<List<MessageModel>> _getMessagesAfterDate() async {
    final completer = Completer<List<MessageModel>>();
    try {
      var request = {
        'query': {'page': 1, 'limit': AppConstants.defaultLimit, 'afterDate': rootMessageDate},
        'body': {'roomId': roomId}
      };
      List<MessageModel> afterPin = [];
      _messageSokcet.emitWithAck(
        SocketPath.getMessages,
        request,
        ack: (result) async {
          var res = BaseApiResponse.generateResponse(
              response: result, parseData: (data) => ChatMessageResponeModel.fromMap(result));
          if (res.success && res.result!.data!.isNotEmpty) {
            afterPin = res.result!.data!;
            afterMessageTotalPage = res.result!.pagination!.totalPages;
            completer.complete(afterPin);
          } else {
            completer.complete([]);
            isDisableGetAfterMessage = true;
          }
        },
      );
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      completer.complete([]);
    }
    return completer.future;
  }

  void getMoreMessagesAfterDate() async {
    try {
      if (afterMessageCurrentPage > afterMessageTotalPage || afterMessageTotalPage == 1) {
        isAfterMessageLoadMore = false;
        isDisableGetAfterMessage = true;
        update();
        return;
      }
      afterMessageCurrentPage++;
      isAfterMessageLoadMore = true;
      update();
      var request = {
        'query': {'page': afterMessageCurrentPage, 'limit': AppConstants.defaultLimit, 'afterDate': rootMessageDate},
        'body': {'roomId': roomId}
      };
      _messageSokcet.emitWithAck(
        SocketPath.getMessages,
        request,
        ack: (result) async {
          var res = BaseApiResponse.generateResponse(
              response: result, parseData: (data) => ChatMessageResponeModel.fromMap(result));
          if (res.success && res.result!.data!.isNotEmpty) {
            var addedAfterData = res.result!.data!;
            listMessage = MessageHelper.onGetMessageListWithTimeStamp([...listMessage, ...addedAfterData]);
            observerController.jumpTo(index: addedAfterData.length + 1);
          }
          isAfterMessageLoadMore = false;
          update();
        },
      );
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
    }
  }

  Future<void> _getChatRoomDetail() async {
    try {
      var request = {
        'query': {'_id': roomId}
      };
      _roomSocket.emitWithAck(
        SocketPath.getChatRooms,
        request,
        ack: (result) async {
          // user block one other can not fetch room detail
          if (result['data'] == null) {
            return;
          }
          Map data = result['data'][0] as Map;
          if ((data['recording'] as List?)?.isNotEmpty ?? false) {
            isPartycipateReceiveReconding = true;
          }
          if ((data['uploading'] as List?)?.isNotEmpty ?? false) {
            isPartycipateSending = true;
          }
          isAllowIncomingCall = data['isAllowIncomingCall'];
          isMute = data['isMuted'];
          isOnline = data['isOnline'];
          lastOnlineAt = data['lastOnlineAt'] ?? DateTime.now().toString();
          profileId = data['profileId'] ?? '';
          name = data['name'];
          isOfficial = data['isOfficial'];
          avatar = data['avatar'] ?? '';
          isShowOffline = data['isShowOffline'] ?? '';
          unReadMessageCount = data['unreadCount'] ?? '';
          roomType = data['type'] ?? 'p';

          //* pass data for store in callkit

          if (data['draft'] != null) {
            var draft = data['draft'] as Map;
            if (draft.isNotEmpty) {
              msgTextController.text = data['draft']['message'];
              isHaveDraft = true;
            }
          }
          update(['appbar']);
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  void onClearChat() {
    try {
      var request = {
        'body': {'roomId': roomId}
      };
      _messageSokcet.emitWithAck(SocketPath.deleteChat, request, ack: (result) async {
        listMessage.clear();
        update();
      });
    } catch (e) {
      final message = e.toString();
      CrashReport.send(ReportModel(message: message));
      log(e.toString());
    }
  }

  Future<bool> _submitMessageToSever(messageBodyRequest) async {
    final completer = Completer<bool>();
    if (isMessageSenting) return false;
    try {
      isMessageSenting = true;
      _messageSokcet.emitWithAck(
        SocketPath.sendMessage,
        messageBodyRequest,
        ack: (res) async {
          var result = res as Map;
          if (result.containsKey('data')) {
            MessageHelper.playMessageSentSound();
            isOnReplying = false;
            mediaTextController.clear();
            msgTextController.clear();
            isMessageSenting = false;
            scrollToBottom();
            completer.complete(true);
          }
        },
      );
    } catch (_) {
      rethrow;
    }
    return completer.future;
  }

  void _mapChatArgument(arguments) async {
    if (arguments == null) return;
    try {
      for (int i = 0; i < arguments.length; i++) {
        if (i == 0) roomId = arguments[0] ?? '';
        if (i == 1) rootMessageDate = arguments[1] ?? '';
      }
    } catch (e) {
      rethrow;
    }
  }

  void _listenReceiveMessage() async {
    _messageSokcet.on(SocketPath.receiveMessage, (data) {
      var responseMap = data as Map;
      var receiveRoomId = data['data']['room']['_id'];
      if (receiveRoomId == roomId) {
        var messageMap = responseMap['data']['message'];
        var message0 = MessageModel.fromJson(messageMap);
        // if in middle of message go to latest message
        if (afterMessageCurrentPage <= afterMessageTotalPage) {
          resetListAndGetLatestMessage();
        } else {
          // backend field seen by default->set to false
          if (message0.status == 'sent') {
            message0.isSeen = false;
          }
          if (!listMessage
              .sublist(listMessage.length - math.min(5, listMessage.length))
              .any((message) => message.id == message0.id)) {
            listMessage.add(message0);
          }
        }

        // if not the sender seen the message
        if (accountId != message0.sender?.id) {
          if (isShowScrollToBottom) {
            inRoomUnreadCountNumber++;
            unReadMessageCount = inRoomUnreadCountNumber;
          }
          _emitSeenMessage();
        } else {
          unReadMessageCount = 0;
        }
        update();
      }
    });
  }

  void _listenTypingEvent() async {
    _messageSokcet.on(SocketPath.onTyping, (data) {
      if (data['data']['room']['_id'] == roomId) {
        var typingList = (data['data']['typing'] as List);
        if (typingList.isNotEmpty) {
          isPartycipateTyping = true;
        } else {
          isPartycipateTyping = false;
        }
      }
      update(['appbar']);
    });
  }

  void _listenSeenMessage() async {
    _messageSokcet.on(SocketPath.seenMessage, (data) {
      if (data['data']['room'] == roomId) {
        listMessage.last.isSeen = true;
      }
      update();
    });
  }

  void _listenOnlineStatus() async {
    try {
      _messageSokcet.on(SocketPath.userOnline, (data) {
        if (data['data']['room'] == roomId) {
          if (accountId != data['data']['user']) {
            isOnline = data['data']['isOnline'];
            lastOnlineAt = data['data']['lastOnlineAt'];
            update(['appbar']);
          }
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  void _listenOnReconding() async {
    try {
      _messageSokcet.on(SocketPath.onRecording, (data) {
        if (data['data']['room']['_id'] == roomId) {
          var reconders = data['data']['recording'] as List;
          if (reconders.isNotEmpty) {
            isPartycipateReceiveReconding = true;
          } else {
            isPartycipateReceiveReconding = false;
          }
        }
        update(['appbar']);
      });
    } catch (e) {
      rethrow;
    }
  }

  void _scrollListener() {
    currentScrollPosition = observerController.controller?.offset ?? 0;
  }

  void scrollToBottom() {
    try {
      if (afterMessageCurrentPage < afterMessageTotalPage) {
        resetListAndGetLatestMessage();
      } else {
        observerController.animateTo(
          index: 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
        inRoomUnreadCountNumber = 0;
      }
    } catch (_) {}
  }

  void scrollToTop() {
    try {
      observerController.animateTo(
        index: listMessage.length - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    } catch (_) {}
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);

    emitRecondingOffEvent();
    roomId = '';
  }

  void onResetControllerState() {
    isLoading = true;
    // pagination
    isBeforeMessageLoadMore = false;
    beforeMessageTotalPage = 0;
    beforeMessageCurrentPage = 1;
    isAfterMessageLoadMore = false;
    afterMessageTotalPage = 0;
    afterMessageCurrentPage = 1;
    rootMessageDate = '';
    isDisableGetBeforeMessage = false;
    isDisableGetAfterMessage = false;

    unReadMessageCount = 0;

    roomId = '';
    avatar = '';
    name = '';
    lastOnlineAt = '';
    accountId = '';

    isMultiSelection = false;
    isPartycipateTyping = false;
    isPartycipateSending = false;
    isEverEmitTypingEvent = false;
    isOnReplying = false;
    isOnline = false;
    isMute = false;
    isHaveDraft = false;
    isEnableScrollMore = true;
    isSelectMedia = false;
    isAllowIncomingCall = true;

    // typing store
    replyMessage = null;
    selectFiles = [];
    draftCreatedAt = null;

    msgTextController = TextEditingController();
    mediaTextController = TextEditingController();

    isUploading = false;
    messageIdForAnimationPin = '';
    messageIdForAnimationMessage = '';
    indexMessageForScroll = -1;

    listMessage = [];
    listPinMessage = [];
  }

  void resetListAndGetLatestMessage() {
    isBeforeMessageLoadMore = false;
    beforeMessageTotalPage = 0;
    beforeMessageCurrentPage = 1;
    isAfterMessageLoadMore = false;
    afterMessageTotalPage = 0;
    afterMessageCurrentPage = 1;
    rootMessageDate = '';
    isDisableGetBeforeMessage = false;
    isDisableGetAfterMessage = false;
    _getMessage();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _initAllEventListener();
        resetListAndGetLatestMessage();
        break;
      case AppLifecycleState.paused:
        saveDraftMessage();
        break;
      case AppLifecycleState.detached:
        emitRecondingOffEvent();
        break;
      default:
        break;
    }
  }
}
