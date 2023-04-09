// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, unused_local_variable, camel_case_types, sized_box_for_whitespace, prefer_typing_uninitialized_variables, non_constant_identifier_names, unnecessary_this

import 'dart:async';

import 'package:circular_color_picker/circular_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:music_visualizer/music_visualizer.dart';
import 'package:avatar_glow/avatar_glow.dart';

class Microphone extends StatefulWidget {
  const Microphone({Key? key}) : super(key: key);

  @override
  State<Microphone> createState() => _MicrophoneState();
}

class _MicrophoneState extends State<Microphone> {
  StreamSubscription<NoiseReading>? _noiseSubscription;
  final NoiseMeter _noiseMeter = NoiseMeter();
  bool showAnimation = false;
  Color micColor = Colors.red;
  bool playing = false;
  bool animation = false;
  var PIN = " ";
  var socket;

  double min = 0;
  double max = 0;

  @override
  Widget build(BuildContext context) {
    final data = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    socket = data['socket'];
    PIN = data['PIN'];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: (() {
                animation = false;
                socket.sink.add("EFC0");
                stop();
                Navigator.pop(context);
              })),
          title: Text(
            "Microfone",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black12,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.color_lens),
              iconSize: 25,
              onPressed: () {
                colorPopUp();
              },
            ),
          ]),
      body: Container(
        padding: EdgeInsets.only(top: 50),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AvatarGlow(
              glowColor: micColor,
              endRadius: 90.0,
              duration: Duration(milliseconds: 2000),
              repeat: true,
              showTwoGlows: true,
              animate: animation,
              repeatPauseDuration: Duration(milliseconds: 100),
              child: Material(
                  // Replace this child with your own
                  elevation: 8.0,
                  shape: CircleBorder(),
                  child: GestureDetector(
                    onTap: () {
                      if (playing) {
                        setState(() {
                          playing = !playing;
                          animation = false;
                          socket.sink.add("EFC0");
                          stop();
                          micColor = Colors.red;
                        });
                      } else {
                        setState(() {
                          playing = !playing;
                          animation = true;
                          String color = "RGB000036255";
                          socket.sink.add("$PIN$color");
                          start();
                          micColor = Colors.green;
                        });
                      }

                      print("ok");
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[100],
                      radius: 40.0,
                      child: Icon(
                        Icons.mic,
                        color: micColor,
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  double map(double x, double in_min, double in_max, int out_min, int out_max) {
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
  }

  void onData(NoiseReading noiseReading) {
    if (min == 0) {
      setState(() {
        min = noiseReading.maxDecibel;
      });
    }
    if (max == 0) {
      setState(() {
        max = noiseReading.maxDecibel;
      });
    }
    if (noiseReading.maxDecibel > max) {
      setState(() {
        max = noiseReading.maxDecibel;
      });
    }
    if (noiseReading.maxDecibel < min) {
      setState(() {
        min = noiseReading.maxDecibel;
      });
    }

    if (noiseReading.maxDecibel > 75) {
      double value = map(noiseReading.maxDecibel, min, max, 0, 100);
      var data = "BRI$value";
      socket.sink.add("$PIN$data");
    } else {
      socket.sink.add("${PIN}BRI0");
    }
    setState(() {
      min = noiseReading.maxDecibel;
      max = noiseReading.maxDecibel;
    });
    print(min);
    print(max);
  }

  void start() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } catch (err) {
      print(err);
    }
  }

  void stop() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription!.cancel();
        _noiseSubscription = null;
      }
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    socket.sink.add("EFC0");
    socket.sink.add("${PIN}BRI50");
    _noiseSubscription?.cancel();
  }

  void sendMessage(var obj) {
    String finalData;
    String R = "";
    String G = "";
    String B = "";

    if (obj['r'] >= 0 && obj['r'] <= 9) {
      R += "00";
      R += obj['r'].toString();
    } else if (obj['r'] >= 10 && obj['r'] <= 99) {
      R += "0";
      R += obj['r'].toString();
    } else {
      R += obj['r'].toString();
    }

    if (obj['g'] >= 0 && obj['g'] <= 9) {
      G += "00";
      G += obj['g'].toString();
    } else if (obj['g'] >= 10 && obj['g'] <= 99) {
      G += "0";
      G += obj['g'].toString();
    } else {
      G += obj['g'].toString();
    }

    if (obj['b'] >= 0 && obj['b'] <= 9) {
      B += "00";
      B += obj['b'].toString();
    } else if (obj['b'] >= 10 && obj['b'] <= 99) {
      B += "0";
      B += obj['b'].toString();
    } else {
      B += obj['b'].toString();
    }

    finalData = R + G + B;
    finalData = "RGB$finalData";
    socket.sink.add("$PIN$finalData");
  }

  Future<void> colorPopUp() async {
    Color back = Colors.white;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione uma cor'),
          content: CircularColorPicker(
              radius: 65,
              onColorChange: (value) {
                setState(() {
                  back = Color.fromRGBO(value.red, value.green, value.blue, 1);
                });
                var data = {'r': value.red, 'g': value.green, 'b': value.blue};
                sendMessage(data);
              },
              pickerOptions: CircularColorPickerOptions(
                  initialColor: Colors.white, callOnChangeFunctionOnEnd: false),
              pickerDotOptions: PickerDotOptions(radius: 7, borderWidth: 2)),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            SizedBox(
              width: 40,
              height: 40,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: back, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
