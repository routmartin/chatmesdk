class BaseError {
  BaseError({
    required this.error,
    required this.message,
    required this.errorCode,
  });

  List<String> error;
  String message;
  int errorCode;

  factory BaseError.fromMap(Map<String, dynamic> json) => BaseError(
        error: List<String>.from(json['error'].map((x) => x.toString())),
        message: json['message'],
        errorCode: int.parse(json['errorCode'].toString()),
      );

  Map<String, dynamic> toMap() => {
        'error': List<dynamic>.from(error.map((x) => x.toString())),
        'message': message,
        'errorCode': errorCode,
      };
}
