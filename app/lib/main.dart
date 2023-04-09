// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, import_of_legacy_library_into_null_safe, unused_local_variable

import 'package:collors/effects.dart';
import 'package:collors/music.dart';
import 'package:collors/microphone.dart';
import 'package:collors/reles.dart';
import 'package:collors/setup.dart';
import 'package:collors/home.dart';
import 'package:collors/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => Login(),
              '/home': (context) => Home(),
              '/setup': (context) => Setup(),
              '/effects': (context) => Effects(),
              '/music': (context) => Music(),
              '/mic': (context) => Microphone(),
              '/reles': (context) => Reles(),
              // '/third': (context) => const ThirdRoute(),
            },
          )));
}
