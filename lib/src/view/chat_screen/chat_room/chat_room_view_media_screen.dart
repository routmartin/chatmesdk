// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:mno_zoom_widget/zoom_widget.dart';
import 'package:video_player/video_player.dart';

import '../../../data/chat_room/chat_room.dart';
import '../../../data/chat_room/model/attachment_model.dart';
import '../../../data/chat_room/model/message_response_model.dart';
import '../../../data/image_controller.dart';
import '../../../util/constant/app_assets.dart';
import '../../../util/helper/media_helper.dart';
import '../../../util/helper/message_helper.dart';
import '../../../util/theme/app_color.dart';
import '../../widget/base_share_widget.dart';

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

  bool _checkIfMediaImage(AttachmentModel model) {
    var url = model.url ?? '';
    var isImageByMimeType = model.mimeType?.startsWith('image/') ?? false;
    return url.isImageFileName || isImageByMimeType;
  }

  String _checkSaveMediaType() {
    return isMediaIsImage ? 'save_photo' : 'save_video';
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
                duration: const Duration(milliseconds: 250),
                child: const ColoredBox(
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
                    duration: const Duration(milliseconds: 250),
                    child: SizedBox(
                      height: kToolbarHeight,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: Get.back,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Image.asset(
                                Assets.app_assetsIconsSearchBackButton,
                                color: Colors.white,
                                height: 16,
                                width: 16,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 45,
                            child: PopupMenuButton<MenuOptionItem>(
                              elevation: 1,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4.0),
                                ),
                              ),
                              position: PopupMenuPosition.under,
                              offset: const Offset(-20, 0),
                              icon: const Icon(Icons.more_vert, color: Colors.white),
                              constraints: const BoxConstraints(maxWidth: 200),
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptionItem>>[
                                PopupMenuItem<MenuOptionItem>(
                                  height: 0,
                                  padding: EdgeInsets.zero,
                                  onTap: () {
                                    //  saveImageToGallary(_urlPath)
                                  },
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
                            var attachment = controller.selectFiles![indexPage];

                            setState(() {
                              currentIndex = indexPage;
                            });
                            if (!_checkIfMediaImage(attachment)) {
                              EasyDebounce.debounce(
                                'initVideoDebounce',
                                const Duration(milliseconds: 300),
                                () {
                                  if (isPlayerLoad) {
                                    _videoPlayerController.dispose();
                                  }
                                  initVideoController(attachment.url ?? '');
                                },
                              );
                            } else {
                              // await scanQrFromImage(_attachment.url ?? '');
                            }
                            if (scrollMiniMediaController.position.userScrollDirection == ScrollDirection.idle) {
                              await scrollMiniMediaController.animateTo(
                                indexPage * (miniMediaWidth + 4) - 30,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.fastOutSlowIn,
                              );
                            }
                          },
                          itemBuilder: (context, pagePosition) {
                            var attachment = controller.selectFiles![pagePosition];
                            _urlPath = attachment.url!;
                            isMediaIsImage = _checkIfMediaImage(attachment);
                            if (!isMediaIsImage) {
                              return Dismissible(
                                key: const Key('swipe_down'),
                                direction: DismissDirection.vertical,
                                onDismissed: (_) {
                                  Get.back();
                                },
                                movementDuration: const Duration(milliseconds: 10),
                                dismissThresholds: const {
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
                                                duration: const Duration(milliseconds: 400),
                                                firstChild: AnimatedOpacity(
                                                  opacity: isVisiblePause ? 1 : 0,
                                                  duration: const Duration(milliseconds: 500),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: const BoxDecoration(
                                                      color: Colors.white70,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.pause,
                                                      color: AppColors.primaryColor,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ),
                                                secondChild: Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.white70,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
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
                                    : const Center(
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
                                key: const Key('swipe_down'),
                                direction: DismissDirection.vertical,
                                onDismissed: (_) {
                                  Get.back();
                                },
                                movementDuration: const Duration(milliseconds: 10),
                                dismissThresholds: const {
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
                                    child: Transform.scale(scale: 4, child: const CircularProgressIndicator.adaptive()),
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
                  duration: const Duration(milliseconds: 300),
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
                              duration: const Duration(milliseconds: 500),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
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
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.white70,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
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
      await Future.delayed(const Duration(milliseconds: 1400), () {
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
    bool isFromSearch = Get.find<ChatRoomViewMediaController>().isFromSearch;
    var message = Get.find<ChatRoomViewMediaController>().messageItem;
    Get.close(isFromSearch ? 2 : 1);
    dynamic controller = Get.find<ChatRoomMessageController>();
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
            _videoPlayerController.seekTo(const Duration(milliseconds: 0));
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
      Future.delayed(const Duration(milliseconds: 1400), () {
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
                  style: const TextStyle(fontSize: 15),
                )
              ],
            ),
          ),
          if (type != 'last')
            Divider(
              color: const Color(0xFF3C3C43).withOpacity(.8),
              height: 1,
            )
        ],
      );

  // Future saveImageToGallary(String mediaUrl) async {
  //   bool isSuccess = false;
  //   if (isMediaIsImage) {
  //     isSuccess = await ImageController().saveImageToGalleryWithCheckPermission(mediaUrl);
  //   } else {
  //     isSuccess = await ImageController().saveVideoToGalleryWithCheckPermission(mediaUrl);
  //   }
  //   return isSuccess;
  // }
}

enum MenuOptionItem { mute, report, delete }
