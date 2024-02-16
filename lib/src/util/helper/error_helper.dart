import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../view/widget/base_share_widget.dart';
import '../theme/app_color.dart';

class ErrorHelper {
  static void errorHandler({required int errorCode, Function? function}) {
    switch (errorCode) {
      case 40000:
        BaseToast.showErorrBaseToast('40000'.tr);
        break;
      case 50001:
        _showDialoge('50001'.tr);
        break;
      case 40006:
        BaseToast.showErorrBaseToast('40006'.tr);
        break;
      case 40003:
        BaseToast.showErorrBaseToast('40003'.tr);
        break;
      case 40004:
        BaseToast.showErorrBaseToast('40004'.tr);
        break;
      case 40014:
        BaseToast.showErorrBaseToast('40014'.tr);
        break;
      case 40016:
        _showDialoge('40016'.tr);
        break;
      case 10000:
        BaseToast.showErorrBaseToast('10000'.tr);
        break;
      default:
        function ?? BaseToast.showErorrBaseToast('$errorCode'.tr);
    }
  }
}

void _showDialoge(errorMessage) {
  showCupertinoDialog<void>(
    context: Get.context!,
    builder: (BuildContext context) => CupertinoAlertDialog(
      content: Text(
        errorMessage,
        style: const TextStyle(
          color: AppColors.txtSeconddaryColor,
          fontWeight: FontWeight.w400,
          fontSize: 13.3,
        ),
      ),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'ok'.tr,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
  );
}
