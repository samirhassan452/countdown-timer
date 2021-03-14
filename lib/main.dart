import 'package:audioplayers/audio_cache.dart';
import 'package:countdown_timer/button_widget.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(), // Wrap your app
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CountDown',
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController controller;
  bool setTime = false;
  IconData iconPausePlay = Icons.play_arrow_rounded;

  String get timerString {
    Duration duration = controller.isDismissed
        ? controller.duration
        : controller.duration * controller.value;
    return '${(duration.inHours).toString().padLeft(2, '0')}:' +
        '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:' +
        '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 0,
      ),
    );

    // controller.addStatusListener((status) async {
    //   if (status != AnimationStatus.completed) {
    //     await playLocalAsset();
    //   }
    // });
    controller.addListener(() async {
      if (controller.value == 0) {
        await playLocalAsset();
        //print(controller.value);
      }
    });
  }

  Future<AudioPlayer> playLocalAsset() async {
    AudioCache cache = new AudioCache();
    //At the next line, DO NOT pass the entire reference such as assets/yes.mp3. This will not work.
    //Just pass the file name only.
    return await cache.play("time_sound.wav", volume: 10.0);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(size.width / 4);
    return Scaffold(
      backgroundColor: Colors.deepOrange[100],
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            children: <Widget>[
              buildVariableContainer(context),
              buildTimer(context, size),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      return !setTime
                          ? setTimer(context, size)
                          : buildTimerPlayer(size);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  ButtonWidget setTimer(BuildContext context, Size size) {
    return ButtonWidget(
      size: 30,
      icon: Icons.timer,
      iconColor: Color(0xFF0C2D48),
      backgroundColor: Colors.white,
      boxSize: Size(size.width * (1 / 4), size.height * (1 / 8)),
      onPressed: () {
        DatePicker.showTimePicker(
          context,
          onConfirm: (DateTime date) {
            if (date.hour == 0 && date.minute == 0 && date.second == 0) {
              setState(() {
                setTime = false;
              });
            } else if (date.hour != 0 || date.minute != 0 || date.second != 0)
              setState(() {
                //countDownTimer = date;
                controller.duration = Duration(
                  hours: date.hour,
                  minutes: date.minute,
                  seconds: date.second,
                );
                setTime = true;
              });
          },
        );
      },
    );
  }

  Row buildTimerPlayer(Size size) {
    iconPausePlay =
        controller.isAnimating ? Icons.pause : Icons.play_arrow_rounded;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ButtonWidget(
          icon: Icons.replay,
          size: 30,
          iconColor: Color(0xFF0C2D48),
          backgroundColor: Colors.white,
          boxSize: Size(
            size.width * (1 / 6),
            size.height * (1 / 12),
          ),
          onPressed: () {
            controller.reset();
            controller.reverse(from: 1.0);
          },
        ),
        SizedBox(width: 10),
        ButtonWidget(
          icon: iconPausePlay,
          size: 40,
          iconColor: Colors.white,
          backgroundColor: Color(0xFF0C2D48),
          boxSize: Size(size.width * (1 / 3), size.height * (1 / 7)),
          onPressed: () {
            if (controller.isAnimating) {
              controller.stop();
              setState(() {
                iconPausePlay = Icons.play_arrow_rounded;
              });
            } else {
              controller.reverse(
                  from: controller.value == 0.0 ? 1.0 : controller.value);
              setState(() {
                iconPausePlay = Icons.pause;
              });
            }
          },
        ),
        SizedBox(width: 10),
        ButtonWidget(
          icon: Icons.close,
          size: 30,
          iconColor: Color(0xFF0C2D48),
          backgroundColor: Colors.white,
          boxSize: Size(size.width * (1 / 6), size.height * (1 / 12)),
          onPressed: () {
            //controller.value = 0.0;
            controller.reset();
            controller.duration = Duration(
              hours: 0,
              minutes: 0,
              seconds: 0,
            );
            setState(() {
              setTime = false;
            });
          },
        ),
      ],
    );
  }

  Align buildTimer(BuildContext context, Size size) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildTimerText(context),
          Text(
            "Time Left".toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size.width / 8,
            ),
          ),
        ],
      ),
    );
  }

  Text buildTimerText(BuildContext context) {
    return Text(
      timerString,
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.width / 4.5,
        color: Colors.white,
      ),
    );
  }

  Align buildVariableContainer(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.deepOrange[300],
        height: controller.isDismissed
            ? MediaQuery.of(context).size.height
            : controller.value * MediaQuery.of(context).size.height,
      ),
    );
  }
}
