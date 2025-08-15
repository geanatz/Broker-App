import 'package:flutter/foundation.dart';

class DialogOverlayController {
  DialogOverlayController._();
  static final DialogOverlayController instance = DialogOverlayController._();

  final ValueNotifier<bool> isShown = ValueNotifier<bool>(false);
  int _depth = 0;

  void push() {
    _depth++;
    if (_depth > 0 && !isShown.value) {
      isShown.value = true;
    }
  }

  void pop() {
    if (_depth > 0) {
      _depth--;
    }
    if (_depth == 0 && isShown.value) {
      isShown.value = false;
    }
  }
}


