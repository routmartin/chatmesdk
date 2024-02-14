import 'package:chatme/util/constant/app_asset.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ChatSelectMediaSlide extends StatefulWidget {
  const ChatSelectMediaSlide({Key? key, required this.images}) : super(key: key);

  final List images;

  @override
  State<ChatSelectMediaSlide> createState() => _ChatSelectMediaSlideState();
}

class _ChatSelectMediaSlideState extends State<ChatSelectMediaSlide> {
  late PageController _pageController;
  late VideoPlayerController _videoPlayerController;
  bool isPlayerLoad = false;
  int activePage = 0;
  bool isVisiblePause = false;
  final miniMediaWidth = 40.0;
  bool isShowMiniList = true;
  ScrollController scrollMiniMediaController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
    // init controller if first file type is video
    if (widget.images.isNotEmpty && widget.images.first.type == AssetType.video) {
      initVideoController(widget.images.first);
    }
    scrollMiniMediaController.addListener(_listenMiniMediaList);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
            itemCount: widget.images.length,
            controller: _pageController,
            onPageChanged: (pageIndex) async {
              if (isPlayerLoad) {
                await _videoPlayerController.pause();
              }
              if (widget.images[pageIndex].type == AssetType.video) {
                EasyDebounce.debounce(
                  'initVideoDebounce',
                  Duration(milliseconds: 500),
                  () {
                    if (isPlayerLoad) {
                      _videoPlayerController.dispose();
                    }
                    initVideoController(widget.images[pageIndex]);
                  },
                );
              }
              if (scrollMiniMediaController.position.userScrollDirection == ScrollDirection.idle) {
                await scrollMiniMediaController.animateTo(
                  pageIndex * (miniMediaWidth + 4) - 30,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                );
                setState(() {});
              }
            },
            itemBuilder: (context, pagePosition) {
              if (widget.images[pagePosition].type == AssetType.video) {
                return Center(
                  child: isPlayerLoad
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: _videoPlayerController.value.aspectRatio,
                              child: InkWell(onTap: onShowPauseIconVideo, child: VideoPlayer(_videoPlayerController)),
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
                      : CircularProgressIndicator.adaptive(),
                );
              }
              return GestureDetector(
                onTap: () {
                  setState(() {
                    isShowMiniList = !isShowMiniList;
                  });
                },
                child: InteractiveViewer(
                  child: Image(
                    image: ResizeImage(AssetEntityImageProvider(widget.images[pagePosition]),
                        width: (Get.width * 1.5).toInt()),
                    width: Get.width,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            }),
        Positioned(
          bottom: 0,
          child: AnimatedOpacity(
            opacity: isShowMiniList ? 1 : 0,
            duration: Duration(milliseconds: 300),
            child: Visibility(
              visible: isShowMiniList && widget.images.length > 1,
              child: Container(
                height: 80,
                width: Get.width,
                alignment: Alignment.center,
                constraints: BoxConstraints(maxWidth: Get.width),
                padding: EdgeInsets.symmetric(horizontal: Get.width * .3, vertical: 10),
                color: Colors.black12,
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: scrollMiniMediaController,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    var selectedIndex = _pageController.page!.round();
                    AssetEntity entity = widget.images[index];

                    return GestureDetector(
                      onTap: () {
                        _pageController.jumpToPage(index);
                      },
                      child: AnimatedContainer(
                        curve: Curves.easeOutCirc,
                        duration: Duration(milliseconds: 500),
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        width: selectedIndex == index ? miniMediaWidth * 2 : miniMediaWidth,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: entity.type == AssetType.image
                              ? Image(
                                  image: ResizeImage(
                                    AssetEntityImageProvider(
                                      widget.images[index],
                                      isOriginal: false,
                                    ),
                                    width: (miniMediaWidth * 3).toInt(),
                                  ),
                                  fit: BoxFit.cover,
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

  void _listenMiniMediaList() {
    var index = (scrollMiniMediaController.offset / (miniMediaWidth + 4)).ceil();
    index = index < 0 ? 0 : index;
    // move when miniList scroll only
    if (scrollMiniMediaController.position.userScrollDirection == ScrollDirection.forward ||
        scrollMiniMediaController.position.userScrollDirection == ScrollDirection.reverse) {
      if (scrollMiniMediaController.offset >= scrollMiniMediaController.position.maxScrollExtent) {
        _pageController.jumpToPage(widget.images.length - 1);
        setState(() {});
      } else {
        _pageController.jumpToPage(index);
        setState(() {});
      }
    }
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
        isShowMiniList = false;
      });
      Future.delayed(Duration(milliseconds: 1400), () {
        setState(() {
          isVisiblePause = false;
        });
      });
    }
  }

  void initVideoController(AssetEntity assetEntity) async {
    final dataFile = await assetEntity.file;
    _videoPlayerController = VideoPlayerController.file(dataFile!);
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

  @override
  void dispose() {
    super.dispose();
    if (isPlayerLoad) {
      _videoPlayerController.dispose();
    }
  }
}
