import 'dart:async';
import 'dart:math';
import 'package:custom_timer/custom_timer.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../../data/chat_room/chat_room.dart';
import '../../../../data/image_controller.dart';
import '../../../../util/constant/app_assets.dart';
import '../../../../util/constant/app_constant.dart';
import '../../../../util/helper/message_helper.dart';
import '../../../../util/helper/message_upload_helper.dart';
import '../../../../util/helper/message_voice_helper.dart';
import '../../../widget/long_press_wrapper.dart';
import '../../sticker_screen/export.dart';
import '../chat_select_media_screen.dart';
import 'chatroom_footer_section.dart';

class ChatRoomTextField extends StatefulWidget {
  const ChatRoomTextField({Key? key}) : super(key: key);

  @override
  State<ChatRoomTextField> createState() => _ChatRoomTextFieldState();
}

class _ChatRoomTextFieldState extends State<ChatRoomTextField> with TickerProviderStateMixin, MessageVoiceHelper {
  final FocusNode _focus = FocusNode();

  String msgText = '';
  int messageLength = 0;

  final _stickerController = Get.put(StickerController());
  final _imageController = Get.put(ImageController());
  final ChatRoomMessageController _messageController = Get.find();
  late CustomTimerController _timerController;

  late AnimationController _animateController;
  late Animation<double> _animation;

  int _recordTime = 0;

  bool isLongPress = false;
  bool isCancelled = false;
  bool isReleaseHold = false;

  @override
  void initState() {
    initReconderController();
    super.initState();
    _focus.addListener(_onFocusChange);
    _timerController = CustomTimerController(
      vsync: this,
      begin: const Duration(minutes: 0),
      end: const Duration(minutes: 2),
      initialState: CustomTimerState.reset,
      interval: CustomTimerInterval.seconds,
    );

    _animateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _animation = Tween<double>(
      begin: 0,
      end: -0.65,
    ).animate(_animateController);
    _messageController.showFooter = false;
    _stickerController.showEmojiFooter = false;
  }

  @override
  void deactivate() {
    _timerController.dispose();
    _animateController.dispose();
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    isRecording = false;
    stopRecording();
  }

