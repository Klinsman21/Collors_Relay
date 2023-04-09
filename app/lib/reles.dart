// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, unused_local_variable, camel_case_types, sized_box_for_whitespace, prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import 'dart:math';

class Reles extends StatefulWidget {
  const Reles({Key? key}) : super(key: key);

  @override
  State<Reles> createState() => _RelesState();
}

class _RelesState extends State<Reles> {
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
  ];
  List<Color> switchColors = [
    Colors.red,
    Colors.red,
    Colors.red,
    Colors.red,
    Colors.red,
    Colors.red,
    Colors.red,
  ];
  var Releselected = 0;

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
          title: Text("Relés"),
          backgroundColor: Colors.black12,
        ),
        body: SingleChildScrollView(
          child: Wrap(
            spacing: 5, // to apply margin in the main axis of the wrap
            runSpacing: 5, // to apply margin in the cross axis of the wrap
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  button("Bomba 1", 1, 0, false, false),
                  button("Bomba 2", 2, 1, false, false),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  button("Bomba 3", 3, 2, false, false),
                  button("Bomba 4", 4, 3, false, false),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  button("Bomba 5", 5, 4, false, false),
                  button("Bomba 6", 6, 5, true, false),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  button("Desligar \n   Tudo", 7, 6, true, true),
                ],
              ),
            ],
          ),
        ));
  }

  void sendCommand(var command) {
    socket.sink.add("${PIN}CMD$command");
    print("${PIN}CMD$command");
  }

  Widget button(String name, int cmd, int controller, bool pulse, bool master) {
    return NeoPopButton(
      color: Colors.white,
      onTapUp: () {
        sendCommand(cmd);
        setState(() {
          switchControllers[controller] = !switchControllers[controller];
          if (switchControllers[controller]) {
            print(controller);
            switchColors[controller] = Colors.green;
          } else {
            switchColors[controller] = Colors.red;
          }
        });
      },
      onTapDown: () {
        if (pulse) {
          sendCommand(cmd);
          if (master) {
            for (var i = 0; i < 7; i++) {
              setState(() {
                switchColors[i] = Colors.red;
                switchControllers[i] = false;
              });
            }
          }
          setState(() {
            switchControllers[controller] = !switchControllers[controller];
            if (switchControllers[controller]) {
              print(controller);
              switchColors[controller] = Colors.green;
            } else {
              switchColors[controller] = Colors.red;
            }
          });
        }
      },
      bottomShadowColor: Colors.white,
      leftShadowColor: Colors.white,
      rightShadowColor: Colors.white,
      child: AvatarGlow(
        glowColor: Colors.green,
        endRadius: 60.0,
        duration: Duration(milliseconds: 700),
        repeat: true,
        showTwoGlows: true,
        animate: switchControllers[controller],
        repeatPauseDuration: Duration(milliseconds: 10),
        child: Material(
          // Replace this child with your own
          elevation: 8.0,
          shape: CircleBorder(),
          child: CircleAvatar(
              backgroundColor: Colors.grey[100],
              radius: 40.0,
              child: Text(
                name,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: switchColors[controller]),
              )),
        ),
      ),
    );
  }

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
