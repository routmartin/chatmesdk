// To parse this JSON data, do
//
//     final listenRoomModel = listenRoomModelFromJson(jsonString);

import 'dart:convert';

ListenRoomModel listenRoomModelFromJson(String str) => ListenRoomModel.fromJson(json.decode(str));

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
        draft: json['draft'] == null ? null : Draft.fromMap(json['draft']),
        profileUrl: json['profileUrl'],
        numberOfOnlineUsers: json['numberOfOnlineUsers'],
      );
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

class Draft {
  String? message;
  bool showDraft = true;
  String? createdAt;

  Draft({this.message, this.showDraft = true, this.createdAt});

  factory Draft.fromMap(Map<String, dynamic> map) {
    return Draft(
      message: map['message'] != null ? map['message'] as String : null,
      createdAt: map['createdAt'] != null ? map['createdAt'] as String : null,
    );
  }
}
