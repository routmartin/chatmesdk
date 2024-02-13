import 'package:flutter/material.dart';

class KeyboardHeper {
  static void hideKeyborad(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
