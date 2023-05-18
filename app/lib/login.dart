// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, unused_local_variable, annotate_overrides, prefer_final_fields, sort_child_properties_last, non_constant_identifier_names, prefer_const_declarations, depend_on_referenced_packages, prefer_is_empty, avoid_unnecessary_containers, use_build_context_synchronously, prefer_typing_uninitialized_variables
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'package:lan_scanner/lan_scanner.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final controller = TextEditingController();
  final storage = FlutterSecureStorage();
  bool searchProgress = false;
  var subTitle = "";
  var passwordVisibility = false;
  var testerVisibility = false;
  var selectedDevice = "";
  var DevicePIN = "";
  var socket;
  String selectedDeviceName = "";
  List<String> deviceList = [];
  List<String> deviceListIP = [];
  Map<String, String> storageDevices = {};
  double progressValue = 0;

  int count = 0;

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
  );

  final preFilledWidget = Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Container(
        width: 56,
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 70),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/colors.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: [
            Wrap(direction: Axis.horizontal, children: [
              Text(
                "Collors",
                style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                '®️',
                style: TextStyle(
                    fontFeatures: [FontFeature.superscripts()],
                    color: Colors.white,
                    fontSize: 18),
              ),
            ]),
            Text(
              subTitle,
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: deviceList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                trailing: const Icon(Icons.lightbulb),
                                title: Text(
                                  deviceList[index],
                                  style: TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                  print(deviceListIP[index]);
                                  selectedDevice = deviceListIP[index];
                                  selectedDeviceName = deviceList[index];
                                  setState(() {
                                    passwordVisibility = !passwordVisibility;
                                  });
                                },
                              )));
                    })),
            if (searchProgress) // loading progress
              Padding(
                padding: EdgeInsets.only(bottom: 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LinearProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black38),
                      value: progressValue,
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          "Buscando ${(progressValue * 100).round()}%",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ))
                  ],
                ),
              ),
            if (!passwordVisibility)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                //crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: TextButton.icon(
                        label: Text(
                          'Buscar Dispositivos',
                          style: TextStyle(color: Colors.black),
                        ),
                        icon: Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                        ),
                        onPressed: () async {
                          await storage.deleteAll();
                          SearchDevices(context);
                          // Navigator.pushNamed(context, '/home');
                        }),
                  ),
                  if (testerVisibility)
                    Padding(
                      padding: EdgeInsets.only(bottom: 100),
                      child: TextButton.icon(
                          label: Text(
                            'Testar Dispositivo',
                            style: TextStyle(color: Colors.black),
                          ),
                          icon: Icon(
                            Icons.device_hub,
                            color: Colors.black,
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                          ),
                          onPressed: () {
                            Login("1234", "192.168.4.1", context);
                          }),
                    ),
                ],
              ),
            if (passwordVisibility)
              Text(
                "Informe o PIN de acesso:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (passwordVisibility)
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(seconds: 3),
                child: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 100),
                  child: Pinput(
                    autofocus: true,
                    obscureText: true,
                    length: 4,
                    pinAnimationType: PinAnimationType.slide,
                    controller: controller,
                    focusNode: FocusNode(),
                    defaultPinTheme: defaultPinTheme,
                    preFilledWidget: null,
                    keyboardType: TextInputType.number,
                    keyboardAppearance: Brightness.dark,
                    onCompleted: (value) {
                      print(value);
                      DevicePIN = value;
                      Login(DevicePIN, selectedDevice, context);
                      controller.clear();
                      setState(() {
                        passwordVisibility = !passwordVisibility;
                      });
                    },
                    onSubmitted: ((value) {
                      setState(() {
                        passwordVisibility = !passwordVisibility;
                      });
                    }),
                  ),
                ),
              ),
            Text("Version: 3.0.0", style: TextStyle(
              color: Colors.white
            ),),
            ],
        ),
      ),
    );
  }

  void SearchDevices(BuildContext context) async {
    final scanner = LanScanner();
    var wifiIP = await NetworkInfo().getWifiIP();
    var subnet = ipToCSubnet(wifiIP!);
    if (subnet == "192.168.4") {
      await storage.deleteAll();
      Navigator.pushNamed(context, '/setup');
    } else {
      setState(() {
        searchProgress = true;
        deviceList.clear();
      });
      final stream = scanner.icmpScan(subnet, progressCallback: (progress) {
        // print('Progress: $progress');
        setState(() {
          progressValue = progress;
        });
        if (progress == 1.0) {
          if (deviceList.length == 0) {
            SearchStatusAlert(0);
          }
          setState(() {
            searchProgress = false;
            subTitle = "Dispositivos encontrados: ${deviceList.length}";
          });
          //listDevices();
        }
      });

      stream.listen((HostModel device) async {
        final response = await http.get(Uri.parse("http://${device.ip}:3731/"));
        setState(() {
          deviceList.add(response.body.toString());
          deviceListIP.add(device.ip);
        });
        print("Found host: ${device.ip}");
      });
    }
  }

  void Login(String pin, String ip, BuildContext context) async {
    var wifiIP = await NetworkInfo().getWifiIP();
    var subnet = ipToCSubnet(wifiIP!);
    final response =
        await http.get(Uri.parse("http://$ip:3731/login?pin=$pin"));

    if (response.body == "true") {
      if (subnet != "192.168.4") {
        await storage.write(key: selectedDeviceName, value: ip);
      }
      Navigator.pushNamed(context, '/home', arguments: {'ip': ip, 'PIN': pin});
    } else {
      IncorretPINAlert();
    }
    // setState(() {
    //   deviceList.add(response.body.toString());
    // });
  }

  Future<void> IncorretPINAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('PIN Incorreto'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[Text('Tente novamente')],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  passwordVisibility = !passwordVisibility;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> SetupAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
              'Antes de configurar o dispositivo pela primeira vez execute os passos abaixo:'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                    '1- Certifique-se que o dispositivo Collors esteja devidamente ligado;\n'),
                Text(
                    '2- O dispositivo Collors irá criar um ponto de acesso chamado "Collors" seguido de um número;\n'),
                Text(
                    '3- É fundamental que o seu smartphone esteja conectado no ponto de acesso Wi-Fi gerado;')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Continuar'),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  Future<void> SearchStatusAlert(var type) async {
    if (type == 0) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Nenhum dispositivo Collors encontrado!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[Text('Tente novamente')],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {});
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var wifiIP = await NetworkInfo().getWifiIP();
      var subnet = ipToCSubnet(wifiIP!);
      if (subnet == "192.168.4") {
        setState(() {
          testerVisibility = !testerVisibility;
        });
      }
      Map<String, String> devicesInMemory = await storage.readAll();
      // await storage.write(key: "teste", value: "192.168.0.50");
      setState(() {
        // storageDevices = storage.getItem('devices');
        devicesInMemory.forEach(((key, value) {
          deviceList.add(key);
          deviceListIP.add(value);
        }));
      });
      print(devicesInMemory);
    });
  }

  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
