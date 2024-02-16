import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_color.dart';
import 'method_channel_helper.dart';

mixin MessageVoiceHelper {
  final RecorderController recorderController = RecorderController()
    ..androidEncoder = AndroidEncoder.aac
    ..androidOutputFormat = AndroidOutputFormat.mpeg4
    ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
    ..sampleRate = 44100;
  final PlayerController playController = PlayerController();
  String? path;
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;
  late Directory appDirectory;

  void _getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
    path = '${appDirectory.path}/chatmevoice.m4a';
  }

  void initReconderController() {
    _getDir();
  }

  Widget voiceRecorder(bool isCancelled) {
    return AudioWaveforms(
      enableGesture: true,
      size: Size(Get.width / 2, 10),
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 60, top: 4),
      recorderController: recorderController,
      waveStyle: const WaveStyle(
        waveColor: Colors.white,
        waveThickness: 2,
        extendWaveform: true,
        showMiddleLine: false,
        spacing: 4.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        color: isCancelled ? Colors.red : AppColors.primaryColor,
      ),
    );
  }

  Future<void> startRecording() async {
    try {
      await recorderController.record(path: path!);
    } catch (e) {
      debugPrint(e.toString());
    } finally {}
  }

  Future<String> stopRecording() async {
    final path = await recorderController.stop();
    if (path != null) {
      return path;
    } else {
      return '';
    }
  }

  void addHapticSupportWhenRecordingIOS() {
    if (GetPlatform.isIOS) {
      MethodChannelHelper.getHapticAndVoice();
    }
  }

  void showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            title: const Text('Microphone permission'),
            content: const Text('Microphone permission is required to use this app.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Settings'),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
        return AlertDialog(
          title: const Text('Microphone permission'),
          content: const Text('Microphone permission is required to use this app.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Settings'),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
