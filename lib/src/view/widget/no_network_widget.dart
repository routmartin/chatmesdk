import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/network_controller.dart';

double kPreferredSize = 12;

class NetworkConnectionTextWidget extends StatelessWidget {
  const NetworkConnectionTextWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConnectionActivityController>(
        init: ConnectionActivityController(),
        builder: (controller) {
          return AnimatedContainer(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            height: controller.networkIsConnected ? 0 : 20.0,
            child: Text(
              'no_internet_connection'.tr,
              style: const TextStyle(color: Colors.red, fontSize: 13.33),
            ),
          );
        });
  }
}
