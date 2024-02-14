import 'dart:convert';

import '../pagination.dart';
import 'chat_room_model.dart';

class ChatRoomResponseModel {
  List<ChatRoomModel>? data;
  int totalUnreadCount;
  Pagination? pagination;

  ChatRoomResponseModel({this.data, this.pagination, this.totalUnreadCount = 0});

  factory ChatRoomResponseModel.fromMap(Map<String, dynamic> data) {
    return ChatRoomResponseModel(
      data: (data['data'] as List<dynamic>?)?.map((e) => ChatRoomModel.fromJson(e as Map<String, dynamic>)).toList(),
      pagination: data['pagination'] == null ? null : Pagination.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }

  factory ChatRoomResponseModel.fromJson(String data) {
    return ChatRoomResponseModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }
}
