// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatme/data/add_friend/controller/add_friend_by_search_controller.dart';
import 'package:chatme/data/chat_room/chat_room_message_controller.dart';
import 'package:chatme/data/chat_room/chat_room_view_media_controller.dart';
import 'package:chatme/data/chat_room/model/attachment_model.dart';
import 'package:chatme/data/chat_room/model/message_response_model.dart';
import 'package:chatme/data/group_room/group_message_controller.dart';
import 'package:chatme/data/image_controller/image_controller.dart';
import 'package:chatme/data/qr_controller/qr_controller.dart';
import 'package:chatme/template/add_friend/friend_profile_pre_add/friend_profile_pre_add.dart';
import 'package:chatme/template/chat_screen/chat_room/chat_room_share_media_screen.dart';
import 'package:chatme/template/group/group_setting/setting_group_qr_code/setting_group_qr_code_group_info/setting_group_qr_code_group_info.dart';
import 'package:chatme/util/constant/app_asset.dart';
import 'package:chatme/util/helper/media_helper.dart';
import 'package:chatme/util/helper/message_helper.dart';
import 'package:chatme/widgets/cupertino/icon_dialog.dart';
import 'package:chatme/widgets/loading/base_dialog_loading.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:mno_zoom_widget/zoom_widget.dart';
import 'package:scan/scan.dart';
import 'package:video_player/video_player.dart';

class ChatRoomViewMediaScreen extends StatefulWidget {
  const ChatRoomViewMediaScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ChatRoomViewMediaScreen> createState() => _ChatRoomViewMediaScreenState();
}

class _ChatRoomViewMediaScreenState extends State<ChatRoomViewMediaScreen> {
  late VideoPlayerController _videoPlayerController;
  bool isPlayerLoad = false;
  String qrcode = 'Unknown';
  int currentIndex = 0;
  double screenOpacity = 1;
  bool isVisiblePause = false;
  final miniMediaWidth = 40.0;
  bool isShowMiniList = true;

  var _urlPath = '';
  var isMediaIsImage = true;
  ScrollController scrollMiniMediaController = ScrollController();

  bool _checkIfMediaImage(AttachmentModel _model) {
    var _url = _model.url ?? '';
    var isImageByMimeType = _model.mimeType?.startsWith('image/') ?? false;
    return _url.isImageFileName || isImageByMimeType;
  }

  String _checkSaveMediaType() {
    return isMediaIsImage ? 'save_photo' : 'save_video';
  }

  String _checkShareMediaType() {
    return isMediaIsImage ? 'share_photo' : 'share_video';
  }

