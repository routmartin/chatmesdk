class CallParams {
  String id;
  String nameCaller;
  String avatar;
  String number;
  int type;
  int duration;
  String textAccept;
  String textDecline;
  String textMissedCall;
  String textCallback;
  Extra extra;
  // Android android;

  CallParams({
    required this.id,
    required this.nameCaller,
    required this.avatar,
    required this.number,
    required this.type,
    required this.duration,
    required this.textAccept,
    required this.textDecline,
    required this.textMissedCall,
    required this.textCallback,
    required this.extra,
    // required this.android,
  });

  factory CallParams.fromJson(Map<String, dynamic> json) => CallParams(
        id: json['id'],
        nameCaller: json['nameCaller'],
        avatar: json['avatar'],
        number: json['number'],
        type: json['type'],
        duration: json['duration'],
        textAccept: json['textAccept'],
        textDecline: json['textDecline'],
        textMissedCall: json['textMissedCall'],
        textCallback: json['textCallback'],
        extra: Extra.fromJson(json['extra']),
        // android: Android.fromJson(json['android']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameCaller': nameCaller,
        'avatar': avatar,
        'number': number,
        'type': type,
        'duration': duration,
        'textAccept': textAccept,
        'textDecline': textDecline,
        'textMissedCall': textMissedCall,
        'textCallback': textCallback,
        'extra': extra.toJson(),
        // 'android': android.toJson(),
      };
}

class Extra {
  String callId;
  String roomId;

  Extra({
    required this.callId,
    required this.roomId,
  });

  factory Extra.fromJson(Map<dynamic, dynamic> json) => Extra(
        callId: json['callId'] ?? '',
        roomId: json['roomId'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'callId': callId,
        'roomId': roomId,
      };
}
