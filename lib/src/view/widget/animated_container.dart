import 'package:flutter/material.dart';
import 'package:show_up_animation/show_up_animation.dart';

class AnimatedEaseoutMessage extends StatelessWidget {
  const AnimatedEaseoutMessage({
    Key? key,
    required this.child,
    required this.keyId,
    this.isDisabledAnimation = false,
  }) : super(key: key);
  final Widget child;
  final String keyId;
  final bool isDisabledAnimation;
  @override
  Widget build(BuildContext context) {
    return ShowUpAnimation(
      key: Key(keyId),
      delayStart: const Duration(milliseconds: 0),
      animationDuration: isDisabledAnimation ? Duration.zero : const Duration(milliseconds: 400),
      curve: Curves.ease,
      direction: Direction.vertical,
      offset: 0.6,
      child: child,
    );
  }
}
