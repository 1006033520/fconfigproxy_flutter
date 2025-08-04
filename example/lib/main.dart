import 'package:fconfigproxy_example/UserConfig.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fconfigproxy/fconfigproxy.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {

  if (kIsWeb) {
    Hive.init('/');
  } else {
    final directory = await getApplicationSupportDirectory();
    Hive.init(directory.path);
  }

  await Hive.openBox("UserConfig");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLogin = UserConfig.getUserConfig().isLogin;
  @override
  void initState() {
    super.initState();

    UserConfig.getUserConfig().isLoginNotifier.addListener(() {
      setState(() {
        _isLogin = UserConfig.getUserConfig().isLogin;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: ListView(
            children: [
              Text(
                'UserName: ${UserConfig.getUserConfig().userName ?? "null"}',
              ),
              Text('Age: ${UserConfig.getUserConfig().age ?? "null"}'),
              Text('Is Login: $_isLogin'),
              ElevatedButton(
                onPressed: () {
                  UserConfig.getUserConfig().userName = 'John Doe';
                  UserConfig.getUserConfig().age = 30;
                },
                child: const Text('Set User Config'),
              ),
              ElevatedButton(
                onPressed: () {
                  UserConfig.getUserConfig().isLogin = !_isLogin;
                },
                child: Text('Login ${!_isLogin ? "Out" : "In"}'),
              ),
              ElevatedButton(
                onPressed: () {
                  UserConfig.getUserConfig().clearAll();
                },
                child: const Text('Clear All Config'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
