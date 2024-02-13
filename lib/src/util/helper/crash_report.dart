// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:http/http.dart' as http;

class CrashReport {
  static Future send(ReportModel reportModel) async {
    // Get.put(AccountUserProfileController());
    // final id = Get.find<AccountUserProfileController>().profile?.id ?? 'n/a';
    // final userName =
    //     Get.find<AccountUserProfileController>().profile?.fullName ?? 'n/a';
    var statusCode = reportModel.statusCode.isEmpty ? 'n/a' : reportModel.statusCode;

    var botToken = '6170160676:AAEGVN2IBGNxnZJ8U503TiXXoxZlf_HobL8';
    var chatId = '@rithcrashreport';

    var message = '''UserName: ChatME User\nid: \nErrorMessage: \n${reportModel.message}\nstatusCode: $statusCode''';

    try {
      final Uri uri = Uri.https(
        'api.telegram.org',
        '/bot$botToken/sendMessage',
        {
          'chat_id': chatId,
          'text': message,
          'parse_mode': 'html',
        },
      );
      return http.get(uri);
    } catch (e) {
      log(e.toString(), name: 'telegram_report_error');
    }
  }
}

class ReportModel {
  String message = '';
  String statusCode = '';
  ReportModel({
    this.message = '',
    this.statusCode = '',
  });
}
