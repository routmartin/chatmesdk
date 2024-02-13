import 'package:flutter/material.dart';

class FuncBaseScrollToTop {
  final ScrollController scrollController = ScrollController();
  void scrollToIndex() async {
    // if (scrollController.hasClients) {
    await scrollController.animateTo(
      0,
      duration: const Duration(
        milliseconds: 100,
      ),
      curve: Curves.easeInOutCubic,
    );
    // Get.appUpdate();
    // }
  }
}
