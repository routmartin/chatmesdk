import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

import '../../../../data/chat_room/chat_room.dart';
import '../../../../util/helper/cache_mananger_helper.dart';
import '../../../../util/helper/message_helper.dart';
import '../../../../util/theme/app_color.dart';

class VoiceChatWidget extends StatefulWidget {
  final bool isSender;
  final String path;
  final String? uploadPath;

  const VoiceChatWidget({
    Key? key,
    this.isSender = false,
    required this.path,
    this.uploadPath,
  }) : super(key: key);

  @override
  State<VoiceChatWidget> createState() => _VoiceChatWidgetState();
}

class _VoiceChatWidgetState extends State<VoiceChatWidget> with AutomaticKeepAliveClientMixin {
  late PlayerController _playController;
  late StreamSubscription<PlayerState> playerStateSubscription;

  Timer? _timer;

  bool _isBeingLoading = true;
  String _voiceDuration = '';
  int _totalVoiceDurationInSeconds = 0;
  int _totalRemainTime = 0;

  List<double> _listWaveForm = [];

  final _width = Get.width * .4;

  final senderPlayerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Colors.white,
    spacing: 4,
    waveThickness: 2,
  );

  final otherPlayerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Color(0xFFACACAC),
    liveWaveColor: Color(0xFF787878),
    spacing: 4.0,
    waveThickness: 2,
  );

  @override
  void initState() {
    super.initState();
    _playController = PlayerController();
    _getPlayerReady();
    playerStateSubscription = _playController.onPlayerStateChanged.listen((playState) {
      if (mounted && playState == PlayerState.playing) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _rebuildTotalLeaveDuration();
        });
      } else {
        _timer?.cancel();
      }
      setState(() {});
    });
    _playController.onCurrentDurationChanged.listen((currentDuration) {
      _getCurrentDuration(currentDuration);
    });
    _playController.onCompletion.listen((_) async {
      _voiceDuration = MessageHelper.formatDuration(_totalVoiceDurationInSeconds);
      final session = await AudioSession.instance;
      await session.setActive(false);
      setState(() {});
    });

    _playController.onExtractionProgress.listen((progress) {
      if (progress == 1) {
        if (mounted) {
          setState(() {
            _isBeingLoading = false;
          });
        }
      }
    });
  }

  Future<void> _getPlayerReady() async {
    _playController.updateFrequency = UpdateFrequency.low;
    if (widget.uploadPath != null) {
      _preparePlayer(widget.uploadPath ?? '');
      return;
    }
    var cacheFile = await CacheManagerHelper.instance.getFileFromCache(widget.path);
    if (cacheFile != null) {
      _preparePlayer(cacheFile.file.path);
    } else {
      CacheManagerHelper.downloadFileToCacheManager(
        dio.CancelToken(),
        widget.path,
        onDownloadChange: (percentage) async {
          if (percentage == 100) {
            await Future.delayed(const Duration(milliseconds: 300));
            var downloadFile = await CacheManagerHelper.instance.getFileFromCache(widget.path);
            if (mounted) {
              _preparePlayer(downloadFile?.file.path ?? '');
            }
          }
        },
      );
    }
  }

  void _preparePlayer(String path) async {
    await _playController.preparePlayer(
      path: path,
      shouldExtractWaveform: true,
    );
    _listWaveForm = await _playController.extractWaveformData(
      path: path,
      noOfSamples: widget.isSender
          ? senderPlayerWaveStyle.getSamplesForWidth(_width)
          : otherPlayerWaveStyle.getSamplesForWidth(_width),
    );
    if (mounted) {
      setState(() {
        _isBeingLoading = false;
      });
    }
    await _getVoiceTotalDuration();
  }

  static Future<void> _setAudioSessionOn() async {
    final session = await AudioSession.instance;
    try {
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      ));
      await session.setActive(true);
    } catch (e) {
      print('setAudioSession catch: $e');
    }
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    _playController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedSize(
      alignment: widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.isSender ? AppColors.primaryColor : const Color(0xFFE4E6EB),
        ),
        child: _isBeingLoading
            ? Container(
                width: _width,
                alignment: Alignment.center,
                height: 55,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Text(
                  '<<< ${'voice'.tr} >>>',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.11,
                    fontWeight: FontWeight.w500,
                    color: widget.isSender ? Colors.white : const Color(0xff343434),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_playController.playerState.isStopped)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      child: widget.uploadPath == null
                          ? InkWell(
                              onTap: _onPlayPauseButton,
                              child: Icon(
                                _playController.playerState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                size: 30,
                                color: widget.isSender ? Colors.white : const Color(0xFF787878),
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )),
                            ),
                    ),
                  AudioFileWaveforms(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    size: Size(_width, 40),
                    playerController: _playController,
                    waveformType: WaveformType.fitWidth,
                    waveformData: _listWaveForm,
                    playerWaveStyle: widget.isSender ? senderPlayerWaveStyle : otherPlayerWaveStyle,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 45,
                    alignment: Alignment.center,
                    child: Text(
                      _voiceDuration,
                      style: TextStyle(
                        color: widget.isSender ? Colors.white : const Color(0xFF787878),
                        fontWeight: FontWeight.w500,
                        fontSize: 14.33,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _onPlayPauseButton() async {
    if (_playController.playerState.isPlaying) {
      await _playController.pausePlayer();
    } else {
      await _setAudioSessionOn();
      await _playController.startPlayer(finishMode: FinishMode.pause);
      dynamic controller = Get.find<ChatRoomMessageController>();
      controller.selectedAudioMessageKey = _playController.playerKey;
      controller.update();
    }
  }

  Future<void> _getVoiceTotalDuration() async {
    var durationInMilliseconds = await _playController.getDuration(DurationType.max);
    Duration duration = Duration(milliseconds: durationInMilliseconds);
    _totalVoiceDurationInSeconds = duration.inSeconds;
    if (mounted) {
      setState(() {
        _voiceDuration = MessageHelper.formatDuration(_totalVoiceDurationInSeconds);
      });
    }
  }

  Future<void> _getCurrentDuration(int currentDuration) async {
    Duration duration = Duration(milliseconds: currentDuration);
    var totalCurrentTime = duration.inSeconds;
    _totalRemainTime = _totalVoiceDurationInSeconds - totalCurrentTime;
    _rebuildTotalLeaveDuration();

    dynamic controller = Get.find<ChatRoomMessageController>();
    if (controller.selectedAudioMessageKey != _playController.playerKey) {
      await _onPlayPauseButton();
    }
  }

  void _rebuildTotalLeaveDuration() {
    if (mounted) {
      _voiceDuration = MessageHelper.formatDuration(_totalRemainTime);
      setState(() {});
    }
  }

  @override
  bool get wantKeepAlive => true;
}
