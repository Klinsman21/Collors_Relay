// ignore_for_file: prefer_const_constructors, deprecated_member_use, sized_box_for_whitespace, non_constant_identifier_names, avoid_print, unused_local_variable, prefer_typing_uninitialized_variables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' show utf8;

class Setup extends StatefulWidget {
  const Setup({Key? key}) : super(key: key);
  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  late List<String> networks = [];
  bool wifiOK = false;
  bool showButtons = true;
  String wifiSSID = "";
  var deviceLoadSettings;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController PINController = TextEditingController();
  final TextEditingController wifiPassWordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.only(top: 70),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/colors.jpg"),
              fit: BoxFit.fill,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "Configuração do dispositivo",
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 350,
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: TextFormField(
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      onFieldSubmitted: (value) async {
                        print(value);
                      },
                      controller: nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black12,
                        labelText: 'Nome do Dispositivo',
                        labelStyle:
                            TextStyle(fontSize: 15, color: Colors.white),
                        enabledBorder: null,
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black26, width: 3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        suffixIcon: Icon(
                          Icons.create,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 350,
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: TextFormField(
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      maxLength: 4,
                      onFieldSubmitted: (value) async {
                        print(value);
                      },
                      controller: PINController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black12,
                        labelText: 'PIN do dispositivo',
                        labelStyle:
                            TextStyle(fontSize: 15, color: Colors.white),
                        enabledBorder: null,
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black26, width: 3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        suffixIcon: Icon(
                          Icons.lock,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "Selecione uma rede Wi-Fi abaixo",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                // if(showButtons)
                Container(
                  height: 160,
                  width: 350,
                  child: Scrollbar(
                      // showTrackOnHover: false,
                      thumbVisibility: true,
                      child: ListView.builder(
                          itemCount: networks.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black12,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: ListTile(
                                      trailing:
                                          const Icon(Icons.wifi_lock_rounded),
                                      title: Text(
                                        networks[index],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        SetPassword(networks[index]);
                                      },
                                    )));
                          })),
                ),
                if (wifiOK)
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      "Rede Wi-Fi selecionada: $wifiSSID",
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  ),
                Padding(
                    padding: EdgeInsets.only(top: 70),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        TextButton.icon(
                            label: Text(
                              'Voltar',
                              style: TextStyle(color: Colors.black),
                            ),
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                        TextButton.icon(
                            label: Text(
                              'Carregar WiFi',
                              style: TextStyle(color: Colors.black),
                            ),
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.black,
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            onPressed: () {
                              getNeworks();
                            }),
                        TextButton.icon(
                            label: Text(
                              'Salvar',
                              style: TextStyle(color: Colors.black),
                            ),
                            icon: Icon(
                              Icons.check,
                              color: Colors.black,
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            onPressed: () {
                              SetDevice();
                            }),
                      ],
                    ))
              ],
            ),
          ),
        ));
  }

  Future<void> SetPassword(String ssid) async {
    return showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Informe a senha do Wi-Fi'),
            content: TextField(
              autofocus: true,
              obscureText: true,
              controller: wifiPassWordController,
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancelar', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  setState(() {
                    showButtons = !showButtons;
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () async {
                  Navigator.pop(context);
                  await Future.delayed(const Duration(milliseconds: 500), () {
                    setState(() {
                      wifiSSID = ssid;
                      wifiOK = true;
                      showButtons = true;
                      print(wifiSSID);
                    });
                  });
                },
              ),
            ],
          );
        });
  }

  void sendSettings() async {
    final response = await http.post(
      Uri.parse('http://192.168.4.1:3731/setSettings'),
      body: {
        'name': nameController.text,
        'PIN': PINController.text,
        'ssid': wifiSSID,
        'ssidPassword': wifiPassWordController.text,
      },
    );
    //print(response);
  }

  void getNeworks() async {
    final response = await http.get(
      Uri.parse('http://192.168.4.1:3731/networks'),
    );
    String body = utf8.decode(response.bodyBytes);
    setState(() {
      networks = body.split(',');
      networks.removeLast();
    });
    print(networks[0]);
  }

  void getSettings() async {
    final response = await http.get(
      Uri.parse('http://192.168.4.1:3731/settings'),
    );
    //print(response.body);
    setState(() {
      deviceLoadSettings = jsonDecode(response.body);
      nameController.text = deviceLoadSettings['apName'];
      PINController.text = deviceLoadSettings['devicePIN'];
    });

    print(deviceLoadSettings['apName']);
  }

  Future<void> SetDevice() {
    return showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                'Deseja salvar as configurações e reiniciar o dispositivo?'),
            content: Text(
                "Após salvar conecte-se na mesma rede Wi-fi em que o dispositivo esteja conectado e clique em buscar"),
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
                child: const Text('Salvar'),
                onPressed: () {
                  sendSettings();
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/');
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getNeworks();
      getSettings();
    });
  }
}
