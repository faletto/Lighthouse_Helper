import 'package:flutter/material.dart';
import 'package:lighthouse_helper/qrcode_scanner.dart';

void main() {
  runApp(const MainWidget());
}

class MainWidget extends StatelessWidget {
  const MainWidget({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LightHouse Helper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: Home(),
      routes: {
        "/scanner" : (context) => QRScannerScreen()
      },
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
 

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: TextButton(onPressed: () => Navigator.pushNamed(context,"/scanner"), child: Text("QR Code scanner")),
    ),
    appBar: AppBar(
      title: Text("LightHouse Helper Application"),
    ),
  );
  }
}
