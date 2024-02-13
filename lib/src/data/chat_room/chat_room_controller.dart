import 'dart:async';
import 'dart:developer';

import 'package:chatmesdk/src/util/helper/crash_report.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../../util/helper/scroll_to_top.dart';
import '../api_helper/base/base.dart';
import '../model/chat_model/chat_room_model.dart';
import '../model/chat_model/chat_room_response_model.dart';
import '../model/chat_model/sticker.dart';
import '../model/listen_message_response_model.dart';
import '../model/listen_room_model.dart';
import '../model/mark_as_read_response_model/mark_as_read_response_model.dart';

class ChatRoomController extends GetxController with WidgetsBindingObserver, GetSingleTickerProviderStateMixin {
  late Socket _socket;
  late Socket _receiveMessage;

  // List<ChatHistoryModel> chatHistoryList = [];
  List<ChatRoomModel> chatRoomList = [];
  List<ChatRoomModel> groupRoomList = [];
  GlobalKey<AnimatedListState> listTileKey = GlobalKey();
  GlobalKey<AnimatedListState> groupListTileKey = GlobalKey();

  final ScrollController scrollController = ScrollController();
  final FuncBaseScrollToTop funcBaseScrollToTop = FuncBaseScrollToTop();

  int totalMessageUnreadCount = 0;
  int totalUnreadBadges = 0;
  int totalUnreadCountInGroup = 0;
  int totalUnreadCountInPerson = 0;
  String accountId = '';
  String trckRoomIn = '';
  String deviceId = '';

  bool isPersonalListUpdating = false;
  bool isGroupListUpdating = false;

  bool isPersonalListLoading = false;
  bool isGroupListLoading = false;

  Timer? audioCallTimer;
  int startTime = 0;

  /// for checking when to show call status bar in the correct moment
  bool isShouldShowCallStatusBar = false;

  bool isOffVideo = false;
  bool isConnection = false;
  bool? isDismissible;

  bool isVisible = false;
  bool hasConnected = true;

  bool isPartner = true;
  bool isMutePartner = false;

