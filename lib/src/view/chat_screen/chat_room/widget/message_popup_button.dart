import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double _kMenuScreenPadding = 8.0;
typedef PopupBuilder = Widget Function(BuildContext context, Function onClose);

enum PopupDirection { left, top, right, bottom }

enum PopupAlign { start, center, end }

enum PressType { longPress, tap }

// class _PopupRoute<T> extends PopupRoute<T> {
//   _PopupRoute(
//       {required this.position,
//       required this.child,
//       this.initialValue,
//       this.elevation,
//       this.shape,
//       this.color,
//       required this.align,
//       required this.direction});
//   final PopupDirection direction;
//   final PopupAlign align;
//   final RelativeRect position;
//   final Widget child;

//   final T? initialValue;
//   final double? elevation;

//   final ShapeBorder? shape;
//   final Color? color;

//   @override
//   Animation<double> createAnimation() {
//     return CurvedAnimation(
//       parent: super.createAnimation(),
//       curve: Curves.linear,
//       reverseCurve: const Interval(0.0, 2.0 / 3.0),
//     );
//   }

//   @override
//   Duration get transitionDuration => const Duration(milliseconds: 0);

//   @override
//   bool get barrierDismissible => true;
//   @override
//   Color? get barrierColor => null;

//   @override
//   Widget buildPage(BuildContext context, Animation<double> animation,
//       Animation<double> secondaryAnimation) {
//     final MediaQueryData mediaQuery = MediaQuery.of(context);
//     return MediaQuery.removePadding(
//       context: context,
//       removeTop: true,
//       removeBottom: true,
//       removeLeft: true,
//       removeRight: true,
//       child: Builder(
//         builder: (BuildContext context) {
//           return CustomSingleChildLayout(
//             delegate: __PopupRouteLayout(
//                 position: position,
//                 padding: mediaQuery.padding,
//                 align: align,
//                 direction: direction),
//             child: child,
//           );
//         },
//       ),
//     );
//   }

//   @override
//   String? get barrierLabel => 'dismiss';
// }

class __PopupRouteLayout extends SingleChildLayoutDelegate {
  __PopupRouteLayout(
      {required this.position,
      required this.padding,
      required this.direction,
      required this.align,
      required this.arrowHeight});
  final PopupDirection direction;
  final PopupAlign align;

  final RelativeRect position;
  final double arrowHeight;

  // The padding of unsafe area.
  EdgeInsets padding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest).deflate(
      const EdgeInsets.all(_kMenuScreenPadding) + padding,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // size: The size of the overlay.
    // childSize: The size of the popup.
    var buttonHeight = size.height - position.top - position.bottom;
    var buttonWidth = size.width - position.left - position.right;
    double x = 0;

    double y = 0;
    var diffHeight = buttonHeight - childSize.height;
    var diffWidth = buttonWidth - childSize.width;
    switch (direction) {
      case PopupDirection.left:
        switch (align) {
          case PopupAlign.start:
            x = position.left - childSize.width;
            y = position.top;
            break;
          case PopupAlign.center:
            x = position.left - childSize.width;
            y = position.top + diffHeight / 2;
            break;
          case PopupAlign.end:
            x = position.left - childSize.width;
            y = size.height - position.bottom - childSize.height;
            break;
        }

        break;
      case PopupDirection.top:
        switch (align) {
          case PopupAlign.start:
            x = position.left;
            y = position.top - childSize.height - arrowHeight;
            break;
          case PopupAlign.center:
            x = position.left + diffWidth / 2;
            y = position.top - childSize.height - arrowHeight;
            break;
          case PopupAlign.end:
            x = size.width - position.right - childSize.width;
            y = position.top - childSize.height - arrowHeight;
            break;
        }

        break;
      case PopupDirection.right:
        switch (align) {
          case PopupAlign.start:
            x = size.width - position.right;
            y = position.top;
            break;
          case PopupAlign.center:
            x = size.width - position.right;
            y = position.top + diffHeight / 2;
            break;
          case PopupAlign.end:
            x = size.width - position.right;
            y = size.height - position.bottom - childSize.height;
            break;
        }

        break;
      case PopupDirection.bottom:
        switch (align) {
          case PopupAlign.start:
            x = position.left;
            y = size.height - position.bottom + arrowHeight;
            break;
          case PopupAlign.center:
            x = position.left + diffWidth / 2;
            y = size.height - position.bottom + arrowHeight;
            break;
          case PopupAlign.end:
            x = size.width - position.right - childSize.width;
            y = size.height - position.bottom + arrowHeight;
            break;
        }

        break;
    }

    // Avoid going outside an area defined as the rectangle 8.0 pixels from the
    // edge of the screen in every direction.
    if (x < _kMenuScreenPadding + padding.left) {
      x = _kMenuScreenPadding + padding.left;
    } else if (x + childSize.width > size.width - _kMenuScreenPadding - padding.right) {
      x = size.width - childSize.width - _kMenuScreenPadding - padding.right;
    }
    if (y < _kMenuScreenPadding + padding.top) {
      y = _kMenuScreenPadding + padding.top;
    } else if (y + childSize.height > size.height - _kMenuScreenPadding - padding.bottom) {
      y = size.height - padding.bottom - _kMenuScreenPadding - childSize.height;
    }
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(__PopupRouteLayout oldDelegate) {
    return position != oldDelegate.position || padding != oldDelegate.padding;
  }
}

