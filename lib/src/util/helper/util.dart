import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Util {
  Util._();

  static void checkState(bool isTrue) {
    isTrue = !isTrue;
    isTrue ? Get.updateLocale(const Locale('en')) : Get.updateLocale(const Locale('zh'));
    // setState() {}
  }

  static Color color(Color color) => color;

  static double doubleParse(String size) => double.tryParse(size) ?? 0;

  static Color buttonColor(String hexCode) => Color(int.parse(hexCode));

  static BoxDecoration signUpBorder() =>
      BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black));

  static double fontSize(String size) => double.parse(size);

  /// static function
  ///
  static LinearGradient gradient() => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF5D7AD5),
          Color(0xFF624D9F),
        ],
      );

  static void showWidget({required fairPath, fairArguments, required fairName}) {
    // Navigator.of(AppContext.navigatorKey.currentContext!)
    //     .push(CupertinoPageRoute(builder: (_) {
    //   return FairWidgetPage(
    //     fairArguments: fairArguments,
    //     fairPath: fairPath,
    //     fairName: fairName,
    //   );
    // }));
  }

  static Future<void> launchWebUrl(
    String url, {
    LaunchMode mode = LaunchMode.inAppWebView,
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
    String? webOnlyWindowName,
  }) async {
    if (url.isEmpty) {
      Get.snackbar('Failed to launch URL', 'URL is not valid');
      return;
    }

    if (!url.startsWith('http')) {
      url = 'https://$url';
    }

    if (await canLaunchUrlString(url)) {
      await launchUrlString(
        url,
        mode: mode,
        webViewConfiguration: webViewConfiguration,
        webOnlyWindowName: webOnlyWindowName,
      );
    }
  }

  static bool onCheckIfUrl(String url) {
    RegExp regExp = RegExp(
        r'^(http(s)?:\/\/)?(www.)?([a-zA-Z0-9])+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}(:[0-9]{1,5})?(\/[^\s]*)?$');
    return regExp.hasMatch(url);
  }
}