  late AnimationController animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 250), animationBehavior: AnimationBehavior.preserve);
  final animationTween = Tween<double>(begin: 0.0, end: -200);
  late Animation<double> animation = animation = animationTween.animate(animationController)..addListener(update);
  List<String>? movables;
  Offset offset = Offset.zero;
  // MuteRoom? listMuteRoom;

  @override
  void onInit() async {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _socket = await BaseSocket.initConnectWithHeader(SocketPath.room);
    _receiveMessage = await BaseSocket.initConnectWithHeader(SocketPath.message);
    _initAllEventListener();

    //* do not put the code under this function as it will not run
    // await initPlayAndRecorder();
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
    animationController.dispose();
  }

  void _initAllEventListener() async {
    _listenReceiveMessage();
    _listenTypingEvent();
    _listenSeenMessage();
    _listenUnsentMessage();
    _listenUploadingEvent();
    _listenOnRecordingEvent();
    _listenOnLineStatus();

    // await listenerEvent();
  }

  void getAllPersonRoom() async {
    chatRoomList = await _callToGetRooms(false) ?? [];
    update(['totalCount', 'list']);
  }

  void getAllGroupRoom() async {
    groupRoomList = await _callToGetRooms(true) ?? [];
    update(['totalCount', 'groupList']);
  }

  void getChatRoom() async {
    getAllGroupRoom();
    getAllPersonRoom();
  }

  /// [ isNeedPersonalListUpdate ]
  /// this variable need to identify which list state we need to modify
  void removeUnreadCount(roomId, bool isNeedPersonalListUpdate) async {
    var controller = Get.find<ChatRoomController>();
    if (chatRoomList.isNotEmpty) {
      var roomPersonal = chatRoomList.firstWhere((element) => element.id == roomId);
      //click from chatlist menu list
      if (isNeedPersonalListUpdate) {
        if (!roomPersonal.isMuted) {
          controller.totalMessageUnreadCount -= roomPersonal.unreadCount;
        }
        if (roomPersonal.type == 'g') {
          if (!roomPersonal.isMuted) {
            controller.totalUnreadCountInGroup -= roomPersonal.unreadCount;
          }
          roomPersonal.hasMention = false;
          roomPersonal.isMarkUnread = false;
        }
        //click from group menu list
      } else {
        var groupRoom = groupRoomList.firstWhere((element) => element.id == roomId);
        if (!groupRoom.isMuted) {
          controller.totalMessageUnreadCount -= groupRoom.unreadCount;
          controller.totalUnreadCountInGroup -= groupRoom.unreadCount;
        }

        // unread
        groupRoom.unreadCount = 0;
        // mention
        groupRoom.hasMention = false;
        roomPersonal.hasMention = false;
        // mark unread
        roomPersonal.isMarkUnread = false;
        groupRoom.isMarkUnread = false;
      }
      roomPersonal.unreadCount = 0;
      // controller.totalUnreadBadges -= controller.totalMessageUnreadCount;
      update(['totalCount', '$roomId', 'list']);
    }
  }

  void markRoomAsRead(String roomId, bool isFromGroup) async {
    try {
      var request = {
        'body': {'roomId': roomId}
      };
      _socket = await BaseSocket.initConnectWithHeader(SocketPath.room);
      _socket.emitWithAck(
        SocketPath.markAsRead,
        request,
        ack: (result) async {
          var res = BaseApiResponse.generateResponse(
            response: result,
            parseData: ((data) => MarkAsReadResponseModel.fromMap(result)),
          );
          if (res.success) {
            await getTotalUnreadCount();
            var roomUnreadCount = result['data']['unreadCount'];
            var personalTarget = chatRoomList.firstWhere((item) => item.id == roomId);
            personalTarget.unreadCount = roomUnreadCount;
            personalTarget.unReadCountBiggerThan0 = personalTarget.unreadCount > 0;
            if (isFromGroup) {
              var groupTarget = groupRoomList.firstWhere((item) => item.id == roomId);
              groupTarget.isMarkUnread = false;
            }
            personalTarget.unreadCount = 0;
            personalTarget.isMarkUnread = false;
            update([roomId]);
          }
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  void markRoomAsUnRead(String roomId, bool isFromGroup) async {
    try {
      var request = {
        'body': {'roomId': roomId}
      };
      _socket = await BaseSocket.initConnectWithHeader(SocketPath.room);
      _socket.emitWithAck(
        SocketPath.markAsUnread,
        request,
        ack: (result) async {
          if ((result['data'] as Map).isNotEmpty) {
            var unreadCount = result['data']['unreadCount'];
            if (isFromGroup) {
              var groupTarget = groupRoomList.firstWhere((item) => item.id == roomId);
              groupTarget.isMarkUnread = true;
            }

            var target = chatRoomList.firstWhere((item) => item.id == roomId);
            target.unReadCountBiggerThan0 = unreadCount > 0;

            target.isMarkUnread = true;
            await getTotalUnreadCount();
            update([roomId]);
          }
        },
      );
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      log(e.toString());
    }
  }

  Future<bool> hideChatRoom(String roomId) async {
    final completer = Completer<bool>();
    try {
      var request = {
        'body': {'roomId': roomId}
      };
      _socket = await BaseSocket.initConnectWithHeader(SocketPath.room);
      _socket.emitWithAck(
        SocketPath.hideChatRoom,
        request,
        ack: (result) async {
          if (result['data']['success']) {
            chatRoomList.removeWhere((element) => element.id == roomId);
            await getTotalUnreadCount();
            update([roomId, 'list', 'groupList']);
            completer.complete(true);
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

  Future<bool> deleteChatRoom(String roomId) async {
    final completer = Completer<bool>();
    try {
      var request = {
        'body': {'roomId': roomId}
      };
      _socket = await BaseSocket.initConnectWithHeader(SocketPath.message);
      _socket.emitWithAck(
        SocketPath.deleteChat,
        request,
        ack: (result) async {
          try {
            if (result['data'] != null) {
              var success = result['data']['success'] ?? false;
              if (success) {
                chatRoomList.removeWhere((element) => element.id == roomId);
                await getTotalUnreadCount();
                update([roomId, 'list', 'groupList']);
                completer.complete(true);
              }
            }
          } catch (e) {
            completer.complete(false);
            final message = e.toString();
            await CrashReport.send(ReportModel(message: message));
            log(e.toString());
          }
        },
      );
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      log(e.toString());
    }
    return completer.future;
  }

  void updateMute(roomId, bool isMute, bool isFromGroup) {
    ChatRoomModel? targetPersonalRoom;
    ChatRoomModel? targetGroupRoom;
    try {
      if (isFromGroup) {
        targetGroupRoom = groupRoomList.firstWhereOrNull((chat) => chat.id == roomId);
        targetPersonalRoom = chatRoomList.firstWhereOrNull((chat) => chat.id == roomId);
      } else {
        targetPersonalRoom = chatRoomList.firstWhereOrNull((chat) => chat.id == roomId);
      }
      if (isFromGroup) {
        if (targetGroupRoom != null) {
          targetGroupRoom;
          targetGroupRoom.isMuted = isMute;
        }
        if (targetPersonalRoom != null) {
          targetPersonalRoom;
          targetPersonalRoom.isMuted = isMute;
        }
      } else {
        if (targetPersonalRoom != null) {
          targetPersonalRoom;
          targetPersonalRoom.isMuted = isMute;
        }
      }
      update([roomId]);
    } catch (e) {
      log(e.toString());
    }
  }

  void _listenUnsentMessage() async {
    try {
      _receiveMessage.on(SocketPath.unsendMessage, (data) {
        var roomId = data['data']['room']['_id'];
        var messageStatus = data['data']['message']['status'];
        if (chatRoomList.isNotEmpty) {
          var foundRoomIndex = chatRoomList.indexWhere((room) => room.id == roomId);
          if (foundRoomIndex != -1) {
            chatRoomList[foundRoomIndex].lastMessage!.status = messageStatus;
            update([roomId]);
          }
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  void _listenSeenMessage() async {
    try {
      _receiveMessage.on(SocketPath.seenMessage, (data) {
        var roomId = data['data']['room'];
        var seenUserId = data['data']['user'];
        if (chatRoomList.isNotEmpty) {
          var foundRoomIndex = chatRoomList.indexWhere((element) => element.id == roomId);
          if (foundRoomIndex != -1) {
            var senderId = chatRoomList[foundRoomIndex].lastMessage?.sender?.id ?? '';
            if (senderId != seenUserId) {
              chatRoomList[foundRoomIndex].lastMessage?.isSeen = true;
              update([roomId]);
            }
          }
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  void _listenReceiveMessage() async {
    try {
      _receiveMessage.on(SocketPath.receiveMessage, (data) async {
        var checkRoomInPayload = data['data']['room'];
        var checkMessageInPayload = data['data']['message']['_id'];

        // if (accountId != senderId) {
        //   if (listMuteRoom!.mutedRoom!.isEmpty) {
        //     MessageHelper.messageVibration();
        //     MessageHelper.playMessageReceivedSound();
        //   } else {
        //     if (listMuteRoom!.mutedRoom!.contains(checkRoomReceiveId)) {
        //     } else {
        //       MessageHelper.messageVibration();
        //       MessageHelper.playMessageReceivedSound();
        //     }
        //   }
        // }

        // check where to update the ui
        if (checkRoomInPayload != null && checkMessageInPayload != null) {
          _listenLastMessageToUpdateRooms(data);
          if (checkRoomInPayload['type'] == 'g') {
            _listenLastMessageToUpdateGroupRooms(data);
          }
        }
        if (checkRoomInPayload['_id'] != trckRoomIn) {
          await getTotalUnreadCount();
        }
      });
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      log(e.toString());
    }
  }

  void _listenLastMessageToUpdateRooms(data) async {
    ListenRoomModel? room = ListenRoomModel.fromJson(data['data']['room']);
    ListenMessageModel? listenMessage = ListenMessageModel.fromJson(data['data']['message']);

    // find specific room to update
    int? indexOfRoomToUpdate;
    bool officialAnnouncement = (room.isOfficial ?? false) && (room.type == 'html');

    if (officialAnnouncement) {
      indexOfRoomToUpdate = chatRoomList.indexWhere((element) => element.isOfficial == true);
    } else {
      indexOfRoomToUpdate = chatRoomList.indexWhere((element) => element.id == room.id);
    }

    //TODO: ignore create group message to prevent duplicate message
    if (listenMessage.message == 'activity.group.create') {
      return;
    }

    //fetch a hidden room when listen to new message, -1 is index of unfound item
    else if (indexOfRoomToUpdate == -1) {
      ChatRoomModel? roomModel = await getRoomById(room.id);
      var lastSenderId = roomModel?.lastMessage?.sender?.profileId ?? '';
      // mark as read if last message send by you
      if (lastSenderId.split('_').last == accountId) {
        roomModel!.unReadCountBiggerThan0 = false;
      }
      chatRoomList.insert(0, roomModel!);
      chatRoomList.toSet().toList();
      listTileKey.currentState?.insertItem(0);
      update(['totalCount', 'list']);
    } else {
      ChatRoomModel? roomToUpdate;
      try {
        roomToUpdate = chatRoomList[indexOfRoomToUpdate];
      } catch (e) {
        final message = e.toString();
        await CrashReport.send(ReportModel(message: message));
      }

      // check duplication listen event
      if (listenMessage.id != roomToUpdate!.lastMessage?.id) {
        try {
          //*prop to up date
          if (officialAnnouncement) {
            roomToUpdate.lastMessage?.htmlContent = listenMessage.htmlContent;
          } else {
            //update allListRooms in Chat Tab of DashBorad Screen
            roomToUpdate.lastMessage?.sender?.id = listenMessage.sender?.id ?? '';
            roomToUpdate.lastMessage?.sender?.name = listenMessage.sender?.name ?? '';
            roomToUpdate.lastMessage?.attachments = listenMessage.attachments;
            roomToUpdate.lastMessage?.type = listenMessage.type;
            roomToUpdate.lastMessage?.status = listenMessage.status;
            roomToUpdate.lastMessage?.refType = listenMessage.refType;
            roomToUpdate.lastMessage?.deleters = listenMessage.deleters;
            roomToUpdate.lastMessage?.rejectCode = listenMessage.rejectCode;
            roomToUpdate.lastMessage?.updatedAt = listenMessage.updatedAt;
            roomToUpdate.lastMessage?.createdAt = listenMessage.createdAt;

            roomToUpdate.lastMessage?.sticker =
                listenMessage.sticker != null ? Sticker.fromMap(listenMessage.sticker) : Sticker('', '', '');
            roomToUpdate.lastMessage?.isSeen = listenMessage.isSeen;
            roomToUpdate.lastMessage?.isPinned = listenMessage.isPinned;
            roomToUpdate.lastMessage?.message = listenMessage.message;
            roomToUpdate.lastMessage?.args = listenMessage.args;
            roomToUpdate.lastMessage?.mentions = listenMessage.mentions;

            // * audio call update
            roomToUpdate.lastMessage?.call = listenMessage.call;

            if (roomToUpdate.lastMessage?.mentions != null && roomToUpdate.lastMessage!.mentions!.isNotEmpty) {
              // bool _isHaveMentionMe = false;
              roomToUpdate.lastMessage?.mentions?.forEach((element) {
                if (element.id == accountId && trckRoomIn.isEmpty) {
                  roomToUpdate!.hasMention = true;
                }
              });
            }

            // _roomToUpdate.lastMessage.
            // roomToUpdate.draft = draftmodel.Draft(showDraft: false);
            roomToUpdate.lastMessage?.id = listenMessage.id;

            //update unread count
            var isSeen = listenMessage.isSeen == true;
            var senderId = listenMessage.sender?.id;
            var sentByMe = senderId == accountId;
            if (isSeen || sentByMe) {
              roomToUpdate.unreadCount = 0;
            } else {
              if (roomToUpdate.id != trckRoomIn) {
                roomToUpdate.lastMessage?.isSeen = false;
                roomToUpdate.unreadCount++;
              }
            }

            //update order of list
            if (indexOfRoomToUpdate != 0) {
              chatRoomList.removeAt(indexOfRoomToUpdate);
              if (listTileKey.currentState != null) {
                listTileKey.currentState?.removeItem(
                  indexOfRoomToUpdate,
                  (_, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      child: const Card(
                        elevation: 0,
                        margin: EdgeInsets.all(10),
                      ),
                    );
                  },
                  duration: const Duration(milliseconds: 500),
                );
              }
              chatRoomList.insert(0, roomToUpdate);
              if (listTileKey.currentState != null) {
                listTileKey.currentState!.insertItem(0);
              }
            }
          }
          update([room.id ?? 'official', 'totalCount', 'list', 'groupList']);
        } catch (e) {
          rethrow;
        }
      }
    }
  }

  void _listenLastMessageToUpdateGroupRooms(data) async {
    try {
      ListenRoomModel? room = ListenRoomModel.fromJson(data['data']['room']);
      ListenMessageModel? listenMessage = ListenMessageModel.fromJson(data['data']['message']);

      // find specific room to update
      int? indexOfGroupRoomToUpdate;
      indexOfGroupRoomToUpdate = groupRoomList.indexWhere((element) => element.id == room.id);

      //TODO: ignore create group message to prevent duplicate message
      if (listenMessage.message == 'activity.group.create') {
        return;
      }

      // check if remove from group
      if (listenMessage.message == 'activity.group.removeMember') {
        var removedId = listenMessage.args['removed']?['profileId'];
        if (removedId.split('_').last == accountId) {
          if (indexOfGroupRoomToUpdate == -1) {
            return;
          } else {
            groupRoomList.removeAt(indexOfGroupRoomToUpdate);
            if (groupListTileKey.currentState != null) {
              groupListTileKey.currentState?.removeItem(
                indexOfGroupRoomToUpdate,
                (_, animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    child: const Card(
                      elevation: 0,
                      margin: EdgeInsets.all(10),
                    ),
                  );
                },
                duration: const Duration(milliseconds: 500),
              );
              update(['groupList']);
            }
            return;
          }
        }
      }

      //fetch a hidden room when listen to new message, -1 is index of unfound item
      if (indexOfGroupRoomToUpdate == -1) {
        var newRoom = data['data']['room'];
        var roomResponse = ChatRoomModel.fromJson(newRoom);
        ChatRoomModel? roomModel = roomResponse;
        var lastSenderId = roomModel.lastMessage?.sender?.profileId ?? '';
        // mark as read if last message send by you
        if (lastSenderId.split('_').last == accountId) {
          roomModel.unReadCountBiggerThan0 = false;
        } else {
          roomModel.unreadCount++;
        }
        groupRoomList.insert(0, roomModel);
        groupListTileKey.currentState?.insertItem(0);
        update(['totalCount', 'groupList']);
      } else {
        ChatRoomModel? groupRoomToUpdate;
        try {
          groupRoomToUpdate = groupRoomList[indexOfGroupRoomToUpdate];
        } catch (e) {
          final message = e.toString();
          await CrashReport.send(ReportModel(message: message));
          if (groupRoomList.isEmpty) {
            getAllGroupRoom();
            rethrow;
          }
          log('updateRoomList from listen error: indexToUpdate $indexOfGroupRoomToUpdate :$e');
        }

        // check duplication listen event
        if (listenMessage.id != groupRoomToUpdate!.lastMessage?.id) {
          try {
            //*prop to up date
            //update only group room list  in Group Tab of DashBorad Screen
            groupRoomToUpdate.lastMessage?.id = listenMessage.id;
            groupRoomToUpdate.lastMessage?.attachments = listenMessage.attachments;
            groupRoomToUpdate.lastMessage?.type = listenMessage.type;
            groupRoomToUpdate.lastMessage?.status = listenMessage.status;
            groupRoomToUpdate.lastMessage?.refType = listenMessage.refType;
            groupRoomToUpdate.lastMessage?.deleters = listenMessage.deleters;
            groupRoomToUpdate.lastMessage?.rejectCode = listenMessage.rejectCode;
            groupRoomToUpdate.lastMessage?.createdAt = listenMessage.createdAt;
            groupRoomToUpdate.lastMessage?.updatedAt = listenMessage.updatedAt;
            groupRoomToUpdate.lastMessage?.sticker =
                listenMessage.sticker != null ? Sticker.fromMap(listenMessage.sticker) : Sticker('', '', '');
            groupRoomToUpdate.lastMessage?.args = listenMessage.args;
            groupRoomToUpdate.lastMessage?.isSeen = listenMessage.isSeen;
            groupRoomToUpdate.lastMessage?.isPinned = listenMessage.isPinned;
            groupRoomToUpdate.lastMessage?.message = listenMessage.message;
            groupRoomToUpdate.lastMessage?.mentions = listenMessage.mentions;
            groupRoomToUpdate.lastMessage?.call = listenMessage.call;
            //the prop below not include in ChatRoomModel

            groupRoomToUpdate.lastMessage?.sender?.id = listenMessage.sender?.id ?? '';

            //update unread count
            var senderId = listenMessage.sender?.id;
            var isSeen = listenMessage.isSeen == true;
            var sentByMe = senderId == accountId;
            if (isSeen || sentByMe) {
              groupRoomToUpdate.unreadCount = 0;
            } else {
              if (groupRoomToUpdate.id != trckRoomIn) {
                groupRoomToUpdate.unreadCount++;
                groupRoomToUpdate.lastMessage?.isSeen = false;
              }
            }
            groupRoomToUpdate.lastMessage?.mentions?.forEach((element) {
              if (element.id == accountId) {
                groupRoomToUpdate!.hasMention = true;
              }
            });

            //update order of list
            if (indexOfGroupRoomToUpdate != 0) {
              groupRoomList.removeAt(indexOfGroupRoomToUpdate);
              if (groupListTileKey.currentState != null) {
                groupListTileKey.currentState!.removeItem(
                  indexOfGroupRoomToUpdate,
                  (_, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      child: const Card(
                        elevation: 0,
                        margin: EdgeInsets.all(10),
                      ),
                    );
                  },
                  duration: const Duration(milliseconds: 500),
                );
              }
              groupRoomList.insert(0, groupRoomToUpdate);
              if (groupListTileKey.currentState != null) {
                groupListTileKey.currentState!.insertItem(0);
              }
            }

            update([room.id ?? 'official', 'list', 'groupList', 'totalCount']);
          } catch (e) {
            final message = e.toString();
            await CrashReport.send(ReportModel(message: message));
            log(e.toString());
          }
        }
      }
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      log(e.toString());
    }
  }

  void _listenTypingEvent() async {
    _receiveMessage.on(SocketPath.onTyping, (data) {
      try {
        var roomId = data['data']['room']['_id'];
        var typing = (data['data']['typing'] as List).isNotEmpty;
        ChatRoomModel? targetPersonRoom;
        for (var i in chatRoomList) {
          if (i.id == roomId) {
            targetPersonRoom = i;
          }
        }

        ChatRoomModel? targetForGroupRoom;
        for (var i in groupRoomList) {
          if (i.id == roomId) {
            targetForGroupRoom = i;
          }
        }

        if (typing) {
          //update for PersonRoom Tab
          targetPersonRoom?.isTyping = true;
          var peopleTyping = data['data']['typing'];

          for (var i in peopleTyping) {
            if (targetPersonRoom?.whoTyping?.contains(i['name']) ?? false) {
              continue;
            }
            targetPersonRoom?.whoTyping?.add(i['name']);
            targetPersonRoom?.whoTyping?.toSet().toList();
          }
          //Update for only group room Tab
          var isGroup = (data['data']['room']['type']) == 'g';
          if (isGroup) {
            targetForGroupRoom?.isTyping = true;
            var peopleTyping = data['data']['typing'];

            for (var i in peopleTyping) {
              if (targetForGroupRoom?.whoTyping?.contains(i['name']) ?? false) {
                continue;
              }
              targetForGroupRoom?.whoTyping?.add(i['name']);
              targetForGroupRoom?.whoTyping?.toSet().toList();
            }
          }
          update([roomId]);
        }

        if (!typing) {
          targetPersonRoom?.whoTyping = [];
          targetPersonRoom?.isTyping = false;

          targetForGroupRoom?.isTyping = false;
          targetForGroupRoom?.whoTyping = [];
          update([roomId]);
        }
      } catch (e) {
        final message = e.toString();
        CrashReport.send(ReportModel(message: message));
        log(e.toString());
      }
    });
  }

  void _listenOnRecordingEvent() async {
    _receiveMessage.on(SocketPath.onRecording, (data) {
      try {
        var roomId = data['data']['room']['_id'];
        var isRecordingding = (data['data']['recording'] as List).isNotEmpty;
        ChatRoomModel? targetPersonRoom;
        ChatRoomModel? targetForGroupRoom;
        // TODO: need to improve this logic
        for (var i in chatRoomList) {
          if (i.id == roomId) {
            targetPersonRoom = i;
          }
        }

        for (var i in groupRoomList) {
          if (i.id == roomId) {
            targetForGroupRoom = i;
          }
        }

        if (isRecordingding) {
          //update for PersonRoom Tab
          targetPersonRoom?.isRecording = true;
          var peopleOnRecording = data['data']['recording'];
          for (var i in peopleOnRecording) {
            if (targetPersonRoom?.whoRecording?.contains(i['name']) ?? false) {
              continue;
            }
            targetPersonRoom?.whoRecording?.add(i['name']);
            targetPersonRoom?.whoRecording?.toSet().toList();
          }
          //Update for only group room Tab
          var isGroup = (data['data']['room']['type']) == 'g';
          if (isGroup) {
            targetForGroupRoom?.isRecording = true;
            var peopleTyping = data['data']['recording'];

            for (var i in peopleTyping) {
              if (targetForGroupRoom?.whoRecording?.contains(i['name']) ?? false) {
                continue;
              }
              targetForGroupRoom?.whoRecording?.add(i['name']);
              targetForGroupRoom?.whoRecording?.toSet().toList();
            }
          }
        }

        if (!isRecordingding) {
          targetPersonRoom?.whoRecording = [];
          targetForGroupRoom?.whoRecording = [];
          targetPersonRoom?.isRecording = false;
          targetForGroupRoom?.isRecording = false;
        }
        update([roomId, 'list', 'groupList']);
      } catch (e) {
        rethrow;
      }
    });
  }

  void _listenUploadingEvent() async {
    _receiveMessage.on(SocketPath.onUploading, (data) {
      try {
        var roomId = data['data']['room']['_id'];
        List listUploadUser = data['data']['uploading'] ?? [];
        var uploading = listUploadUser.isNotEmpty;
        if (uploading) {
          var target = chatRoomList.firstWhere((item) => item.id == roomId);
          target.isRecieving = true;
          target.whoSending = listUploadUser.last['name'];
          if (groupRoomList.isNotEmpty) {
            var targetGroup = groupRoomList.firstWhereOrNull((item) => item.id == roomId);
            if (targetGroup != null) {
              targetGroup.isRecieving = true;
              targetGroup.whoSending = listUploadUser.last['name'];
            }
          }
        } else {
          var target = chatRoomList.firstWhere((item) => item.id == roomId);
          target.isRecieving = false;
          target.isUploading = false;
          if (groupRoomList.isNotEmpty) {
            var targetGroup = groupRoomList.firstWhereOrNull((item) => item.id == roomId);
            if (targetGroup != null) {
              targetGroup.isRecieving = false;
              targetGroup.isUploading = false;
            }
          }
        }

        update([roomId, 'list', 'groupList']);
      } catch (e) {
        final message = e.toString();
        CrashReport.send(ReportModel(message: message));
        log(e.toString());
      }
    });
  }

  void _listenOnLineStatus() async {
    try {
      _receiveMessage.on(SocketPath.userOnline, (data) {
        if (data.containsKey('data')) {
          var roomId = data['data']['room'];
          var userOnline = data['data']['isOnline'];
          var roomOnline = chatRoomList.firstWhereOrNull((element) => element.id == roomId);
          if (roomOnline != null) {
            roomOnline.statusOnline = userOnline;
            update([roomId, 'list', 'groupList']);
          }
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getTotalUnreadCount() async {
    try {
      _receiveMessage.emitWithAck(
        SocketPath.totalBadge,
        {},
        ack: (res) async {
          Map result = res as Map;
          if (result.containsKey('data')) {
            totalUnreadBadges = result['data']['total'];
            totalUnreadCountInGroup = result['data']['unreadMessage']['totalG'];
            totalUnreadCountInPerson = result['data']['unreadMessage']['totalP'];
            totalMessageUnreadCount = result['data']['unreadMessage']['total'];
            update(['totalCount']);
          }
        },
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<ChatRoomModel?> getRoomById(String? roomId) async {
    final completer = Completer<ChatRoomModel?>();
    try {
      var request = {
        'query': {'page': 1, '_id': roomId, 'limit': 1}
      };
      _socket = await BaseSocket.initConnectWithHeader(SocketPath.room);
      _socket.emitWithAck(
        SocketPath.getChatRooms,
        request,
        ack: (result) async {
          var res = BaseApiResponse.generateResponse(
              response: result, parseData: ((data) => ChatRoomResponseModel.fromMap(result)));
          if (res.success) {
            var singleList = res.result?.data ?? [];
            if (singleList.isNotEmpty) {
              completer.complete(singleList.first);
            } else {
              completer.complete(null);
            }
            update(['list', 'groupList']);
          }
        },
      );
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      completer.complete(null);
      log(e.toString());
    }
    return completer.future;
  }

  Future<List<ChatRoomModel>>? _callToGetRooms(bool isGroup) async {
    final completer = Completer<List<ChatRoomModel>>();
    try {
      Map<String, Map<String, Object>> request;
      if (!isGroup) {
        if (chatRoomList.isEmpty) {
          isPersonalListLoading = true;
        } else {
          isPersonalListUpdating = true;
          update(['onUpdate']);
        }
        request = {
          'query': {'page': 1, 'limit': 100}
        };
      } else {
        if (groupRoomList.isEmpty) {
          isGroupListLoading = true;
        } else {
          isGroupListUpdating = true;
          update(['onUpdate']);
        }
        request = {
          'query': {'page': 1, 'limit': 100, 'type': 'g'}
        };
      }
      _socket = await BaseSocket.initConnectWithHeader(SocketPath.room);
      _socket.emitWithAck(
        SocketPath.getChatRooms,
        request,
        ack: (result) async {
          var res = BaseApiResponse.generateResponse(
              response: result, parseData: ((data) => ChatRoomResponseModel.fromMap(result)));
          if (res.success) {
            await getTotalUnreadCount();
            // * group
            if (isGroup) {
              groupRoomList = res.result?.data ?? [];
              isGroupListUpdating = false;
              isGroupListLoading = false;
              update(['list', 'groupList', 'onUpdate']);
              completer.complete(groupRoomList);
            } else {
              chatRoomList = res.result?.data ?? [];
              isPersonalListLoading = false;
              isPersonalListUpdating = false;
              update(['list', 'groupList', 'onUpdate']);
              completer.complete(chatRoomList);
            }
          } else {
            isGroupListLoading = false;
            isPersonalListLoading = false;
            isPersonalListUpdating = false;
            isGroupListUpdating = false;
            update(['list', 'groupList', 'onUpdate']);
          }
        },
      );
    } catch (e) {
      isGroupListLoading = false;
      isPersonalListLoading = false;
      isPersonalListUpdating = false;
      isGroupListUpdating = false;
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      log(e.toString());
      completer.complete([]);
    }
    return completer.future;
  }

  Future<void> scrollToIndex() async {
    await scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
    );
    update();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        getAllGroupRoom();
        getAllPersonRoom();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      default:
        break;
    }
  }
}
