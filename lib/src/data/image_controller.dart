import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:cr_file_saver/file_saver.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart' as dio;
import '../util/helper/crash_report.dart';
import '../util/theme/app_color.dart';
import '../view/widget/base_share_widget.dart';
import 'api_helper/base/base.dart';
import 'api_helper/storage_token.dart';

class ImageController extends GetxController {
  TextEditingController imageController = TextEditingController();
  final GlobalKey cropperKey = GlobalKey(debugLabel: 'cropperKey');
  final ImagePicker _picker = ImagePicker();
  dio.CancelToken cancelToken = dio.CancelToken();
  List<File> pickedFiles = [];

  XFile? pickedFile;
  bool havePickedImage = false;
  String? croppedImagePath;
  String imageUrl = '';
  CameraPickerPageRoute<AssetEntity> Function(Widget picker)? pageRouteBuilder;

  Future<XFile> cropImage({required XFile xFile, required BuildContext context}) async {
    var croppedFile = await ImageCropper().cropImage(
      sourcePath: xFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 60,
      uiSettings: [
        AndroidUiSettings(
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          toolbarTitle: 'Edit Profile',
          toolbarColor: AppColors.primaryColor,
          toolbarWidgetColor: Colors.white,
          cropFrameColor: AppColors.primaryColor,
          hideBottomControls: true,
          activeControlsWidgetColor: AppColors.primaryColor,
          statusBarColor: Colors.white,
          cropFrameStrokeWidth: 2,
        ),
        IOSUiSettings(
          title: 'Edit Profile',
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
          aspectRatioLockDimensionSwapEnabled: true,
          resetButtonHidden: true,
          rotateButtonsHidden: true,
          rotateClockwiseButtonHidden: true,
          rectX: 10000,
          rectY: 10000,
          rectWidth: 10000,
          rectHeight: 10000,
          doneButtonTitle: 'Done',
          resetAspectRatioEnabled: false,
        ),
        WebUiSettings(
          context: context,
          presentStyle: CropperPresentStyle.dialog,
          boundary: const CroppieBoundary(
            width: 520,
            height: 520,
          ),
          viewPort: const CroppieViewPort(width: 480, height: 480, type: 'circle'),
          enableExif: true,
          enableZoom: true,
          showZoomer: true,
        ),
      ],
    );
    return XFile(croppedFile!.path);
  }

