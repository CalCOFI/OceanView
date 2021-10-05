import 'dart:core';

class AppData {
  static final AppData _appData = new AppData._internal();

  Stopwatch stopwatch = Stopwatch();

  start () {
    stopwatch.start();
  }

  stop () {
    stopwatch.stop();
    stopwatch.reset();
  }

  double getElapsedSeconds() {
    return stopwatch.elapsedMilliseconds/1000;
  }

  factory AppData() {
    return _appData;
  }

  AppData._internal();
}

final appData = AppData();