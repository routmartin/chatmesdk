import 'chat_model/chat_room_model.dart';
import 'message_response_model.dart';

class ListenMessageModel {
  String? id;
  List<dynamic>? attachments;
  bool? localize;
  String? type;
  String? status;
  dynamic refType;
  dynamic ref;
  List<dynamic>? deleters;
  dynamic rejectCode;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic sticker;
  bool? isPinned;
  String? message;
  dynamic args;
  bool? isSeen;
  List<Mention>? mentions;
  dynamic contact;
  dynamic htmlContent;
  dynamic requestId;
  Sender? sender;
  String? notificationType;
  String? groupName;
  bool hasMention;
  List<MentionSavedContact> mentionSavedContact;
  Call? call;

  ListenMessageModel({
    this.id,
    this.attachments,
    this.localize,
    this.type,
    this.status,
    this.refType,
    this.ref,
    this.deleters,
    this.rejectCode,
    this.createdAt,
    this.updatedAt,
    this.sticker,
    this.isPinned,
    this.message,
    this.args,
    this.isSeen,
    this.mentions,
    this.contact,
    this.htmlContent,
    this.requestId,
    this.sender,
    this.notificationType,
    this.groupName,
    this.hasMention = false,
    required this.mentionSavedContact,
    this.call,
  });

  factory ListenMessageModel.fromJson(Map<String, dynamic> json) => ListenMessageModel(
        id: json['_id'],
        attachments: json['attachments'] == null ? [] : List<dynamic>.from(json['attachments']!.map((x) => x)),
        localize: json['localize'],
        type: json['type'],
        status: json['status'],
        refType: json['refType'],
        ref: json['ref'],
        deleters: json['deleters'] == null ? [] : List<dynamic>.from(json['deleters']!.map((x) => x)),
        rejectCode: json['rejectCode'],
        createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt']),
        sticker: json['sticker'],
        isPinned: json['isPinned'],
        message: json['message'],
        args: json['args'],
        isSeen: json['isSeen'],
        hasMention: json['hasMention'] ?? false,
        mentions: json['mentions'] == null ? [] : List<Mention>.from(json['mentions']!.map((x) => Mention.fromMap(x))),
        contact: json['contact'],
        htmlContent: json['htmlContent'],
        requestId: json['requestId'],
        sender: json['sender'] == null ? null : Sender.fromJson(json['sender']),
        notificationType: json['notificationType'],
        groupName: json['groupName'],
        mentionSavedContact: json['mentionSavedContact'] == null
            ? []
            : List<MentionSavedContact>.from(json['mentionSavedContact'].map((x) => MentionSavedContact.fromMap(x))),
        call: json['call'] == null ? null : Call.fromJson(json['call']),
      );
}

class MentionSavedContact {
  String id;
  String contact;
  String name;

  MentionSavedContact({
    required this.id,
    required this.contact,
    required this.name,
  });

  factory MentionSavedContact.fromMap(Map<String, dynamic> json) => MentionSavedContact(
        id: json['_id'],
        contact: json['contact'],
        name: json['name'],
      );
}
