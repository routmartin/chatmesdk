import 'dart:async';
import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart';

import '../../util/constant/app_assets.dart';
import '../../util/constant/app_constant.dart';
import '../../util/helper/crash_report.dart';
import '../../view/chat_screen/sticker_screen/export.dart';
import '../api_helper/base/base.dart';
import 'model/add_sticker_response_model.dart';
import 'model/get_all_available_sticker_response_model.dart';
import 'model/get_recommand_sticker_respons_model.dart';
import 'model/my_sticker_response_model.dart';
import 'model/recent_used_sticker.dart';
import 'model/view_sticker_response_model.dart';

class StickerController extends GetxController with GetTickerProviderStateMixin {
  late Socket _socket;
  late TabController tabController;

  ViewStickersResponseModel? stickersInDetail;
  List<AllAvailableStickers> allAvailableStickers = [];
  List<RecommandedStickerModel> recommendedStickers = [];
  List<AllAvailableStickers> otherCategoryStickers = [];

  List<AllAvailableStickers> searchStickerResult = [];
  List<MyStickerModel>? mySticker = [];
  List<MyStickerModel>? myStickerAfterSearch = [];
  List<RecentUsedStickers> recentUsedStickers = [];
  final List<MyStickerModel> _storeAsset = <MyStickerModel>[
    MyStickerModel(thumbnail: Assets.app_assetsIconsIconSetting),
    MyStickerModel(thumbnail: Assets.app_assetsIconsIconRecently),
    MyStickerModel(thumbnail: Assets.app_assetsIconsIconPlusGreen),
  ];
  List<MyStickerModel> tabBarName = [];
  bool showEmojiFooter = false;
  bool showPlusFooter = false;
  bool isLoading = true;

