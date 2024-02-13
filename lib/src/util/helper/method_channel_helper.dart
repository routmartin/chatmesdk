import 'package:flutter/services.dart';

class MethodChannelHelper {
  static const platform = MethodChannel('chatme.method.channel');

  static Future<void> getHapticAndVoice() async {
    try {
      await platform.invokeMethod('getHapticAndVoice');
    } catch (_) {}
  }

  static Future<void> setAudioSessionActive(bool value) async {
    try {
      await platform.invokeMethod('setAudioSessionActive', value);
    } catch (_) {}
  }

  static Future<dynamic> onRecieveCallDataOnLaunch() async {
    final callData = await platform.invokeMethod('receiveCallData');
    return callData;
  }

  static Future<dynamic> setShowIncommingCallByPushKit(bool isShow) async {
    await platform.invokeMethod('setShowIncommingCallByPushKit', isShow);
  }
}
