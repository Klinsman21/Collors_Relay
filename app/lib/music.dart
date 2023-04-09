// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, unused_local_variable, camel_case_types, sized_box_for_whitespace, prefer_typing_uninitialized_variables, non_constant_identifier_names, unnecessary_this

import 'dart:async';

import 'package:circular_color_picker/circular_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:music_visualizer/music_visualizer.dart';

class Music extends StatefulWidget {
  const Music({Key? key}) : super(key: key);

  @override
  State<Music> createState() => _MusicState();
}

class _MusicState extends State<Music> {
  AudioPlayer player = AudioPlayer();
  StreamSubscription<NoiseReading>? _noiseSubscription;
  final NoiseMeter _noiseMeter = NoiseMeter();
  String music = "";
  bool showAnimation = false;
  bool showControlls = false;
  bool playing = false;
  final List<Color> colors = [
    Color(0xff2e86de),
    Color(0xffff9f43),
    Color(0xffe84118),
    Color(0xff4cd137),
  ];
  List<StreamSubscription> streams = [];
  final List<int> duration = [900, 700, 600, 800, 500];
  Icon playIcon = Icon(Icons.play_circle);
  var PIN = " ";
  var socket;

  double min = 0;
  double max = 0;

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

    if (noiseReading.maxDecibel > 86) {
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

  @override
  void initState() {
    super.initState();
    streams.add(player.onPlayerComplete.listen((event) {
      print("FIM");
      socket.sink.add("EFC0");
      stop();
      setState(() {
        playIcon = Icon(Icons.play_circle);
        showAnimation = false;
        showControlls = false;
        playing = false;
      });
    }));
  }

  @override
  void dispose() {
    for (var it in streams) {
      it.cancel();
    }
    super.dispose();
    socket.sink.add("EFC0");
    socket.sink.add("${PIN}BRI50");
    player.stop();
    _noiseSubscription?.cancel();
  }

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
                Navigator.pop(context);
              })),
          title: Text(
            "Música",
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
            if (showAnimation)
              MusicVisualizer(
                barCount: 30,
                colors: colors,
                duration: duration,
              ),
            if (showControlls)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous),
                    iconSize: 40,
                    color: Colors.grey,
                    onPressed: () {
                      player.stop();
                      player.play(DeviceFileSource(music));
                    },
                  ),
                  IconButton(
                    icon: playIcon,
                    iconSize: 40,
                    color: Colors.grey,
                    onPressed: () async {
                      setState(() {
                        if (playing) {
                          player.pause();
                          showAnimation = false;
                          stop();
                          socket.sink.add("${PIN}BRI0");
                          playIcon = Icon(Icons.play_circle);
                          playing = !playing;
                        } else {
                          playIcon = Icon(Icons.pause_circle);
                          showAnimation = true;
                          start();
                          player.resume();
                          playing = !playing;
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    iconSize: 40,
                    color: Colors.grey,
                    onPressed: () {
                      player.stop();
                      player.play(DeviceFileSource(music));
                    },
                  ),
                ],
              ),
            TextButton.icon(
                label: Text(
                  'Selecionar Música',
                  style: TextStyle(color: Colors.black),
                ),
                icon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.amber),
                ),
                onPressed: () async {
                  await player.stop();
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(() {
                      music = result.files.single.path!;
                    });
                    await player.play(DeviceFileSource(music));
                    start();
                    String color = "RGB000036255";
                    socket.sink.add("$PIN$color");
                    setState(() {
                      playIcon = Icon(Icons.pause_circle);
                      playing = true;
                      showAnimation = true;
                      showControlls = true;
                    });
                  } else {
                    debugPrint("File not picked");
                  }
                  // await recorderController.record();
                }),
          ],
        ),
      ),
    );
  }
}
