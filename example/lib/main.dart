import 'package:fconfigproxy_example/UserConfig.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {

  if (kIsWeb) {
    Hive.init('/');
  } else {
    final directory = await getApplicationSupportDirectory();
    Hive.init(directory.path);
  }

  await UserConfigHive.getUserConfig().initUserConfigHive();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLogin = UserConfigHive.getUserConfig().isLogin;
  @override
  void initState() {
    super.initState();

    UserConfigHive.getUserConfig().isLoginNotifier.addListener(() {
      setState(() {
        _isLogin = UserConfigHive.getUserConfig().isLogin;
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
                'UserName: ${UserConfigHive.getUserConfig().userName ?? "null"}',
              ),
              Text('Age: ${UserConfigHive.getUserConfig().age ?? "null"}'),
              Text('Is Login: $_isLogin'),
              ElevatedButton(
                onPressed: () {
                  UserConfigHive.getUserConfig().userName = 'John Doe';
                  UserConfigHive.getUserConfig().age = 30;
                },
                child: const Text('Set User Config'),
              ),
              ElevatedButton(
                onPressed: () {
                  UserConfigHive.getUserConfig().isLogin = !_isLogin;
                },
                child: Text('Login ${!_isLogin ? "Out" : "In"}'),
              ),
              ElevatedButton(
                onPressed: () {
                  UserConfigHive.getUserConfig().clearAll();
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
