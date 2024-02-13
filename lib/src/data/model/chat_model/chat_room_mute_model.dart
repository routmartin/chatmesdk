class MuteRoomesponse {
  MuteRoom? data;

  MuteRoomesponse({
    required this.data,
  });

  factory MuteRoomesponse.fromJson(Map<String, dynamic> json) =>
      MuteRoomesponse(
        data: json['data'] != null ? MuteRoom.fromJson(json['data']) : null,
      );
}

class MuteRoom {
  List<String>? mutedRoom;

  MuteRoom({required this.mutedRoom});

  factory MuteRoom.fromJson(Map<String, dynamic> json) => MuteRoom(
        mutedRoom: json['mutedRoom'] != null
            ? List<String>.from(json['mutedRoom'].map((x) => x))
            : [],
      );
}
