import 'dart:convert';
import 'attachment_model.dart';
import 'chat_model/chat_room_model.dart';
import 'pagination.dart';
import 'chat_model/sticker.dart';

class ChatMessageResponeModel {
  List<MessageModel>? data;
  Pagination? pagination;

  ChatMessageResponeModel({this.data, this.pagination});

  factory ChatMessageResponeModel.fromMap(Map<String, dynamic> data) {
    return ChatMessageResponeModel(
      data: (data['data'] as List<dynamic>?)?.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList(),
      pagination: data['pagination'] == null ? null : Pagination.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }

  factory ChatMessageResponeModel.fromJson(String data) {
    return ChatMessageResponeModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }
}

class MessageModel {
  MessageModel({
    this.id,
    this.type,
    this.status,
    this.refType,
    this.deleters,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.isPinned,
    this.message,
    this.args,
    this.sender,
    this.isSeen,
    this.mentions,
    this.ref,
    this.htmlContent,
    this.rejectCode,
    this.shareContact,
    this.isSelect = false,
    this.sticker,
    this.attachments,
    this.radioButtonSelectValue = '',
    this.isUploading,
    this.timeStamp = '',
    this.roomId,
    this.call,
  });
  bool? isUploading;
  String? id;
  String? type;
  String? status;
  String? rejectCode;
  String? refType;
  List<dynamic>? deleters;
  bool? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isPinned;
  String? message;
  String? htmlContent;
  Sticker? sticker;
  Map? args;
  Sender? sender;
  bool? isSelect;
  bool? isSeen;
  List<Mention>? mentions;
  MessageModel? ref;
  ShareContact? shareContact;
  List<AttachmentModel>? attachments;
  String? radioButtonSelectValue;
  String? timeStamp;
  String? roomId;
  Call? call;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['_id'] ?? '',
        type: json['type'] ?? '',
        status: json['status'] ?? '',
        refType: json['refType'] ?? '',
        deleters: json['deleters'] == null ? [] : List<dynamic>.from(json['deleters'].map((x) => x)),
        isDeleted: json['isDeleted'] ?? false,
        createdAt: json['createdAt'] == null ? DateTime.now() : DateTime.parse(json['createdAt'] ?? ''),
        updatedAt: json['updatedAt'] == null ? DateTime.now() : DateTime.parse(json['updatedAt'] ?? ''),
        isPinned: json['isPinned'] ?? false,
        message: json['message'] ?? '',
        htmlContent: json['htmlContent'] ?? '',
        args: json['args'] ?? {},
        isSeen: json['isSeen'] ?? false,
        mentions: json['mentions'] == null ? [] : List<Mention>.from(json['mentions'].map((x) => Mention.fromMap(x))),
        rejectCode: json['rejectCode'] ?? '',
        attachments: json['attachments'] == null
            ? null
            : (json['attachments'] as List<dynamic>?)
                ?.map((e) => AttachmentModel.fromMap(e as Map<String, dynamic>))
                .toList(),
        ref: json['ref'] == null ? null : MessageModel.fromJson(json['ref']),
        shareContact: json['contact'] == null ? null : ShareContact.fromJson(json['contact']),
        sender: Sender.fromJson(json['sender']),
        sticker: json['sticker'] == null ? null : Sticker.fromMap(json['sticker']),
        call: json['call'] == null ? null : Call.fromJson(json['call']),
      );
}

class Mention {
  Mention({
    required this.id,
    required this.name,
  });

  String id;
  String name;

  factory Mention.fromMap(Map<String, dynamic> json) => Mention(
        id: json['_id'],
        name: json['name'],
      );

  Map<String, dynamic> toMap() => {
        '_id': id,
        'name': name,
      };
}

class Ref {
  Ref({required this.id, required this.isSeen, required this.sender, required this.message});

  String id;
  bool isSeen;

  String message;
  Sender sender;

  factory Ref.fromJson(Map<String, dynamic> json) => Ref(
        id: json['_id'],
        isSeen: json['isSeen'],
        message: json['message'] ?? '',
        sender: Sender.fromJson(json['sender']),
      );
}

class ShareContact {
  ShareContact(
      {required this.id, required this.fullName, required this.country, required this.profileId, required this.avatar});

  String id;
  String fullName;
  String country;
  String profileId;
  String avatar;

  factory ShareContact.fromJson(Map<String, dynamic> json) => ShareContact(
        id: json['_id'] ?? '',
        fullName: json['fullName'] ?? '',
        country: json['country'] ?? '',
        profileId: json['profileId'] ?? '',
        avatar: json['avatar'] ?? '',
      );
}

class Call {
  Call({
    required this.id,
    this.userId,
    this.startAt,
    this.receivedAt,
    this.endAt,
    this.name,
    this.isMissedCall,
  });

  String id;
  String? userId;
  DateTime? startAt;
  DateTime? receivedAt;
  DateTime? endAt;
  String? name;
  bool? isMissedCall;

  factory Call.fromJson(Map<String, dynamic> json) => Call(
        id: json['_id'] ?? '',
        userId: json['user'] ?? '',
        startAt: json['startAt'] == null ? null : DateTime.parse(json['startAt'] ?? ''),
        receivedAt: json['receivedAt'] == null ? null : DateTime.parse(json['receivedAt'] ?? ''),
        endAt: json['endAt'] == null ? null : DateTime.parse(json['endAt'] ?? ''),
        name: json['name'] ?? '',
        isMissedCall: json['isMissedCall'] ?? false,
      );
}

class MessageModel1 extends MessageModel {
  MessageModel1(
      {String? id,
      String? type,
      String? status,
      String? refType,
      List? deleters,
      bool? isDeleted,
      DateTime? createdAt,
      DateTime? updatedAt,
      bool? isPinned,
      String? message,
      args,
      Sender? sender,
      bool? isSeen})
      : super(
            id: id ?? '',
            type: type ?? '',
            status: status ?? '',
            refType: refType ?? '',
            deleters: deleters ?? [],
            isDeleted: isDeleted ?? false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isPinned: false,
            message: '',
            args: args,
            sender: sender ?? Sender(id: '', accountId: '', name: '', profileId: ''),
            isSeen: false);
}
