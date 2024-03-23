import 'dart:async';

import 'package:flutter/material.dart';

class ClockProvider extends ChangeNotifier {
  DateTime _dateTime = DateTime.now();
  late Timer _timer;

  ClockProvider() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _dateTime = DateTime.now();
      notifyListeners();
    });
  }

  DateTime get dateTime => _dateTime;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
