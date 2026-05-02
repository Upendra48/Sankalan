import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trash_map/mapscreen.dart';
import 'package:trash_map/pages/welcomepage.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate some initialization process (e.g., loading assets, fetching data).
    Future.delayed(Duration(seconds: 5)).then((value) => Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => WelcomePage())));
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(
        child: Container(
          height: 200.0,
          width: 200.0,
          child: LottieBuilder.asset('assets/animassets/splashanimation.json'),
        ),
      ),
    );
  }
}

