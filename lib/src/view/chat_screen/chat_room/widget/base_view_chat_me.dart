import 'package:chatme/template/chat_screen/chat_room/widget/status_bar_call.dart';
import 'package:flutter/material.dart';

class AppMetricsObserver with WidgetsBindingObserver {
  Function() onMetricsChanged;
  AppMetricsObserver({required this.onMetricsChanged});

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    onMetricsChanged();
  }
}

class BaseViewChatMe extends StatefulWidget {
  final AppBar? appBar;
  final Widget? body;
  final Widget child;
  const BaseViewChatMe({
    Key? key,
    this.appBar,
    this.body,
    required this.child,
  }) : super(key: key);

  @override
  State<BaseViewChatMe> createState() => _BaseViewChatMeState();
}

class _BaseViewChatMeState extends State<BaseViewChatMe> with WidgetsBindingObserver {
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final topPadding = MediaQueryData.fromView(View.of(context)).padding.top;
    if (topPadding > 24) {}
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(AppMetricsObserver(
      onMetricsChanged: () {
        print('observer working');
      },
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(AppMetricsObserver(
      onMetricsChanged: () {
        print('observer working');
      },
    ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [widget.child, StatusBarCell()],
    );
  }
}