  Future<XFile?> pickImage(String source) async {
    try {
      pickedFile = await _picker.pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickedFile != null) {
        imageController.text = pickedFile!.path;
        havePickedImage = true;
        update();
      } else {
        log('image path null ');
        havePickedImage = false;
      }
      update();
    } catch (e) {
      log(e.toString());
      havePickedImage = false;
    }
    return pickedFile!;
  }

  Future<List> pickMuliImages() async {
    List<XFile>? pickedFileList;
    try {
      pickedFileList = await _picker.pickMultiImage(imageQuality: 50);
      if (pickedFileList.isNotEmpty) {
        return pickedFileList;
      }
      return [];
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      return [];
    }
  }

  Future<AssetEntity?> takeCamera() async {
    try {
      AssetEntity? entity = await CameraPicker.pickFromCamera(
        Get.context!,
        pickerConfig: const CameraPickerConfig(enableRecording: true, maximumRecordingDuration: Duration(minutes: 10)),
        locale: StorageToken.readLanguageChosen() == 'en' ? const Locale('en') : const Locale('zh'),
      );
      if (entity != null) {
        return entity;
      }
      return null;
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      return null;
    }
  }

  Future<XFile?> pickSingleFile(String source) async {
    XFile? file;
    try {
      file = await _picker.pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      );
      if (file != null) {
        return file;
      }
      return null;
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      return null;
    }
  }

  Future<List<AssetEntity>?> openMedia({maxLength}) async {
    List<AssetEntity>? result;
    try {
      result = await AssetPicker.pickAssets(
        Get.context!,
        pickerConfig: AssetPickerConfig(maxAssets: maxLength),
      );
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      return null;
    }

    return result;
  }

  Future uploadImage(String path) async {
    List<dio.MultipartFile> files = [];
    files.add(await dio.MultipartFile.fromFile(path));
    var formData = dio.FormData.fromMap({'attachment': files});

    try {
      BaseDialogLoading.show();
      var response = await dio.Dio().post('${SocketPath.httpBaseUrl}${SocketPath.uploadFile}',
          data: formData,
          options: dio.Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${StorageToken.readToken()}',
            },
          ));

      if (response.statusCode == 200) {
        BaseDialogLoading.dismiss();
        // var avatarID = response.data['data']['_id'];
        // await Get.find<AccountUserProfileController>().updateProfile('avatar', avatarID);
      } else {
        BaseDialogLoading.dismiss();
        BaseToast.showErorrBaseToast('could_not_upload_image_now_,_please_try_again_later'.tr);
      }
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      BaseDialogLoading.dismiss();
      BaseToast.showErorrBaseToast('could_not_upload_image_now_,_please_try_again_later'.tr);
    }
  }

  Future<Directory> getTemporaryDirectory() async {
    return Directory.systemTemp;
  }

  /// return String of attactmentId
  Future<String?> uploadAttachment(
    String path,
    MediaType mediaType, {
    Function(int percentage)? onUploadChange,
    bool? hasQrcode,
    bool? isCompress = false,
  }) async {
    final completer = Completer<String?>();
    List<dio.MultipartFile> files = [];
    dio.MultipartFile filePath;
    final mimeType = lookupMimeType(path) ?? '';
    final isImage = mimeType.startsWith('image/');

    // check need to comopress file or not
    if (isCompress! && isImage) {
      File compressedFile = await FlutterNativeImage.compressImage(path, quality: 80);
      filePath = await dio.MultipartFile.fromFile(
        compressedFile.absolute.path,
        contentType: mediaType,
      );
    } else {
      filePath = await dio.MultipartFile.fromFile(
        path,
        contentType: mediaType,
      );
    }
    files.add(filePath);
    var formData = dio.FormData.fromMap({
      'attachment': files,
      'hasQrcode': hasQrcode,
    });
    String token = StorageToken.readToken();
    try {
      var response = await dio.Dio().post(
        '${SocketPath.httpBaseUrl}${SocketPath.uploadFile}',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        onSendProgress: (count, total) {
          if (total != -1) {
            if (onUploadChange != null) {
              onUploadChange(
                int.parse(
                  (count / total * 100).toStringAsFixed(0),
                ),
              );
            }
          }
        },
        cancelToken: cancelToken, // to cancel uploading progress
      );
      var attachmentIds = response.data['data']['_id'];
      completer.complete(attachmentIds);
      return attachmentIds;
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      dio.DioError err = e as dio.DioError;
      if (err.response?.statusCode == 413 || err.response?.statusCode == 401) {
        // 413 error file is too large for server
        // 401 error token expired
        completer.complete('status_error');
      } else {
        completer.complete(null);
      }
      log(e.toString());
    }
    return completer.future;
  }

  // use this function to prevent auto remove by pickfiles
  Future<List<File>> newPickFileList(List<File> list) async {
    var dir = await getTemporaryDirectory();
    return await Future.wait(list.map((file) async {
      String filename = file.path.split('/').last;
      var newfile = file.copy('${dir.path}/$filename');
      return newfile;
    }));
  }

  Future<List<File>?> pickFiles() async {
    // pick files stores in tmp directory which is last only 60 seconds
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      pickedFiles = result.paths.map((path) => File(path ?? '')).toList();
      pickedFiles = await newPickFileList(pickedFiles);
      update();
      return pickedFiles;
    } else {
      return null;
    }
  }

  // Future<bool> saveImageToGallary(String urlPath) async {
  //   try {
  //     var response = await dio.Dio().get(
  //       urlPath,
  //       options: dio.Options(responseType: dio.ResponseType.bytes),
  //     );

  //     final result = await ImageGallerySaver.saveImage(
  //       Uint8List.fromList(response.data),
  //       name: urlPath,
  //     );
  //     if (result['isSuccess']) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     final message = e.toString();
  //     await CrashReport.send(ReportModel(message: message));
  //     print(e);
  //     return false;
  //   }
  // }

  // Future<bool> saveVideoToGallary(String urlPath) async {
  //   try {
  //     var fileName = urlPath.split('/chat-me/').last;
  //     var tempDir = await getTemporaryDirectory();
  //     String savePath = tempDir.path + fileName;
  //     BaseDialogLoading.show();
  //     var response = await dio.Dio().get(
  //       urlPath,
  //       options: dio.Options(responseType: dio.ResponseType.bytes),
  //     );
  //     File file = File(savePath);
  //     var raf = file.openSync(mode: FileMode.write);
  //     raf.writeFromSync(response.data);
  //     await raf.close();

  //     final result = await ImageGallerySaver.saveFile(raf.path);
  //     Directory(savePath).deleteSync(recursive: true);
  //     BaseDialogLoading.dismiss();
  //     if (result['isSuccess']) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     final message = e.toString();
  //     await CrashReport.send(ReportModel(message: message));
  //     BaseDialogLoading.dismiss();
  //     print(e);
  //     return false;
  //   }
  // }

  Future<File?> downloadImage(String url) async {
    try {
      BaseDialogLoading.show();
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/imageQr.png';
      await dio.Dio().download(url, filePath, options: dio.Options(responseType: dio.ResponseType.bytes));
      BaseDialogLoading.dismiss();
      return File(filePath);
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      rethrow;
    }
  }

  void fileDownload(String url) async {}

  Future<bool> saveFileToDownloadFolder(String fileUrl, String fileName) async {
    BaseDialogLoading.show();
    String localPath;
    if (Platform.isAndroid) {
      localPath = '/sdcard/download/';
    } else {
      var directory = await getApplicationDocumentsDirectory();
      localPath = '${directory.path}${Platform.pathSeparator}Download';
    }

    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      await savedDir.create();
    }
    try {
      await dio.Dio().download(fileUrl, '$localPath/$fileName');
      BaseDialogLoading.dismiss();
      return true;
    } catch (e) {
      BaseDialogLoading.dismiss();
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      print('Download Failed.\n\n$e');
      return false;
    }
  }

  Future<bool> saveFileToSpecificFolder(String fileUrl, File? cachedFile, String fileNameWithExtension) async {
    try {
      // String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      // if (selectedDirectory == null) {
      //   return false;
      // }

      BaseDialogLoading.show();
      if (cachedFile != null) {
        // await cachedFile.copy(
        //     '$selectedDirectory/${math.Random().nextInt(1000000000)}_$fileNameWithExtension');
        String? file;
        await cachedFile.setLastModified(DateTime.now());
        file = await CRFileSaver.saveFileWithDialog(SaveFileDialogParams(
          sourceFilePath: cachedFile.path,
          destinationFileName: fileNameWithExtension,
        ));
        if (file == null) {
          BaseDialogLoading.dismiss();
          return false;
        }
      } else {
        final folder = await getTemporaryDirectory();
        final filePath = '${folder.path}/${math.Random().nextInt(1000000000)}_$fileNameWithExtension';
        await dio.Dio().download(fileUrl, filePath);
        String? file;
        file = await CRFileSaver.saveFileWithDialog(SaveFileDialogParams(
          sourceFilePath: filePath,
          destinationFileName: fileNameWithExtension,
        ));
        if (file == null) {
          BaseDialogLoading.dismiss();
          return false;
        }
      }
      BaseDialogLoading.dismiss();
      return true;
    } catch (e) {
      BaseDialogLoading.dismiss();
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      print('Download Failed.\n\n$e');
      return false;
    }
  }

  // Future<bool> saveImageToGalleryWithCheckPermission(String url) async {
  //   bool isSuccess = false;
  //   final permissionStatus = await Permission.storage.status;
  //   if (permissionStatus.isDenied) {
  //     await Permission.storage.request();
  //   } else if (permissionStatus.isPermanentlyDenied) {
  //     return false;
  //   }
  //   if (Platform.isAndroid) {
  //     var androidInfo = await DeviceInfoPlugin().androidInfo;
  //     var release = androidInfo.version.release;
  //     if (int.parse(release) < 10) {
  //       BaseDialogLoading.dismiss();
  //       isSuccess =
  //           await saveFileToDownloadFolder(url, '${math.Random().nextInt(1000000000)}_${url.split('/chat-me/').last}');
  //     } else {
  //       isSuccess = await saveImageToGallary(url);
  //     }
  //   } else {
  //     isSuccess = await saveImageToGallary(url);
  //   }
  //   return isSuccess;
  // }

  // Future<bool> saveVideoToGalleryWithCheckPermission(String url) async {
  //   bool isSuccess = false;
  //   final permissionStatus = await Permission.storage.status;
  //   if (permissionStatus.isDenied) {
  //     await Permission.storage.request();
  //   } else if (permissionStatus.isPermanentlyDenied) {
  //     return false;
  //   }
  //   if (Platform.isAndroid) {
  //     var androidInfo = await DeviceInfoPlugin().androidInfo;
  //     var release = androidInfo.version.release;
  //     if (int.parse(release) < 10) {
  //       BaseDialogLoading.dismiss();
  //       isSuccess =
  //           await saveFileToDownloadFolder(url, '${math.Random().nextInt(1000000000)}_${url.split('/chat-me/').last}');
  //     } else {
  //       isSuccess = await saveVideoToGallary(url);
  //     }
  //   } else {
  //     isSuccess = await saveVideoToGallary(url);
  //   }
  //   return isSuccess;
  // }

  @override
  void onClose() {
    super.onClose();
    pickedFile = null;
  }
}
