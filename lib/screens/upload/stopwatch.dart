import 'dart:async';

import 'package:flutter/material.dart';

class StopWatch extends StatefulWidget {

  @override
  _StopWatchState createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {

  bool recording = false;
  Stream<int>? timerStream;
  StreamSubscription<int>? timerSubscription;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';

  Stream<int> stopWatchStream() {
    StreamController<int> streamController = StreamController();
    Timer? timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer!.cancel();
        timer = null;
        counter = 0;
        streamController.close();
        recording = false;
      }
    }

    void tick(_) {
      counter++;
      streamController.add(counter);
      if (!recording) {
        stopTimer();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
      recording = true;
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }

  @override
  void dispose() {
    super.dispose();
    if (timerSubscription!=null){
      timerSubscription!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          onPressed: () {
            if (!recording) {
              timerStream = stopWatchStream();
              timerSubscription = timerStream!.listen((int newTick) {
                setState(() {
                  hoursStr = ((newTick / (60 * 60)) % 60)
                      .floor()
                      .toString()
                      .padLeft(2, '0');
                  minutesStr = ((newTick / 60) % 60)
                      .floor()
                      .toString()
                      .padLeft(2, '0');
                  secondsStr =
                      (newTick % 60).floor().toString().padLeft(2, '0');
                });
              });
            }
          },
          icon: Icon(Icons.not_started_rounded),
        ),
        Text(
          "$hoursStr:$minutesStr:$secondsStr",
          style: TextStyle(
            fontSize: 25.0,
          ),
        ),
        IconButton(
          onPressed: () {
            if (recording){
              timerSubscription!.cancel();
              //timerStream = null;
              setState(() {
                hoursStr = '00';
                minutesStr = '00';
                secondsStr = '00';
              });
            }
          },
          icon: Icon(Icons.stop_circle_sharp),
        )
      ],
    );
  }
}