  @override
  void onInit() async {
    _socket = await BaseSocket.initConnectWithHeader(SocketPath.message);
    await Future.wait([getMyStickers(), getRecentUsedStickers()]).then((_) {
      initTabController();
    });

    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void initTabController() {
    tabBarName.insertAll(0, _storeAsset);
    tabBarName.insertAll(2, mySticker ?? []);
    tabController = TabController(length: tabBarName.length, vsync: this, initialIndex: 1);
    tabController.animateTo(1);
    isLoading = false;
    update();
  }

  void _resetTabController() {
    tabController.dispose();
    tabBarName.clear();
    tabBarName.insertAll(0, _storeAsset);
    tabBarName.insertAll(2, mySticker ?? []);
    tabController = TabController(length: tabBarName.length, vsync: this, initialIndex: 1);
    tabController.animateTo(1);
    update();
  }

  Future<bool> getMyStickers() async {
    final completer = Completer<bool>();
    try {
      var request = {
        'query': {
          'page': 1,
          'limit': 100,
        }
      };
      _socket.emitWithAck(SocketPath.mySticker, request, ack: (result) async {
        BaseApiResponse<ListMyStickerResponseModel> response = BaseApiResponse.generateResponse(
          response: result,
          parseData: (data) => ListMyStickerResponseModel.fromJson(result),
        );

        if (response.success) {
          mySticker = response.result?.data;
          myStickerAfterSearch = mySticker;
          update();
        }
        completer.complete(true);
      });
    } catch (e) {
      completer.complete(true);
    }
    return completer.future;
  }

  void getAllAvailableSticker() async {
    try {
      var request = {
        'query': {'page': 1, 'limit': 100}
      };

      _socket.emitWithAck(SocketPath.listAllSticker, request, ack: (result) async {
        BaseApiResponse<GetAllAvailableStickerResponseModel> response = BaseApiResponse.generateResponse(
          response: result,
          parseData: (data) => GetAllAvailableStickerResponseModel.fromJson(result),
        );
        if (response.success) {
          allAvailableStickers = response.result?.data ?? [];
          update();
        }
      });
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
    }
  }

  void getRecommendSticker() async {
    try {
      var request = {
        'query': {
          'page': 1,
          'limit': 100,
        }
      };
      _socket.emitWithAck(SocketPath.getRecommendSticker, request, ack: (result) async {
        BaseApiResponse<GetRecommandStickerModel> response = BaseApiResponse.generateResponse(
          response: result,
          parseData: (data) => GetRecommandStickerModel.fromJson(result),
        );
        if (response.success) {
          recommendedStickers = response.result?.data ?? [];
          update();
        } else {}
      });
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      log(e.toString());
    }
  }

  void addStickerToMySticker(String stickerGroupId) async {
    try {
      // BaseDialogLoading.show();
      var request = {
        'body': {'stickerGroupId': stickerGroupId}
      };
      _socket.emitWithAck(SocketPath.addSticker, request, ack: (result) async {
        // BaseDialogLoading.dismiss();
        BaseApiResponse<AddStickerResponseModel> response = BaseApiResponse.generateResponse(
          response: result,
          parseData: (data) => AddStickerResponseModel.fromJson(data),
        );
        if (response.success) {
          stickersInDetail?.data?.isAdded = true;
          update();
          //* call to rebuild ui -> not good practise
          getAllAvailableSticker();
          await getMyStickers().then((_) {
            _resetTabController();
          });
        }
      });
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      // BaseDialogLoading.dismiss();
      log(e.toString());
    }
  }

  void viewEachSticker(String stickerGroupId) async {
    final completer = Completer();
    try {
      stickersInDetail = null;
      var request = {
        'body': {'stickerGroupId': stickerGroupId}
      };
      _socket.emitWithAck(SocketPath.viewEachSticker, request, ack: (result) async {
        BaseApiResponse<ViewStickersResponseModel> response = BaseApiResponse.generateResponse(
          response: result,
          parseData: (data) => ViewStickersResponseModel.fromJson(result),
        );

        if (response.success) {
          completer.complete();
          stickersInDetail = response.result;
          update();
        } else {
          completer.complete();
          log(response.error.toString());
        }
      });
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      completer.complete();
      log(e.toString());
    }
  }

  void searchSticker(String query) async {
    try {
      // BaseDialogLoading.show();
      var request = {
        'query': {
          'page': 1,
          'limit': 1,
          'search': query,
        }
      };
      _socket.emitWithAck(SocketPath.listAllSticker, request, ack: (result) async {
        // BaseDialogLoading.dismiss();
        BaseApiResponse<GetAllAvailableStickerResponseModel> response = BaseApiResponse.generateResponse(
          response: result,
          parseData: (data) => GetAllAvailableStickerResponseModel.fromJson(result),
        );
        if (response.success) {
          searchStickerResult = response.result?.data ?? [];
          update();
        } else {}
      });
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      // BaseDialogLoading.dismiss();
      log(e.toString());
    }
  }

  void removeSticker(String stickerGroupId) async {
    try {
      // BaseDialogLoading.show();
      var request = {
        'body': {'stickerGroupId': stickerGroupId}
      };
      _socket.emitWithAck(SocketPath.removeSticker, request, ack: (result) async {
        // BaseDialogLoading.dismiss();
        var res = result;
        if (res['data']['success']) {
          mySticker?.removeWhere((element) => element.stickergroupId == stickerGroupId);
          // viewEachSticker(stickerGroupId);
          _resetTabController();
        }
      });
    } catch (e) {
      // BaseDialogLoading.dismiss();
      rethrow;
    }
  }

  Future getRecentUsedStickers() async {
    try {
      var request = {
        'query': {'page': 1, 'limit': AppConstants.defaultLimit}
      };
      _socket.emitWithAck(SocketPath.recentUsedSticker, request, ack: (result) async {
        BaseApiResponse<RecentUsedStickerResponseModel> response = BaseApiResponse.generateResponse(
          response: result,
          parseData: (data) => RecentUsedStickerResponseModel.fromJson(result),
        );
        if (response.success) {
          recentUsedStickers = response.result?.data ?? [];
          update();
        } else {
          log(response.error.toString());
        }
      });
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      log(e.toString());
    }
  }

  void searchMySticker(String searchQuery) async {
    myStickerAfterSearch = mySticker;
    if (searchQuery.isEmpty) {
      myStickerAfterSearch = mySticker;
    } else {
      myStickerAfterSearch = mySticker!
          .where((element) => element.name!.first.value.toString().toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    update();
  }
}
