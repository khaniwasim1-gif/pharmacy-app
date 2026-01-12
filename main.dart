import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project1/splash_screen.dart';
import 'package:provider/provider.dart';

import 'Provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PharmacyProvider()..loadData(),
      child: PharmacyApp(),
    ),
  );
}

class PharmacyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anwar Pharmacy App',

      home: SplashScreen(),
    );
  }
}
