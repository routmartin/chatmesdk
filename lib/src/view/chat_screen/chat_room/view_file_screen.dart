import 'dart:async';
import 'dart:io';

import 'package:chatme/data/image_controller/image_controller.dart';
import 'package:chatme/data/share_contact/share_contact_controller.dart';
import 'package:chatme/routes/app_routes.dart';
import 'package:chatme/util/helper/cache_mananger_helper.dart';
import 'package:chatme/util/text_style.dart';
import 'package:chatme/util/theme/app_color.dart';
import 'package:chatme/widgets/cupertino/icon_dialog.dart';
import 'package:chatme/widgets/loading/base_dialog_loading.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:mno_zoom_widget/zoom_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart' as dio;

class ViewFileScreen extends StatefulWidget {
  final String fileType;
  final String fileSize;
  final String fileName;
  final String fileUrl;
  final String fileId;

  const ViewFileScreen(
      {Key? key,
      required this.fileType,
      required this.fileSize,
      required this.fileName,
      required this.fileUrl,
      required this.fileId})
      : super(key: key);

  @override
  State<ViewFileScreen> createState() => _ViewFileScreenState();
}

class _ViewFileScreenState extends State<ViewFileScreen> {
  Stream? fileStream;
  late VideoPlayerController _videoPlayerController;
  bool isPlayerLoad = false;
  String pathFile = '';
  bool isWebViewLoad = false;
  bool showLoading = true;
  bool isVisiblePause = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // init controller if file type is video
      if (_checkIsVideo()) {
        setState(() {
          showLoading = false;
        });
        initVideoController(widget.fileUrl);
      } else {
        _checkCacheFile();
      }
    });
  }

  @override
  void dispose() {
    if (isPlayerLoad) {
      _videoPlayerController.dispose();
    }
    super.dispose();
  }

  bool _checkIsVideo() {
    List<String> videoSupportedFile = ['mp4', 'mov', 'm4v', '3gp'];
    bool isVideo = videoSupportedFile.contains(widget.fileType.toLowerCase());
    return isVideo;
  }

  void _checkCacheFile() async {
    var cacheFile = await CacheManagerHelper.instance.getFileFromCache(widget.fileUrl);
    if (cacheFile != null) {
      setState(() {
        pathFile = cacheFile.file.path;
        showLoading = false;
      });
    }
    // download cache for pdf or image
    else if (widget.fileUrl.isPDFFileName || widget.fileUrl.isImageFileName) {
      CacheManagerHelper.downloadFileToCacheManager(
        dio.CancelToken(),
        widget.fileUrl,
        onDownloadChange: (percentage) async {
          if (percentage == 100) {
            await Future.delayed(Duration(milliseconds: 300));
            var downloadFile = await CacheManagerHelper.instance.getFileFromCache(widget.fileUrl);
            if (mounted) {
              setState(() {
                pathFile = downloadFile?.file.path ?? '';
                showLoading = false;
              });
            }
          }
        },
      );
    } else {
      setState(() {
        showLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.grey,
        ),
        actions: [
          IconButton(
            onPressed: () {
              showMoreModalSheet();
            },
            icon: Icon(Icons.more_horiz),
            color: Colors.grey,
          )
        ],
        title: Text(
          widget.fileName,
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ),
      body: Container(color: AppColors.lightGrayBackground, child: _viewContent()),
    );
  }

  void initVideoController(String urlPath) async {
    var cacheFile = await CacheManagerHelper.instance.getFileFromCache(urlPath);
    if (cacheFile != null) {
      _videoPlayerController = VideoPlayerController.file(cacheFile.file);
    } else {
      _videoPlayerController = VideoPlayerController.network(urlPath);
    }
    onPlayVideo();
    await _videoPlayerController.initialize().then((_) {
      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.position == _videoPlayerController.value.duration) {
          setState(() {
            _videoPlayerController.pause();
            _videoPlayerController.seekTo(Duration(milliseconds: 0));
            isVisiblePause = true;
          });
        }
      });
      setState(() {
        isPlayerLoad = true;
      });
    });
  }

  Future<File> createFileOfUrl() async {
    Completer<File> completer = Completer();
    try {
      final url = widget.fileUrl;
      final filename = url.substring(url.lastIndexOf('/') + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getTemporaryDirectory();
      File file = File('${dir.path}/$filename');

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  Widget _viewContent() {
    bool isVideo = _checkIsVideo();

    if (showLoading) {
      return Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.grey,
        ),
      );
    }
    if (isVideo) {
      return Center(
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
            : CircularProgressIndicator.adaptive(
                backgroundColor: Colors.grey,
              ),
      );
    }
    // String type = lookupMimeType(pathFile) ?? '';

    if (pathFile.isImageFileName) {
      return Zoom(
        maxZoomWidth: 1000 * 2.5,
        maxZoomHeight: 1900 * 2.5,
        opacityScrollBars: 0,
        scrollWeight: 10.0,
        centerOnScale: true,
        enableScroll: true,
        doubleTapZoom: true,
        zoomSensibility: 10,
        backgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
        initZoom: 0,
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
            // setState(() {
            //   screenOpacity = 1 - details.progress;
            // });
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
          child: Image.file(
            File(pathFile),
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    if (pathFile.isPDFFileName) {
      return SizedBox(
        height: double.maxFinite,
        child: PDFView(
          filePath: pathFile,
          pageFling: false,
          pageSnap: false,
          onError: (error) {
            print(error.toString());
          },
          onPageError: (page, error) {
            print('$page: ${error.toString()}');
          },
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              border: Border.all(color: Colors.blue, width: 0.7),
            ),
            child: Text(
              widget.fileType,
              style:
                  TextStyle(color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold, overflow: TextOverflow.clip),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Text(
              widget.fileName,
              style: AppTextStyle.normalBold,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(widget.fileSize, style: AppTextStyle.extraSmallTextBold),
        ],
      ),
    );
  }

  void onShowPauseIconVideo() async {
    if (!isVisiblePause) {
      setState(() {
        isVisiblePause = true;
      });
      await Future.delayed(Duration(milliseconds: 1400), () {
        setState(() {
          isVisiblePause = false;
        });
      });
    } else {
      setState(() {
        isVisiblePause = false;
      });
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
      });
      Future.delayed(Duration(milliseconds: 1400), () {
        setState(() {
          isVisiblePause = false;
        });
      });
    }
  }

  void showMoreModalSheet() async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      context: Get.context!,
      builder: (BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 25, left: 16, right: 16),
        child: ListView(
          shrinkWrap: true,
          children: [
            InkWell(
              onTap: _saveFileToDownload,
              child: Container(
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Text('save_to_file'.tr, textAlign: TextAlign.center, style: AppTextStyle.normalBold),
              ),
            ),
            Container(height: .8, color: Colors.grey),
            InkWell(
              onTap: () {
                sentToChat();
              },
              child: Container(
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Text('send_to_chat'.tr, style: AppTextStyle.normalBold),
              ),
            ),
            Container(height: .8, color: Colors.grey),
            InkWell(
              onTap: () {
                openInOtherApp();
              },
              child: Container(
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text('open_in_other_app'.tr, style: AppTextStyle.normalBold),
              ),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  'cancel'.tr,
                  style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openInOtherApp() async {
    Get.back();
    BaseDialogLoading.show();
    final filename = widget.fileUrl.substring(widget.fileUrl.lastIndexOf('/') + 1);
    var cacheFile = await CacheManagerHelper.instance.getFileFromCache(widget.fileUrl);

    try {
      if (cacheFile != null) {
        BaseDialogLoading.dismiss();
        await Share.shareXFiles([XFile(cacheFile.file.path)]);
      } else {
        await createFileOfUrl().then((f) {
          BaseDialogLoading.dismiss();
          Share.shareXFiles([XFile(f.path)]);
        });
      }
    } catch (_) {
      BaseDialogLoading.dismiss();
    }
  }

  void sentToChat() {
    Get.back();
    Get.put(ShareContactController());
    Get.find<ShareContactController>().getFileIdFromFileView(widget.fileId);
    Get.toNamed(Routes.share_contact_screen)!.then((_) {
      Get.find<ShareContactController>().fileSendFromViewFileScreen = '';
    });
  }

  void _saveFileToDownload() async {
    Get.back();
    var cacheFile = await CacheManagerHelper.instance.getFileFromCache(widget.fileUrl);

    final bool isSuccess =
        await Get.find<ImageController>().saveFileToSpecificFolder(widget.fileUrl, cacheFile?.file, widget.fileName);
    if (isSuccess) {
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (ctx) {
            Future.delayed(Duration(milliseconds: 1000), () {
              Navigator.of(context).pop();
            });

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: CupertinoDialogIcon(text: 'saved'),
              ),
            );
          });
    }
  }
}
