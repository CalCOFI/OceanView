import 'dart:async';

import 'package:flutter/material.dart';

/*
  Widget for stopwatch in UploadSession

  Start button starts the timerStream to count time lapsed.
  Stop button stops this timerStream.
  Both of them triggers the callback to send information back to UploadSession.
 */

class UploadStopwatch extends StatefulWidget {

  final Function() startCallback;
  final Function(DateTime, Duration) stopCallback;
  UploadStopwatch ({required this.startCallback, required this.stopCallback});

  @override
  _UploadStopwatchState createState() => _UploadStopwatchState();
}

class _UploadStopwatchState extends State<UploadStopwatch> {

  bool isRecording = false;
  Stream<int>? timerStream;
  StreamSubscription<int>? timerSubscription;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';
  DateTime _startTime = DateTime.now();

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
        isRecording = false;
      }
    }

    void tick(_) {
      counter++;
      streamController.add(counter);
      if (!isRecording) {
        stopTimer();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
      isRecording = true;
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
            if (!isRecording) {
              widget.startCallback();
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
            if (isRecording){

              var duration = Duration(
                hours: int.parse(hoursStr),
                minutes: int.parse(minutesStr),
                seconds: int.parse(secondsStr)
              );
              widget.stopCallback(_startTime, duration);

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
