import 'package:bands_app/screens/screens.dart';
import 'package:bands_app/services/socket_service.dart';
import 'package:bands_app/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const BandApp());
}

class BandApp extends StatelessWidget {
  const BandApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SocketService(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Band App',
        initialRoute: StatusScreen.routeName,
        routes: {
          HomeScreen.routeName: (context) => const HomeScreen(),
          StatusScreen.routeName: (context) => const StatusScreen(),
        },
        theme: myTheme,
      ),
    );
  }
}
