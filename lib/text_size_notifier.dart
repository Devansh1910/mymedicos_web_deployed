// TODO Implement this library.import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

class TextSizeNotifier extends ChangeNotifier {
  double _textScaleFactor = 1.0;

  double get textScaleFactor => _textScaleFactor;

  void setTextScaleFactor(double scale) {
    _textScaleFactor = scale;
    notifyListeners();
  }
}