class MessagePopupButton extends StatefulWidget {
  final bool enableFeedback;
  final Widget child;
  final bool enabled;
  final Offset offset;
  final Function? onClose;
  final PopupBuilder builder;
  final PopupDirection direction;
  final PopupAlign align;
  final bool isShowArrow;
  final PressType pressType;
  const MessagePopupButton({
    Key? key,
    required this.builder,
    required this.direction,
    this.align = PopupAlign.center,
    this.onClose,
    this.offset = Offset.zero,
    this.enabled = true,
    required this.child,
    this.enableFeedback = true,
    this.isShowArrow = true,
    this.pressType = PressType.longPress,
  }) : super(key: key);

  @override
  State<MessagePopupButton> createState() => _MessagePopupButtonState();
}

class _MessagePopupButtonState extends State<MessagePopupButton> {
  OverlayEntry? _entry;
  late final double _arrowHeight;

  void onClosePopUp() {
    if (_entry != null) {
      _entry!.remove();

      setState(() {
        _entry = null;
      });
    }
  }

  void showButtonPopup() {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    var dx = widget.offset.dx;
    var dy = widget.offset.dy;
    var popUpHeight = 250;

    switch (widget.direction) {
      case PopupDirection.left:
        dx = -dx;
        break;
      case PopupDirection.top:
        dy = -dy;
        break;
      case PopupDirection.right:
        break;
      case PopupDirection.bottom:
        break;
    }
    var offset = Offset(dx, dy);
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(offset, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero) + offset, ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final topPosition = button.localToGlobal(Offset.zero);
    final keyboardHeight = EdgeInsets.fromWindowPadding(
            WidgetsBinding.instance.window.viewInsets, WidgetsBinding.instance.window.devicePixelRatio)
        .bottom;

    var topButtonOffset = topPosition.dy;
    var isTopDirection = topButtonOffset >= popUpHeight // top area bigger than popUpHeight
        || // button height is long
        (button.size.height > Get.height / 2 && button.size.height + topButtonOffset > popUpHeight) || // keyboard open
        (button.size.height > (Get.height - keyboardHeight) / 2 && keyboardHeight > 0);

    var child = widget.builder(context, onClosePopUp);
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    /*  if (widget.wrapper != null) {
      child = Wrapper(
        child: child,
      );
    } */

    _entry = OverlayEntry(builder: (context) {
      return Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: Colors.transparent,
              child: GestureDetector(
                onTapDown: (_) => onClosePopUp(),
                onVerticalDragDown: (_) => onClosePopUp(),
              ),
            ),
          ),
          CustomSingleChildLayout(
            delegate: __PopupRouteLayout(
              position: position,
              padding: mediaQuery.padding,
              align: widget.align,
              direction: isTopDirection ? PopupDirection.top : PopupDirection.bottom,
              arrowHeight: _arrowHeight,
            ),
            child: AnimatedPopupMenu(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  child,
                  if (widget.isShowArrow)
                    Positioned(
                      top: isTopDirection ? null : -_arrowHeight + 0.1,
                      bottom: isTopDirection ? -_arrowHeight + 0.1 : null,
                      //TODO: calculate position later
                      left: position.left < 100 ? position.left + (button.size.width / 2) - 15 : null,
                      right: position.left < 100 ? null : button.size.width / 2,
                      child: Transform.scale(
                        scaleY: isTopDirection ? 1 : -1,
                        child: ClipPath(
                          clipper: TriangleClipper(),
                          child: Container(
                            color: Color(0xff343434),
                            height: _arrowHeight,
                            width: 15,
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      );
    });

    final overlayPopup = Overlay.of(context)!;
    overlayPopup.insert(_entry!);

    // showPopup(
    //   direction: widget.direction,
    //   align: widget.align,
    //   context: context,
    //   child: child,
    //   position: position,
    // ).then<void>((newValue) {
    //   if (!mounted) return null;
    //   widget.onClose?.call(newValue);
    // });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((call) {
      if (mounted) {
        setState(() {
          _arrowHeight = widget.isShowArrow ? 8 : 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.pressType == PressType.longPress
          ? null
          : widget.enabled
              ? showButtonPopup
              : null,
      onLongPress: widget.pressType == PressType.tap
          ? null
          : widget.enabled
              ? showButtonPopup
              : null,
      enableFeedback: widget.enableFeedback,
      child: widget.child,
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}

// Future showPopup(
//     {required BuildContext context,
//     required RelativeRect position,
//     required Widget child,
//     bool useRootNavigator = false,
//     required PopupDirection direction,
//     required PopupAlign align}) {
//   final NavigatorState navigator =
//       Navigator.of(context, rootNavigator: useRootNavigator);
//   return navigator.push(_PopupRoute(
//       position: position, child: child, align: align, direction: direction));
// }

/// Implements the menu opening and closing animation.
class AnimatedPopupMenu extends StatefulWidget {
  final Widget child;

  const AnimatedPopupMenu({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  AnimatedPopupMenuState createState() => AnimatedPopupMenuState();
}

class AnimatedPopupMenuState extends State<AnimatedPopupMenu> with TickerProviderStateMixin {
  static const ENTER_DURATION = Duration(milliseconds: 220);
  static final CurveTween enterOpacityTween = CurveTween(
    curve: Interval(0.0, 90 / 220, curve: Curves.linear),
  );
  static final CurveTween enterSizeTween = CurveTween(
    curve: Curves.easeOutCubic,
  );

  static const EXIT_DURATION = Duration(milliseconds: 260);
  static final CurveTween exitOpacityTween = CurveTween(
    curve: Curves.linear,
  );

  late final AnimationController _enterAnimationController;
  late final Animation<double> _enterAnimation;
  late final AnimationController _exitAnimationController;
  late final Animation<double> _exitAnimation;
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0, -.1),
    end: const Offset(0, 0),
  ).animate(CurvedAnimation(
    parent: _enterAnimationController,
    curve: Curves.easeOut,
  ));

  @override
  void initState() {
    _enterAnimationController = AnimationController(
      vsync: this,
      duration: ENTER_DURATION,
    );
    _enterAnimation = Tween(begin: 0.0, end: 1.0).animate(_enterAnimationController);
    _enterAnimationController.forward().then((value) {});

    _exitAnimationController = AnimationController(
      vsync: this,
      duration: EXIT_DURATION,
    );
    _exitAnimation = Tween(begin: 1.0, end: 0.0).animate(_exitAnimationController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _exitAnimation,
      builder: (BuildContext context, child) {
        return Opacity(
          opacity: exitOpacityTween.evaluate(_exitAnimation),
          child: child!,
        );
      },
      child: AnimatedBuilder(
        animation: _enterAnimation,
        builder: (BuildContext context, _) {
          return SlideTransition(
            position: _offsetAnimation,
            child: Opacity(
              opacity: enterOpacityTween.evaluate(_enterAnimation),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }

  Future<void> showMenu() async {
    _enterAnimationController.stop();
    await _exitAnimationController.forward();
  }

  Future<void> hideMenu() async {
    _enterAnimationController.stop();
    await _exitAnimationController.forward();
  }

  @override
  void dispose() {
    _enterAnimationController.dispose();
    _exitAnimationController.dispose();
    super.dispose();
  }
}
