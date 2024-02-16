import '../listen_room_model.dart';
import '../message_response_model.dart';
import 'sticker.dart';

class ChatRoomModel {
  ChatRoomModel({
    required this.id,
    required this.type,
    required this.name,
    required this.isMuted,
    required this.unreadCount,
    this.lastOnlineAt,
    this.draft,
    this.avatar,
    this.lastMessage,
    this.confirmSize = 0,
    this.buttonSize = 0,
    this.redColor = false,
    this.showConfirm = false,
    this.statusOnline = false,
    this.unReadCountBiggerThan0 = true,
    this.isOnline = false,
    this.isTyping = false,
    this.isUploading = false,
    this.isRecieving = false,
    this.isRecording = false,
    this.lastUnreadCountAmount = 0,
    this.isOfficial,
    this.isMarkUnread = false,
    this.profileUrl = '',
    this.whoTyping,
    this.whoSending,
    this.hasMention = false,
    this.whoRecording,
    this.isCalling = false,
    this.callId = '',
  });

  String profileUrl;
  int lastUnreadCountAmount;
  bool isMarkUnread;
  bool? isOfficial;
  String? id;
  String type;
  String name;
  String? avatar;
  bool isMuted;
  int unreadCount;
  String? lastOnlineAt;
  Draft? draft;
  LastMessage? lastMessage;
  double buttonSize;
  double confirmSize;
  bool redColor;
  bool showConfirm;
  bool statusOnline;
  bool unReadCountBiggerThan0;
  bool isOnline;
  bool isTyping;
  bool isRecording;
  bool isUploading;
  bool isRecieving;
  bool hasMention;
  bool isCalling;
  String callId;
  String? whoSending;
  List? whoTyping = [];
  List? whoRecording = [];

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) => ChatRoomModel(
        isMarkUnread: json['isMarkUnread'] ?? false,
        profileUrl: json['profileUrl'] ?? '',
        whoTyping: json['whoTyping'] ?? [],
        id: json['_id'],
        isOfficial: json['isOfficial'],
        type: json['type'] ?? 'g',
        name: json['name'] ?? '',
        isMuted: json['isMuted'] ?? false,
        isOnline: json['isOnline'] ?? false,
        isTyping: json['isTyping'] ?? false,
        avatar: json['avatar'] ?? '',
        unreadCount: json['unreadCount'] ?? 0,
        lastOnlineAt: json['lastOnlineAt'],
        hasMention: json['hasMention'] ?? false,
        statusOnline: json['isOnline'] ?? false,
        isCalling: json['isCalling'] ?? false,
        callId: json['callId'] ?? '',
        draft: json['draft'] == null ? null : Draft.fromMap(json['draft']),
        lastMessage: json['lastMessage'] == null ? null : LastMessage.fromJson(json['lastMessage']),
        whoRecording:
            ((json['recording'] as List?)?.isEmpty ?? true) ? [] : [(json['recording'] as List).first['name']],
        isRecording: (json['recording'] as List?)?.isNotEmpty ?? false,
        whoSending: ((json['uploading'] as List?)?.isEmpty ?? true) ? null : (json['uploading'] as List).first['name'],
        isRecieving: (json['uploading'] as List?)?.isNotEmpty ?? false,
      );
}

class LastMessage {
  LastMessage({
    this.attachments,
    this.id,
    this.localize,
    this.type,
    this.status,
    this.refType,
    this.deleters,
    this.rejectCode,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.isPinned,
    this.message,
    this.args,
    this.sender,
    this.isSeen,
    this.sticker,
    this.htmlContent,
    this.mentions,
    this.call,
  });
  String? htmlContent;
  String? id;
  List<dynamic>? attachments;
  bool? localize;
  bool? isSeen;
  String? type;
  String? status;
  String? refType;
  List<dynamic>? deleters;
  dynamic rejectCode;
  bool? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  Sticker? sticker;
  bool? isPinned;
  String? message;
  dynamic args;
  Sender? sender;
  List<Mention>? mentions;
  Call? call;

  factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
        htmlContent: json['htmlContent'] ?? '',
        id: json['_id'] ?? '',
        attachments: json['attachments'] == null ? [] : List<dynamic>.from(json['attachments'].map((x) => x)),
        localize: json['localize'] ?? false,
        type: json['type'] ?? '',
        isSeen: json['isSeen'] ?? false,
        status: json['status'] ?? '',
        refType: json['refType'] ?? '',
        deleters: json['deleters'] == null ? [] : List<dynamic>.from(json['deleters'].map((x) => x)),
        rejectCode: json['rejectCode'] ?? '',
        isDeleted: json['isDeleted'] ?? false,
        createdAt: json['createdAt'] == null ? DateTime.now() : DateTime.parse(json['createdAt']),
        updatedAt: json['createdAt'] == null ? DateTime.now() : DateTime.parse(json['updatedAt']),
        sticker: json['sticker'] == null ? Sticker('', '', '') : Sticker.fromMap(json['sticker']),
        isPinned: json['isPinned'] ?? false,
        message: json['message'] ?? '',
        args: json['args'],
        mentions: json['mentions'] == null
            ? null
            : List<Mention>.from(
                json['mentions'].map(
                  (x) => Mention.fromMap(x),
                ),
              ),
        sender: json['sender'] == null
            ? Sender(
                accountId: '',
                id: '',
                profileId: '',
                name: '',
              )
            : Sender.fromJson(
                json['sender'],
              ),
        call: json['call'] == null ? null : Call.fromJson(json['call']),
      );
}

class Sender {
  Sender({
    this.id,
    this.accountId,
    this.avatar,
    this.name,
    this.profileId,
  });

  String? id;
  String? accountId;
  String? avatar;
  String? name;
  String? profileId;

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
        id: json['merchantUserId'] ?? '',
        accountId: json['accountId'] ?? '',
        avatar: json['avatar'] ?? '',
        name: json['name'] ?? '',
        profileId: json['profileId'] ?? '',
      );
}

class ChatArgumentModel {
  final String roomId;
  final String avatar;
  final String name;
  final String lastOnlineAt;
  ChatArgumentModel({
    required this.roomId,
    required this.avatar,
    required this.name,
    required this.lastOnlineAt,
  });
}
