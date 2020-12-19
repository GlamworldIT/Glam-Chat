import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:glam_chat/Pages/SignInPage.dart';

import 'Models/AdMobService.dart';

// void main() => runApp(MyApp());

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseAdMob.instance.initialize(appId: AdMobService().getAdMobAppId());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlamChat',
      theme: ThemeData(
        primaryColor: Colors.lightBlueAccent,
      ),
      home: LogIn(),
      debugShowCheckedModeBanner: false,
    );
  }
}
