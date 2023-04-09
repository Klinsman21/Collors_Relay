// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, unused_local_variable, camel_case_types, sized_box_for_whitespace, prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'package:circular_color_picker/circular_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'dart:math';

class Effects extends StatefulWidget {
  const Effects({Key? key}) : super(key: key);

  @override
  State<Effects> createState() => _EffectsState();
}

class _EffectsState extends State<Effects> {
  Random random = Random();
  var PIN = " ";
  var socket;
  List<bool> switchControllers = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List<Color> colors = [
    Colors.redAccent,
    Colors.teal,
    Colors.green,
    Colors.amber,
    Colors.blue,
    Colors.purple,
    Colors.grey
  ];
  var effectSelected = 0;

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
                  socket.sink.add("EFC0");
                  Navigator.pop(context);
                })),
            title: Text("Efeitos"),
            backgroundColor: Colors.black12,
            ),
        body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  effect("Flash", "EFC1", 1),
                  effect("FadeIn", "EFC5", 2),
                  effect("Oscilante", "EFC3", 3),
                  effect("Cor Aleatória", "EFC2", 4),
                  effect("Rainbow", "EFC4", 5),
                ],
              ),
            )));
  }

  void updateSwitchs() {
    if (effectSelected == 0) {
      for (var element in switchControllers) {
        setState(() {
          element = false;
        });
      }
    } else {
      int sw = effectSelected - 1;
      setState(() {
        switchControllers[sw] = true;
      });
      for (var i = 0; i < switchControllers.length; i++) {
        if (i != sw) {
          setState(() {
            switchControllers[i] = false;
          });
        }
      }
    }
  }

  Widget effect(name, command, controller) {
    return Padding(
        padding: EdgeInsets.only(top: 30),
        child: Container(
            width: 400,
            height: 80,
            color: colors[random.nextInt(colors.length)],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("    $name",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    )),
                Row(
                  children: [
                    Switch(
                      value: switchControllers[controller],
                      onChanged: (value) {
                        setState(() {
                          switchControllers[controller] =
                              !switchControllers[controller];
                          if (switchControllers[controller]) {
                            effectSelected = controller + 1;
                          } else {
                            effectSelected = 0;
                          }
                          socket.sink.add("$command");
                        });
                        updateSwitchs();
                      },
                      activeTrackColor: Colors.white,
                      activeColor: Colors.black54,
                    ),
                    TouchRippleEffect(
                        borderRadius: BorderRadius.circular(5),
                        rippleColor: Colors.white60,
                        onTap: () {},
                        child: Container(
                            width: 100,
                            height: 80,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(
                              children: [
                                IconButton(
                                  iconSize: 24.0,
                                  icon: Icon(
                                    Icons.color_lens,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  onPressed: () {
                                    colorPopUp();
                                  },
                                ),
                                Text(
                                  "Cor",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ))),
                    TouchRippleEffect(
                        borderRadius: BorderRadius.circular(5),
                        rippleColor: Colors.white60,
                        onTap: () {
                          setEffect(1);
                        },
                        child: Container(
                            width: 50,
                            height: 80,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(
                              children: [
                                IconButton(
                                  iconSize: 24.0,
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  onPressed: () {
                                    setEffect(1);
                                  },
                                ),
                                Text(
                                  "Speed",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ))),
                    TouchRippleEffect(
                        borderRadius: BorderRadius.circular(5),
                        rippleColor: Colors.white60,
                        onTap: () {
                          setEffect(0);
                        },
                        child: Container(
                            width: 50,
                            height: 80,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(
                              children: [
                                IconButton(
                                  iconSize: 24.0,
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  onPressed: () {
                                    setEffect(0);
                                  },
                                ),
                              ],
                            ))),
                  ],
                )
              ],
            )));
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

  void setEffect(var opt) {
    socket.sink.add("SPD$opt");
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

  // void refreshSocket() async {
  //   socket.sink.close();
  //   socket = IOWebSocketChannel.connect(
  //     Uri.parse('ws://$ip:3731/ws'),
  //   );
  //   // final ipv4 = await info.getWifiIP();
  //   // var name = await info.getWifiGatewayIP();
  //   print('ws://$ip:3731/ws');
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    // socket.sink.close();
    super.dispose();
  }
}
