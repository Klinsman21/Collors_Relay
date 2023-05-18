// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, unused_local_variable, non_constant_identifier_names

import 'dart:ui';

import 'package:circular_color_picker/circular_color_picker.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final info = NetworkInfo();
  var ip = " ";
  var PIN = " ";
  var socket = IOWebSocketChannel.connect(
    Uri.parse('ws://192.168.0.1/ws'),
  );
  var data = {
    'R': "",
    'G': "",
    'B': "",
  };
  var colorAppBackground = Colors.white;
  double colorBrightness = 50;

  @override
  Widget build(BuildContext context) {
    final data = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    ip = data['ip'];
    PIN = data['PIN'];
    return Scaffold(
        backgroundColor: colorAppBackground,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            // title: Image.asset('assets/title.png', fit: BoxFit.cover),
            title: Wrap(direction: Axis.horizontal, children: [
              Text(
                "Collors",
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                '®️',
                style: TextStyle(
                    fontFeatures: [FontFeature.superscripts()],
                    color: Colors.white,
                    fontSize: 12),
              ),
            ]),
            backgroundColor: Colors.black12,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.refresh),
                iconSize: 25,
                onPressed: () {
                  refreshSocket();
                },
              ),
              IconButton(
                icon: const Icon(Icons.power_settings_new),
                iconSize: 25,
                onPressed: () {
                  socket.sink.add("EFC0");
                },
              ),
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                iconSize: 25,
                onPressed: () {
                  socket.sink.add("EFC0");
                  Navigator.pop(context);
                },
              ),
            ]),
        body: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 100),
                child: CircularColorPicker(
                    radius: 140,
                    onColorChange: (value) {
                      setState(() {
                        colorAppBackground = Color.fromRGBO(
                            value.red, value.green, value.blue, 0.7);
                      });
                      var data = {
                        'r': value.red,
                        'g': value.green,
                        'b': value.blue
                      };
                      sendMessage(data);
                    },
                    pickerOptions: CircularColorPickerOptions(
                        initialColor: Colors.white,
                        callOnChangeFunctionOnEnd: false)),
              ),
              Slider(
                  value: colorBrightness,
                  max: 100,
                  divisions: 100,
                  label: "Brilho: ${colorBrightness.round()}%",
                  thumbColor: Color.fromARGB(255, 73, 73, 73),
                  activeColor: Color.fromARGB(255, 122, 122, 122),
                  inactiveColor: Color.fromARGB(255, 221, 221, 221),
                  autofocus: true,
                  onChanged: (double value) {
                    setState(() {
                      sendBrightness(value);
                      colorBrightness = value;
                    });
                  }),
              Text(
                "Ajuste de brilho",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 73, 73, 73),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color.fromARGB(255, 73, 73, 73),
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.amber,
          unselectedFontSize: 15,
          selectedFontSize: 15,
          onTap: (value) {
            if (value == 1) {
              Navigator.pushNamed(context, '/effects',
                  arguments: {'socket': socket, 'PIN': PIN});
            } else if (value == 2) {
              Navigator.pushNamed(context, '/reles',
                  arguments: {'socket': socket, 'PIN': PIN, 'IP': ip});
            } else if (value == 3) {
              Navigator.pushNamed(context, '/music',
                  arguments: {'socket': socket, 'PIN': PIN});
            } else if (value == 4) {
              Navigator.pushNamed(context, '/mic',
                  arguments: {'socket': socket, 'PIN': PIN});
            }
          },
          iconSize: 30,
          currentIndex: 0,
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.color_lens,
                  color: Colors.white,
                ),
                label: "Cores"),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.apps,
                color: Colors.white,
              ),
              label: "Efeitos",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.group_work,
                color: Colors.white,
              ),
              label: "Relés",
            ),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.queue_music,
                  color: Colors.white,
                ),
                label: "Música"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.mic,
                  color: Colors.white,
                ),
                label: "Microfone")
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sendBrightness(50);
      refreshSocket();
    });
  }

  void refreshSocket() async {
    socket.sink.close();
    socket = IOWebSocketChannel.connect(
      Uri.parse('ws://$ip:3731/ws'),
    );
    final ipv4 = await info.getWifiIP();
    var name = await info.getWifiGatewayIP();
    print('ws://$ip:3731/ws');
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
    print(finalData);
  }

  void sendBrightness(var value) {
    var data = "BRI$value";
    socket.sink.add("$PIN$data");
  }

  @override
  void dispose() {
    //socket.sink.close();
    super.dispose();
  }
}
