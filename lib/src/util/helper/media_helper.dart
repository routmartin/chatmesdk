import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/chat_room/model/attachment_model.dart';

import '../constant/app_assets.dart';

class MediaHelper {
  static bool checkIfMediaImage(AttachmentModel model) {
    var url = model.url ?? '';
    var isImageByMimeType = model.mimeType?.startsWith('image/') ?? false;
    return url.isImageFileName || isImageByMimeType;
  }

  static Widget brokenfile({double scale = 4}) {
    return Container(
      color: const Color(0xFFE4E6EB),
      padding: const EdgeInsets.all(8.0),
      width: Get.width * .4,
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            Assets.app_assetsIconsBrokenFile,
            scale: scale,
          ),
          const SizedBox(height: 12),
          const FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              'Unavailable',
              style: TextStyle(
                color: Color(0xFF787878),
                fontSize: 13.33,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
