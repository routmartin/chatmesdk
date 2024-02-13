import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/app_color.dart';

class MessageDialogHelper {
  static void showCallPrivacyDeniedDialog(String name) {
    showCupertinoDialog(
      barrierDismissible: true,
      context: Get.context!,
      builder: (context) => Dialog(
        child: Material(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  '${'sorry,_you_can’t_call'.tr} $name ${'because_of_their_privacy_setting._you_can_check_with_them_to_modify_their_setting.'.tr}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
              Container(height: .5, color: Colors.grey),
              InkWell(
                onTap: Get.back,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    'ok'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showPermissionAudioPermanentlyDeniedDialog() {
    showCupertinoDialog(
      barrierDismissible: true,
      context: Get.context!,
      builder: (context) => Dialog(
        child: Material(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                Container(
                  padding: const EdgeInsets.all(23),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Text(
                    'in_the_setting_app,_tap_chatme_and_turn_on_microphone'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                Container(height: .5, color: Colors.grey),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: Get.back,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Text(
                            'cancel'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0XFF787878),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(height: 50, width: .5, color: Colors.grey),
                    Expanded(
                      child: InkWell(
                        onTap: openAppSettings,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Text(
                            'open_setting'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
