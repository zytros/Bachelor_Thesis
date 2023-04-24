import 'dart:math';

import 'package:flutter/material.dart';
import 'package:test/util.dart';

import 'globals.dart';

Globals g = Globals();

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: DebugPage(),
      ),
    );
  }
}

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          OutlinedButton(
            onPressed: () async {
              g.initEigenVecs();
              g.initMean();
              g.dummyObj();
            },
            child: const Text('init'),
          ),
          OutlinedButton(
            onPressed: () async {},
            child: const Text('Debug'),
          ),
          OutlinedButton(
            onPressed: () {
              List<List<int>> mat = [];
              List<int> vec = [];
              for (int i = 0; i < 10000; i++) {
                List<int> l = [];
                for (int j = 0; j < 30; j++) {
                  l.add(max(i, j));
                }
                mat.add(l);
              }
              for (int i = 0; i < 30; i++) {
                vec.add(i);
              }
              List<int> res = [];
              for (int i = 0; i < 10000; i++) {
                int acc = 0;
                for (int j = 0; j < 30; j++) {
                  acc += mat[i][j] * vec[j];
                }
                res.add(acc);
              }
              debugPrint(res.length.toString());
            },
            child: const Text('dummy'),
          )
        ],
      ),
    );
  }
}
