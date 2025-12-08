import 'package:flutter/material.dart';
import 'ui/theme.dart';
import 'ui/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkHive',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