  bool _checkShowScanQRButton(AttachmentModel file) {
    bool _showButton = false;
    if (file.hasQrcode ?? false) {
      _showButton = true;
    } else {
// TODO: scan when swipe image
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      // ImageController().downloadImage(file.url ?? '').then((file) {
      //   Scan.parse(file!.path).then((result) {
      //     if (result?.contains('/p/') ?? result?.contains('/g/') ?? false) {
      //       _showButton = true;
      //       // setState(() {});
      //     }
      //   });
      // });
    }
    return _showButton;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // init controller if first file type is video
      var controller = Get.find<ChatRoomViewMediaController>();

      AttachmentModel attachment = controller.selectFiles![controller.selectIndex];
      if (!_checkIfMediaImage(attachment)) {
        initVideoController(attachment.url ?? '');
      }
      scrollMiniMediaController.addListener(_listenMiniMediaList);
      scrollMiniMediaController.jumpTo(controller.selectIndex * (miniMediaWidth + 4) - 30);
    });
  }

  @override
  void dispose() {
    if (isPlayerLoad) {
      _videoPlayerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatRoomViewMediaController>(
        init: ChatRoomViewMediaController(),
        builder: (controller) {
          return Stack(
            children: [
              Positioned.fill(
                  child: AnimatedOpacity(
                opacity: screenOpacity,
                duration: Duration(milliseconds: 250),
                child: ColoredBox(
                  color: AppColors.seconderyColor,
                ),
              )),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  titleSpacing: 0,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: AnimatedOpacity(
                    opacity: screenOpacity < 1 ? 0 : 1,
                    duration: Duration(milliseconds: 250),
                    child: SizedBox(
                      height: kToolbarHeight,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: Get.back,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Image.asset(
                                Assets.app_assetsIconsSearchBackButton,
                                color: Colors.white,
                                height: 16,
                                width: 16,
                              ),
                            ),
                          ),
                          Spacer(),
                          _checkShowScanQRButton(controller.selectFiles![currentIndex])
                              ? SizedBox(
                                  width: 20,
                                  child: InkWell(
                                    onTap: () async {
                                      await scanQrFromImage(controller.selectFiles![currentIndex].url ?? '');
                                    },
                                    child: Image.asset(
                                      Assets.app_assetsIconsIconBarcode,
                                    ),
                                  ),
                                )
                              : Offstage(),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 45,
                            child: PopupMenuButton<MenuOptionItem>(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4.0),
                                ),
                              ),
                              position: PopupMenuPosition.under,
                              offset: Offset(-20, 0),
                              icon: Icon(Icons.more_vert, color: Colors.white),
                              constraints: BoxConstraints(maxWidth: 200),
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptionItem>>[
                                PopupMenuItem<MenuOptionItem>(
                                  height: 0,
                                  padding: EdgeInsets.zero,
                                  onTap: () => saveImageToGallary(_urlPath),
                                  value: MenuOptionItem.mute,
                                  child:
                                      popMenuItem(Assets.app_assetsIconsCicleDownload, _checkSaveMediaType(), 'first'),
                                ),
                                PopupMenuItem<MenuOptionItem>(
                                  height: 0,
                                  onTap: _onViewInChat,
                                  value: MenuOptionItem.report,
                                  padding: EdgeInsets.zero,
                                  child: popMenuItem(Assets.app_assetsIconsCicleBack, 'view_in_chat', 'middle'),
                                ),
                                PopupMenuItem<MenuOptionItem>(
                                  height: 0,
                                  onTap: _onShareImage,
                                  value: MenuOptionItem.delete,
                                  padding: EdgeInsets.zero,
                                  child: popMenuItem(Assets.app_assetsIconsCicleShare, _checkShareMediaType(), 'last'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: PageView.builder(
                          itemCount: controller.selectFiles!.length,
                          controller: controller.pageController,
                          onPageChanged: (indexPage) async {
                            if (isPlayerLoad) {
                              await _videoPlayerController.pause();
                            }
                            var _attachment = controller.selectFiles![indexPage];

                            setState(() {
                              currentIndex = indexPage;
                            });
                            if (!_checkIfMediaImage(_attachment)) {
                              EasyDebounce.debounce(
                                'initVideoDebounce',
                                Duration(milliseconds: 300),
                                () {
                                  if (isPlayerLoad) {
                                    _videoPlayerController.dispose();
                                  }
                                  initVideoController(_attachment.url ?? '');
                                  ;
                                },
                              );
                            } else {
                              // await scanQrFromImage(_attachment.url ?? '');
                            }
                            if (scrollMiniMediaController.position.userScrollDirection == ScrollDirection.idle) {
                              await scrollMiniMediaController.animateTo(
                                indexPage * (miniMediaWidth + 4) - 30,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.fastOutSlowIn,
                              );
                            }
                          },
                          itemBuilder: (context, pagePosition) {
                            var _attachment = controller.selectFiles![pagePosition];
                            _urlPath = _attachment.url!;
                            isMediaIsImage = _checkIfMediaImage(_attachment);
                            if (!isMediaIsImage) {
                              return Dismissible(
                                key: Key('swipe_down'),
                                direction: DismissDirection.vertical,
                                onDismissed: (_) {
                                  Get.back();
                                },
                                movementDuration: Duration(milliseconds: 10),
                                dismissThresholds: {
                                  DismissDirection.endToStart: 0.4,
                                },
                                onUpdate: (details) {
                                  setState(() {
                                    screenOpacity = 1 - details.progress;
                                  });
                                },
                                child: isPlayerLoad
                                    ? Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          AspectRatio(
                                            aspectRatio: _videoPlayerController.value.aspectRatio,
                                            child: InkWell(
                                              onTap: onShowPauseIconVideo,
                                              child: VideoPlayer(
                                                _videoPlayerController,
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: InkWell(
                                              onTap: onPlayVideo,
                                              child: AnimatedCrossFade(
                                                crossFadeState: _videoPlayerController.value.isPlaying
                                                    ? CrossFadeState.showFirst
                                                    : CrossFadeState.showSecond,
                                                duration: Duration(milliseconds: 400),
                                                firstChild: AnimatedOpacity(
                                                  opacity: isVisiblePause ? 1 : 0,
                                                  duration: Duration(milliseconds: 500),
                                                  child: Container(
                                                    padding: EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white70,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.pause,
                                                      color: AppColors.primaryColor,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ),
                                                secondChild: Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white70,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.play_arrow,
                                                    color: AppColors.primaryColor,
                                                    size: 40,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Center(
                                        child: FittedBox(
                                          child: CircularProgressIndicator.adaptive(
                                            backgroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                              );
                            }
                            return Zoom(
                              maxZoomWidth: 1000 * 2.5,
                              maxZoomHeight: 1700 * 2.5,
                              opacityScrollBars: 0,
                              centerOnScale: true,
                              enableScroll: true,
                              doubleTapZoom: true,
                              zoomSensibility: 10,
                              backgroundColor: Colors.transparent,
                              canvasColor: Colors.transparent,
                              initZoom: 0,
                              onTap: () {
                                setState(() {
                                  isShowMiniList = !isShowMiniList;
                                });
                              },
                              child: Dismissible(
                                key: Key('swipe_down'),
                                direction: DismissDirection.vertical,
                                onDismissed: (_) {
                                  Get.back();
                                },
                                movementDuration: Duration(milliseconds: 10),
                                dismissThresholds: {
                                  DismissDirection.endToStart: 0.4,
                                },
                                onUpdate: (details) {
                                  setState(() {
                                    screenOpacity = 1 - details.progress;
                                  });
                                  // if (details.progress != 0) {
                                  //   setState(() {
                                  //     screenOpacity = 0;
                                  //   });
                                  // } else {
                                  //   setState(() {
                                  //     screenOpacity = 1;
                                  //   });
                                  // }
                                },
                                child: CachedNetworkImage(
                                  imageUrl: controller.selectFiles![pagePosition].url!,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => Center(
                                    child: Transform.scale(scale: 4, child: CircularProgressIndicator.adaptive()),
                                  ),
                                  errorWidget: (context, url, error) => Image.asset(
                                    Assets.app_assetsIconsMyPofileAvatar,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 80,
                child: AnimatedOpacity(
                  opacity: isShowMiniList ? 1 : 0,
                  duration: Duration(milliseconds: 300),
                  child: Visibility(
                    visible: isShowMiniList && controller.selectFiles!.length > 1 && screenOpacity == 1,
                    child: Container(
                      height: 80,
                      width: Get.width,
                      alignment: Alignment.center,
                      constraints: BoxConstraints(maxWidth: Get.width),
                      padding: EdgeInsets.symmetric(horizontal: Get.width * .3, vertical: 10),
                      color: Colors.black12,
                      child: ListView.builder(
                        addAutomaticKeepAlives: true,
                        controller: scrollMiniMediaController,
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.selectFiles!.length,
                        itemBuilder: (context, index) {
                          var selectedIndex = controller.pageController.page!.round();
                          return GestureDetector(
                            onTap: () {
                              controller.pageController.jumpToPage(index);
                            },
                            child: AnimatedContainer(
                              curve: Curves.easeOutCirc,
                              duration: Duration(milliseconds: 500),
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              width: selectedIndex == index ? miniMediaWidth * 2 : miniMediaWidth,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _checkIfMediaImage(controller.selectFiles![index])
                                    ? CachedNetworkImage(
                                        imageUrl: controller.selectFiles![index].url!,
                                        memCacheWidth: 150,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) => MediaHelper.brokenfile(scale: 15),
                                      )
                                    : ColoredBox(
                                        // color: Color(0xFFE4E6EB),
                                        color: Colors.black,
                                        child: Center(
                                            child: Container(
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.white70,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.play_arrow,
                                            color: AppColors.primaryColor,
                                            size: 20,
                                          ),
                                        )),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }

  void _listenMiniMediaList() {
    var controller = Get.find<ChatRoomViewMediaController>();
    var index = (scrollMiniMediaController.offset / (miniMediaWidth + 4)).ceil();
    index = index < 0 ? 0 : index;
    // move when miniList scroll only
    if (scrollMiniMediaController.position.userScrollDirection == ScrollDirection.forward ||
        scrollMiniMediaController.position.userScrollDirection == ScrollDirection.reverse) {
      if (scrollMiniMediaController.offset >= scrollMiniMediaController.position.maxScrollExtent) {
        controller.pageController.jumpToPage(controller.selectFiles!.length - 1);
      } else {
        controller.pageController.jumpToPage(index);
      }
    }
  }

  void onShowPauseIconVideo() async {
    if (!isVisiblePause) {
      setState(() {
        isVisiblePause = true;
        isShowMiniList = true;
      });
      await Future.delayed(Duration(milliseconds: 1400), () {
        setState(() {
          isVisiblePause = false;
          isShowMiniList = false;
        });
      });
    } else {
      setState(() {
        isVisiblePause = false;
        isShowMiniList = false;
      });
    }
  }

  void _onViewInChat() async {
    bool isGroup = Get.find<ChatRoomViewMediaController>().isGroup;
    bool isFromSearch = Get.find<ChatRoomViewMediaController>().isFromSearch;
    var message = Get.find<ChatRoomViewMediaController>().messageItem;
    Get.close(isFromSearch ? 2 : 1);
    dynamic controller = isGroup ? Get.find<GroupMessageController>() : Get.find<ChatRoomMessageController>();
    List<MessageModel> reversedList = List.from(controller.listMessage.reversed);
    controller.indexMessageForScroll = reversedList.indexWhere((element) => element.id == message.id);
    controller.update();
    // found in list
    if (controller.indexMessageForScroll != -1) {
      await MessageHelper.onScrollToMessageIndex(controller, message.id!, isAnimatedPin: false, isJumpTo: true);
    } else {
      BaseDialogLoading.show();
      controller.rootMessageDate = message.createdAt!.toIso8601String();
      controller.update();
      String? messageId = await controller.getMessagesBetweenDate();
      if (messageId != null) {
        await MessageHelper.onScrollToMessageIndex(controller, messageId, isAnimatedPin: false, isJumpTo: true);
      }
      BaseDialogLoading.dismiss();
    }
  }

  void initVideoController(String urlPath) async {
    _videoPlayerController = VideoPlayerController.network(urlPath);
    onPlayVideo();
    await _videoPlayerController.initialize().then((_) {
      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.position == _videoPlayerController.value.duration) {
          setState(() {
            _videoPlayerController.pause();
            _videoPlayerController.seekTo(Duration(milliseconds: 0));
            isVisiblePause = true;
            isShowMiniList = true;
          });
        }
      });
      setState(() {
        isPlayerLoad = true;
      });
    });
  }

  void onPlayVideo() {
    if (_videoPlayerController.value.isPlaying) {
      setState(() {
        _videoPlayerController.pause();
        isVisiblePause = true;
      });
    } else {
      setState(() {
        _videoPlayerController.play();
      });
      Future.delayed(Duration(milliseconds: 1400), () {
        setState(() {
          isVisiblePause = false;
        });
      });
    }
  }

  Widget popMenuItem(String icon, String text, String type) => Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, type == 'first' ? 8 : 11, 16, type == 'last' ? 8 : 11),
            child: Row(
              children: [
                Image.asset(icon, height: 20, width: 20),
                const SizedBox(width: 8),
                Text(
                  text.tr,
                  style: TextStyle(fontSize: 15),
                )
              ],
            ),
          ),
          if (type != 'last')
            Divider(
              color: Color(0xFF3C3C43).withOpacity(.8),
              height: 1,
            )
        ],
      );

  Future<bool> scanQrFromImage(String url) async {
    File? file = await ImageController().downloadImage(url);
    var result = await Scan.parse(file?.path ?? '');

    if (result?.contains('/p/') ?? false) {
      Get.put(QRController());
      Get.find<QRController>().qrCodeValue = result ?? '';
      Get.put(AddFriendBySearchController());
      await Get.to(() => FriendProfilePreAdd());
    } else if (result?.contains('/g/') ?? false) {
      String? qrLink = result;
      await Get.to(() => SettingGroupQrCodeGroupInfo(qrLink: qrLink));
    }
    return true;
  }

  void _onShareImage() async {
    var imageId = Get.find<ChatRoomViewMediaController>().selectFiles![currentIndex].id!;
    await Future.delayed(const Duration(milliseconds: 10));
    await Get.to(() => ChatroomShareMediaScreen(), arguments: imageId);
  }

  Future saveImageToGallary(String mediaUrl) async {
    bool isSuccess = false;
    if (isMediaIsImage) {
      isSuccess = await ImageController().saveImageToGalleryWithCheckPermission(mediaUrl);
    } else {
      isSuccess = await ImageController().saveVideoToGalleryWithCheckPermission(mediaUrl);
    }
    if (isSuccess) {
      _showSaveMediaSavedDialog();
    }
  }

  void _showSaveMediaSavedDialog() async {
    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          Future.delayed(Duration(milliseconds: 1000), () {
            Navigator.of(context).pop();
          });
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: CupertinoDialogIcon(text: 'saved'.tr),
            ),
          );
        });
  }
}

enum MenuOptionItem { mute, report, delete }
