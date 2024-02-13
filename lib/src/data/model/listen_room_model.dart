// To parse this JSON data, do
//
//     final listenRoomModel = listenRoomModelFromJson(jsonString);

import 'dart:convert';

ListenRoomModel listenRoomModelFromJson(String str) => ListenRoomModel.fromJson(json.decode(str));

String listenRoomModelToJson(ListenRoomModel data) => json.encode(data.toJson());

class ListenRoomModel {
  String? id;
  String? type;
  bool? isOfficial;
  String? name;
  String? description;
  PrivacyRoom? privacy;
  String? groupId;
  bool? isMuted;
  dynamic profileId;
  int? unreadCount;
  bool? isMarkUnread;
  String? recipient;
  String? avatar;
  DateTime? lastOnlineAt;
  bool? isOnline;
  bool? isActivated;
  Draft? draft;
  String? profileUrl;
  int? numberOfOnlineUsers;

  ListenRoomModel({
    this.id,
    this.type,
    this.isOfficial,
    this.name,
    this.description,
    this.privacy,
    this.groupId,
    this.isMuted,
    this.profileId,
    this.unreadCount,
    this.isMarkUnread,
    this.recipient,
    this.avatar,
    this.lastOnlineAt,
    this.isOnline,
    this.isActivated,
    this.draft,
    this.profileUrl,
    this.numberOfOnlineUsers,
  });

  factory ListenRoomModel.fromJson(Map<String, dynamic> json) => ListenRoomModel(
        id: json['_id'],
        type: json['type'],
        isOfficial: json['isOfficial'],
        name: json['name'],
        description: json['description'],
        privacy: json['privacy'] == null ? null : PrivacyRoom.fromJson(json['privacy']),
        groupId: json['groupId'],
        isMuted: json['isMuted'],
        profileId: json['profileId'],
        unreadCount: json['unreadCount'],
        isMarkUnread: json['isMarkUnread'],
        recipient: json['recipient'],
        avatar: json['avatar'],
        lastOnlineAt: json['lastOnlineAt'] == null ? null : DateTime.parse(json['lastOnlineAt']),
        isOnline: json['isOnline'],
        isActivated: json['isActivated'],
        draft: json['draft'] == null ? null : Draft.fromJson(json['draft']),
        profileUrl: json['profileUrl'],
        numberOfOnlineUsers: json['numberOfOnlineUsers'],
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'type': type,
        'isOfficial': isOfficial,
        'name': name,
        'description': description,
        'privacy': privacy?.toJson(),
        'groupId': groupId,
        'isMuted': isMuted,
        'profileId': profileId,
        'unreadCount': unreadCount,
        'isMarkUnread': isMarkUnread,
        'recipient': recipient,
        'avatar': avatar,
        'lastOnlineAt': lastOnlineAt?.toIso8601String(),
        'isOnline': isOnline,
        'isActivated': isActivated,
        'draft': draft?.toJson(),
        'profileUrl': profileUrl,
        'numberOfOnlineUsers': numberOfOnlineUsers,
      };
}

class Draft {
  Draft();

  factory Draft.fromJson(Map<String, dynamic> json) => Draft();

  Map<String, dynamic> toJson() => {};
}

class PrivacyRoom {
  bool? isRequiredApproval;
  bool? isNameStricted;

  PrivacyRoom({
    this.isRequiredApproval,
    this.isNameStricted,
  });

  factory PrivacyRoom.fromJson(Map<String, dynamic> json) => PrivacyRoom(
        isRequiredApproval: json['isRequiredApproval'],
        isNameStricted: json['isNameStricted'],
      );

  Map<String, dynamic> toJson() => {
        'isRequiredApproval': isRequiredApproval,
        'isNameStricted': isNameStricted,
      };
}