  void _onFocusChange() {
    _messageController.isShowActionIcons = _focus.hasFocus;
    if (_focus.hasFocus) {
      _stickerController.showEmojiFooter = false;
      _stickerController.showPlusFooter = false;
      _messageController.isShowActionIcons = true;
      _messageController.showFooter = false;
    } else {
      if (_stickerController.showEmojiFooter || _stickerController.showPlusFooter) {
        _messageController.showFooter = true;
      } else {
        _messageController.showFooter = false;
      }
      _messageController.isShowActionIcons = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChatVoiceLongPressWrapper(
      isCancelled: isCancelled,
      isLongPress: isLongPress,
      isReleaseHold: isReleaseHold,
      child: Container(
        color: const Color(0xffFBFBFB),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 10),
              constraints: const BoxConstraints(
                minHeight: kBottomNavigationBarHeight - 12,
                maxHeight: 120,
              ),
              color: const Color(0xffFBFBFB),
              child: GetBuilder<ChatRoomMessageController>(builder: (_) {
                return SafeArea(
                  top: false,
                  bottom: _messageController.shouldHaveButtonPadding,
                  child: AnimatedSize(
                    duration: kTabScrollDuration,
                    child: Row(
                      children: [
                        // AnimatedCrossFade(
                        //   layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
                        //     return Stack(
                        //       clipBehavior: Clip.none,
                        //       alignment: Alignment.center,
                        //       children: <Widget>[
                        //         Positioned(key: bottomChildKey, top: 0, child: bottomChild),
                        //         Positioned(key: topChildKey, child: topChild),
                        //       ],
                        //     );
                        //   },
                        //   duration: kThemeChangeDuration,
                        //   crossFadeState: _messageController.isShowActionIcons
                        //       ? CrossFadeState.showFirst
                        //       : CrossFadeState.showSecond,
                        //   firstChild: isRecording
                        //       ? InkWell(
                        //           onTap: _onDeleteVoice,
                        //           child: AnimatedBuilder(
                        //               animation: _animation,
                        //               builder: (context, child) {
                        //                 return Transform.rotate(
                        //                   angle: _animation.value,
                        //                   child: Container(
                        //                     padding: const EdgeInsets.only(
                        //                       left: 20,
                        //                       right: 16,
                        //                       bottom: 10,
                        //                     ),
                        //                     child: Image.asset(
                        //                       "packages/chatmesdk/assets/icons/icon_trash.png",
                        //                       color: Colors.grey,
                        //                       scale: 4,
                        //                     ),
                        //                   ),
                        //                 );
                        //               }),
                        //         )
                        //       : InkWell(
                        //           onTap: _showActionButton,
                        //           child: Container(
                        //             padding: const EdgeInsets.only(
                        //               left: 20,
                        //               right: 16,
                        //               bottom: 10,
                        //             ),
                        //             child: Image.asset(
                        //               "packages/chatmesdk/assets/icons/profile_forward_button.png",
                        //               color: Colors.grey,
                        //               scale: 4,
                        //             ),
                        //           ),
                        //         ),
                        //   secondChild: Padding(
                        //     padding: const EdgeInsets.only(
                        //       left: 16,
                        //       right: 16,
                        //       bottom: 10,
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //       children: [
                        //         GetBuilder<StickerController>(builder: (controller) {
                        //           return InkWell(
                        //             onTap: _onClickPlus,
                        //             child: RotatedBox(
                        //               quarterTurns: 45,
                        //               child: Image.asset(
                        //                 controller.showPlusFooter
                        //                     ? "packages/chatmesdk/assets/icons/icon_close.png"
                        //                     : "packages/chatmesdk/assets/icons/icon_plus.png",
                        //                 width: 23,
                        //               ),
                        //             ),
                        //           );
                        //         }),
                        //         const SizedBox(width: 16),
                        //         InkWell(
                        //           onTap: onClickCamera,
                        //           child: Image.asset(
                        //             "packages/chatmesdk/assets/icons/icon_camera.png",
                        //             width: 23,
                        //           ),
                        //         ),
                        //         const SizedBox(width: 16),
                        //         InkWell(
                        //           onTap: onOpenGallery,
                        //           child: Image.asset("packages/chatmesdk/assets/icons/icon_gallery.png", width: 23),
                        //         ),
                        //         const SizedBox(width: 12),
                        //         GestureDetector(
                        //           onTap: _onStartRecordingVoice,
                        //           onLongPress: () {
                        //             isLongPress = true;
                        //             MessageHelper.longPressVibration();
                        //             _onStartRecordingVoice();
                        //           },
                        //           onLongPressEnd: (details) {
                        //             if (isCancelled) {
                        //               _onDeleteVoice();
                        //             } else if (isReleaseHold) {
                        //             } else {
                        //               _onSentVoiceMessage();
                        //             }
                        //             setState(() {
                        //               isLongPress = false;
                        //               isCancelled = false;
                        //               isReleaseHold = false;
                        //             });
                        //           },
                        //           onLongPressMoveUpdate: (details) {
                        //             // pointer to delete
                        //             if (details.offsetFromOrigin.dx < AppConstants.longPressOnDelete) {
                        //               if (!isCancelled) {
                        //                 _onMoveToDeleteVoice();
                        //               }
                        //               // pointer to lock
                        //             } else if (details.offsetFromOrigin.dx > AppConstants.longPressOnHoldToRelease) {
                        //               _onMoveToLockRecord();
                        //             } else {
                        //               _resetAnimation();
                        //               setState(() {
                        //                 isReleaseHold = false;
                        //                 isCancelled = false;
                        //               });
                        //             }
                        //           },
                        //           child: Image.asset(
                        //             "packages/chatmesdk/assets/icons/icon_reconder.png",
                        //             width: 23,
                        //             color: Colors.grey.shade300,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),

                        const SizedBox(width: 12),
                        Expanded(
                          child: Stack(
                            children: [
                              AnimatedContainer(
                                  duration: kTabScrollDuration,
                                  padding: EdgeInsets.zero,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff505050).withOpacity(.05),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 12,
                                        ),
                                        child: TextField(
                                          focusNode: _focus,
                                          textCapitalization: TextCapitalization.sentences,
                                          keyboardType: TextInputType.multiline,
                                          textInputAction: TextInputAction.newline,
                                          controller: _messageController.msgTextController,
                                          style: const TextStyle(
                                            fontSize: 15.33,
                                            color: Colors.black87,
                                          ),
                                          showCursor: true,
                                          autofocus: false,
                                          maxLines: null,
                                          enabled: true,
                                          cursorColor: AppColors.seconderyColor,
                                          onChanged: (_) {
                                            _validateOnPasteEvent();
                                            if (!_messageController.shouldHaveButtonPadding ||
                                                !_messageController.isShowActionIcons) {
                                              _tapOnTextField();
                                            }
                                          },
                                          onTap: _tapOnTextField,
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.only(right: 22),
                                            isCollapsed: true,
                                            hintText: 'write_a_message'.tr,
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            hintStyle: const TextStyle(
                                              fontSize: 13.33,
                                              color: Color(0xFF9C9C9C),
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Visibility(
                                          visible: isRecording,
                                          child: voiceRecorder(isCancelled),
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 10,
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 2),
                                          child: Visibility(
                                            visible: isRecording,
                                            child: CustomTimer(
                                                controller: _timerController,
                                                builder: (state, time) {
                                                  _recordTime = time.duration.inSeconds;
                                                  if (time.duration.inMinutes == 2 && isRecording) {
                                                    _onSentVoiceMessage();
                                                  }
                                                  return Text(MessageHelper.formatDuration(time.duration.inSeconds),
                                                      style: const TextStyle(
                                                        fontSize: 13.3,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.white,
                                                      ));
                                                }),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                              // Positioned(
                              //   bottom: 0,
                              //   right: 0,
                              //   child: Visibility(
                              //     visible: !isRecording,
                              //     child: Padding(
                              //       padding: const EdgeInsets.symmetric(
                              //         horizontal: 10,
                              //         vertical: 18,
                              //       ),
                              //       child: InkWell(
                              //         onTap: () {
                              //           if (_messageController.showFooter) {
                              //             _focus.requestFocus();
                              //           } else {
                              //             _onClickEmoji(context);
                              //           }
                              //         },
                              //         child: Image.asset(
                              //           _messageController.showFooter
                              //               ? "packages/chatmesdk/assets/icons/icon_keyboard.png"
                              //               : "packages/chatmesdk/assets/icons/insert_emoji.png",
                              //           height: 20,
                              //           color: const Color(0xffCDCDCD),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 400),
                          alignment: Alignment.centerLeft,
                          crossFadeState: isLongPress ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          secondChild: const SizedBox(width: 26),
                          firstChild: Visibility(
                            visible: !isLongPress,
                            child: InkWell(
                              onTap: _onMessageSent,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: const Icon(
                                  Icons.send_rounded,
                                  color: Color(0xff200E32),
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
            ),
            //* sticker footer section
            GetBuilder<StickerController>(builder: (_) {
              return AnimatedSize(
                duration: const Duration(milliseconds: AppConstants.animationDuration200),
                child: _stickerController.showEmojiFooter
                    ? StickerChatTextfieldFooterScreen(
                        onSentSticker: _onSentSticker,
                      )
                    : const Offstage(),
              );
            }),
            //* plus footer section
            GetBuilder<StickerController>(builder: (_) {
              return Container(
                width: Get.width,
                color: AppColors.txtSeconddaryColor,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: AppConstants.animationDuration200),
                  curve: Curves.ease,
                  child: _stickerController.showPlusFooter
                      ? const ChatroomFooterSection(isGroup: false)
                      : const SizedBox(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _onSentSticker(String stickerId) {
    _messageController.onSentSticker(stickerId);
  }

  void _onMessageSent() async {
    if (isRecording) {
      await _onSentVoiceMessage();
    } else if (_messageController.msgTextController.text.trim().isNotEmpty) {
      var message = _messageController.msgTextController.text.trim();
      _messageController.onSentMessage(message);
    }
  }

  void onClickCamera() async {
    AssetEntity? selectFile = await Get.find<ImageController>().takeCamera();
    if (selectFile != null) {
      Get.find<ChatRoomMessageController>().selectFiles = [selectFile];
      await Get.to(() => const ChatSelectMediaScreen());
    }
  }

  void onOpenGallery() async {
    List<AssetEntity>? selectFiles = await Get.find<ImageController>().openMedia(maxLength: 30);
    if (selectFiles != null && selectFiles.isNotEmpty) {
      _messageController.selectFiles = selectFiles;
      await Get.to(() => const ChatSelectMediaScreen());
    }
  }

  void _onClickPlus() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _messageController.showFooter = !_messageController.showFooter;
      _stickerController.showPlusFooter = !_stickerController.showPlusFooter;
      _messageController.shouldHaveButtonPadding = !_stickerController.showPlusFooter;
      _stickerController.showEmojiFooter = false;
    });
  }

  void _onClickEmoji(BuildContext ctx) async {
    FocusManager.instance.primaryFocus?.unfocus();
    int delayTime = 0;
    if (MediaQuery.of(ctx).viewInsets.bottom > 0.0) {
      delayTime = AppConstants.animationDuration200;
    }
    Future.delayed(Duration(milliseconds: delayTime), () {
      _messageController.shouldHaveButtonPadding = false;
      _stickerController.showPlusFooter = false;
      _messageController.showFooter = true;
      _stickerController.showEmojiFooter = true;
      setState(() {});
    });
  }

  void _showActionButton() {
    if (_messageController.isShowActionIcons) {
      _messageController.isShowActionIcons = false;
      setState(() {});
    }
  }

  void _validateOnPasteEvent() {
    var count = _messageController.msgTextController.text.length - messageLength;
    if (count > 1) {
      if (_messageController.msgTextController.text.length > 2000) {
        _messageController.msgTextController.clear();
      }
    } else if (_messageController.msgTextController.text.length > 2000) {
      _messageController.msgTextController.text =
          _messageController.msgTextController.text.substring(_messageController.msgTextController.text.length - 1);
    } else {
      messageLength = _messageController.msgTextController.text.length;
    }
    _messageController.onTypingEvent();
  }

  void _tapOnTextField() {
    setState(() {
      _messageController.shouldHaveButtonPadding = true;
      _messageController.isShowActionIcons = true;
    });
  }

  Future<void> _onStartRecordingVoice() async {
    PermissionStatus status = await Permission.microphone.status;

    if (status.isGranted) {
      isRecording = true;
      _animateController.reset();
      _messageController.shouldHaveButtonPadding = true;
      _messageController.isShowActionIcons = true;
      setState(() {});
      await startRecording().then((_) {
        _timerController.start();
        _messageController.emitRecondingOnEvent();
        addHapticSupportWhenRecordingIOS();
      });
    } else if (status.isPermanentlyDenied) {
      showPermissionPermanentlyDeniedDialog();
    } else {
      await Permission.microphone.request().then((_) {
        initReconderController();
        _onStartRecordingVoice();
      });
    }
  }

  Future<void> _onSentVoiceMessage() async {
    if (_recordTime < 1) return;
    await stopRecording().then((path) async {
      _resetVoiceUI();
      _messageController.emitRecondingOffEvent();
      final tempId = 'uploading${Random().nextInt(1000000000)}';
      var controller = Get.find<ChatRoomMessageController>();
      var uploadMessage = MessageUploadHelper().messageVoiceUploadModel(
        tempId,
        path,
        false,
        controller.roomId,
        controller.replyMessage,
      );
      controller.listMessage.add(uploadMessage);
      controller.isOnReplying = false;
      controller.update();
      String extension = path.split('.').last;
      var attachmentId = await _imageController.uploadAttachment(
        path,
        MediaType('voice', extension),
      );
      if (attachmentId != null) {
        _messageController.onSentVoiceMessage(attachmentId);
      }
      controller.listMessage.removeWhere((message) => message.id == tempId);
      controller.update();
    });
  }

  Future<void> _onDeleteVoice() async {
    if (isRecording) {
      _messageController.emitRecondingOffEvent();
      await stopRecording().then((_) {
        _resetVoiceUI();
      });
      _resetAnimation();
    }
  }

  void _resetVoiceUI() {
    _timerController.reset();
    isRecording = false;
    _messageController.isShowActionIcons = false;
    setState(() {});
  }

  void _onMoveToDeleteVoice() async {
    isCancelled = true;
    if (GetPlatform.isIOS) {
      await HapticFeedback.mediumImpact();
    } else {
      await Vibration.vibrate(duration: 50, amplitude: 128);
    }
    await _animateController.forward();
    setState(() {});
  }

  void _onMoveToLockRecord() {
    if (!isReleaseHold) {
      isReleaseHold = true;
      setState(() {});
    }
  }

  void _resetAnimation() {
    _animateController.reset();
  }
}
