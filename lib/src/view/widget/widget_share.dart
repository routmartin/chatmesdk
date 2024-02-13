import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BaseToast {
  static void removeAllBaseToast() {
    return Get.closeAllSnackbars();
  }

  static SnackbarController showErorrBaseToast(String message, {duration = 2}) {
    Get.closeAllSnackbars();
    return Get.showSnackbar(
      GetSnackBar(
        icon: const Icon(Icons.error_outline),
        backgroundColor: const Color.fromARGB(255, 230, 89, 79),
        message: message.tr,
        snackPosition: SnackPosition.TOP,
        isDismissible: true,
        duration: Duration(seconds: duration),
        snackStyle: SnackStyle.GROUNDED,
      ),
    );
  }

  static SnackbarController showSuccessBaseToast(String message) {
    return Get.showSnackbar(
      GetSnackBar(
        icon: const Icon(Icons.done, color: Colors.white),
        backgroundColor: const Color(0XFF408140),
        message: message.tr,
        snackPosition: SnackPosition.TOP,
        isDismissible: false,
        duration: const Duration(seconds: 1),
        snackStyle: SnackStyle.GROUNDED,
      ),
    );
  }
}
