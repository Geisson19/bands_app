import 'package:bands_app/screens/screens.dart';
import 'package:bands_app/themes/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BandApp());
}

class BandApp extends StatelessWidget {
  const BandApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Band App',
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
      theme: myTheme,
    );
  }
}
