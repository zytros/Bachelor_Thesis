import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test/scanning_page_web.dart';
import 'package:test/util.dart';

import 'globals.dart';

late List<CameraDescription> _cameras;
Globals g = Globals();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: ScanningPageWeb(_cameras, g),
      ),
    );
  }
}

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScanningPageWeb(_cameras, g);
  }
}

class Imgdisp extends StatefulWidget {
  const Imgdisp({super.key});

  @override
  State<Imgdisp> createState() => _ImgdispState();
}

class _ImgdispState extends State<Imgdisp> {
  String data = '';
  Image image = Image.asset('assets/mountain.png');
  late Uint8List bytes;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              getImgHTTP('http://localhost:8080/').then((value) => setState(() {
                    image = Image.memory(stringToUint8List(value));
                  }));
            },
            child: const Text('GET'),
          ),
          Expanded(
            flex: 1,
            child: Image(
              image: image.image,
            ),
          )
        ],
      ),
    );
  }
}

class Webdeb extends StatelessWidget {
  const Webdeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                getMtlHTTP('http://localhost:8080/');
              },
              child: const Text('GET'),
            ),
            ElevatedButton(
              onPressed: () {
                sendImages('http://localhost:8080/', 'assets/mountain.png',
                    'assets/black.png', 'assets/white.png', 'ident', 12);
              },
              child: const Text('POST'),
            ),
            //const Imgdisp()
          ],
        ),
      ),
    );
    ;
  }
}
