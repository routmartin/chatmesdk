import 'package:get/get.dart';
import 'package:intl/date_symbol_data_custom.dart';
import 'package:intl/intl.dart';
import 'package:moment_dart/moment_dart.dart';
import '../../data/model/message_response_model.dart';

class DateTimeHelper {
  static String get _languageCode => Get.locale?.languageCode ?? 'en';

  static String getShortTimer(DateTime dateTime) => _languageCode == 'zh'
      ? DateFormat('a hh:mm', _languageCode).format(dateTime)
      : DateFormat('hh:mm a', _languageCode).format(dateTime);

  static String generateMessageWithTimeStamp(MessageModel message, List<MessageModel> listMessage) {
    final now = DateTime.now();
    // final yesterday = now.subtract(Duration(days: 1));
    final today = DateTime(now.year, now.month, now.day); // start from 00:00 (12AM)
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    var messageDate =
        DateFormat('yyyy-MM-dd HH:mm:ss', _languageCode).parse(message.createdAt!.toString(), true).toLocal();

    if (messageDate.isAfter(today)) {
      return _languageCode == 'zh'
          ? DateFormat('a hh:mm', _languageCode).format(messageDate)
          : DateFormat('hh:mm a', _languageCode).format(messageDate);
    } else if (messageDate.isAfter(yesterday)) {
      return '${'yesterday'.tr} ${getShortTimer(messageDate)}';
    } else {
      return _languageCode == 'zh'
          ? DateFormat('yyyy MMMM dd 日 a hh:mm', _languageCode).format(messageDate)
          : DateFormat('dd MMMM yyyy hh:mm a', _languageCode).format(messageDate);
    }
  }

  static String formate(String? date) {
    initializeDateFormattingCustom();
    if (date != null) {
      return DateFormat('yyyy-MM-dd-h-m', _languageCode).format(DateTime.parse(date));
    }
    return '';
  }

  static String showTime24H(DateTime? date) {
    if (date == null) return '';
    //*2:40 PM
    final format = DateFormat.jm(_languageCode);
    return format.format(date.add(const Duration(hours: 7)));
  }

  static String showDateAsNumber(String date) {
    //*16/03/2023
    return _languageCode == 'zh'
        ? DateFormat('y/MM/d', _languageCode).format(DateTime.parse(date))
        : DateFormat('d/MM/y', _languageCode).format(DateTime.parse(date));
  }

  static String showShortDate(String date) {
    return DateFormat.yMMMMd(_languageCode).format(DateTime.parse(date));
  }

  static bool differentTimeWithTimeZone(
    int expectedSecond,
    DateTime dateTime,
  ) {
    var now = DateTime.now();
    var diff = now.difference(dateTime);
    if (diff.inSeconds < expectedSecond) {
      return true;
    }
    return false;
  }

  static String timeStamp(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final aDate = DateTime(time.year, time.month, time.day);

    String displayText = '';

    if (aDate == today) {
      displayText = DateTimeHelper.showTime24H(time);
    } else if (aDate == yesterday) {
      displayText = 'yesterday'.tr;
    } else {
      displayText = DateTimeHelper.showDateAsNumber(aDate.toString());
    }
    return displayText;
  }

  static String timeDurationBetweenDate(DateTime? startDate, DateTime? endDate) {
    if (endDate == null) {
      return '';
    }

    startDate = startDate ?? DateTime.now();
    int seconds = endDate.difference(startDate).inSeconds;

    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    String durationFormat = '';
    if (hours > 0) {
      durationFormat += '$hours${_languageCode == 'zh' ? '小时' : 'h'} ';
    }
    if (minutes > 0) {
      durationFormat += '$minutes${_languageCode == 'zh' ? '分钟' : 'mins'} ';
    }
    if (remainingSeconds > 0) {
      durationFormat += '$remainingSeconds${_languageCode == 'zh' ? '秒' : 's'}';
    }
    return durationFormat;
  }
}

extension DateHelper on DateTime {
  String formatDate() {
    final Moment date = DateTime.parse(toString()).toLocal().toMoment();
    if (compareToFiveMinutes(this)) {
      return date.LT.toString();
    } else {
      return date.LLL.toString();
    }
  }

  bool isSameFiveMinutes(DateTime other) {
    return year == other.year &&
        month == other.month &&
        day == other.day &&
        hour == other.hour &&
        compareToFiveMinutes(other);
  }

  bool isToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final aDate = DateTime(year, month, day);

    if (aDate == today) {
      return true;
    } else {
      return false;
    }
  }

  bool compareDate(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime fifteenMinutesAgo = now.subtract(Duration(hours: day));
    DateTime dateToCompare = dateTime;
    if (dateToCompare.isAfter(fifteenMinutesAgo) && dateToCompare.isBefore(now)) {
      return true;
    } else {
      return false;
    }
  }

  bool compareToFiveMinutes(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
    if (dateTime.isAfter(fiveMinutesAgo) && dateTime.isBefore(now)) {
      return true;
    } else {
      return false;
    }
  }
}
