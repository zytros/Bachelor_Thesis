import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:scidart/numdart.dart';
import 'package:test/flutter_cube.dart';

import 'src/object.dart';

class Globals {
  Globals();

  late Object currentModel;
  late Object lowerModel;
  late Object upperModel;
  late Object baseModel;
  late Object debO;
  late List<List<double>> eigenVecs;
  late List<double> mean;
  List<double> eigVals = [];

  double baseSize = 0;
  double size = 0;
  double baseVertLift = 0;
  double vertLift = 0;
  double baseClWidth = 0;
  double clWidth = 0;
  double nippleDistance = 12;

  // scales x,y,z obj*scale = cube space
  List<double> scales = [0.011431561, 0.008130968, 0.007232266];

  // size, vertLift, clWidth
  List<double> stddevs = [50.187588073453, 40.423292736364, 25.940261854601];

  String obj = '';
  String mtl = '';
  late Image image;

  void setObject(Object o) {
    debO = o;
  }

  void initMean() async {
    String data = await rootBundle.loadString('mean.txt');
    List<String> lines = data.split('\n');
    mean = [];
    for (var i = 0; i < lines.length; i++) {
      if (lines[i] == '') continue;
      mean.add(double.parse(lines[i]));
    }
    debugPrint('initialized mean');
  }

  void initEigenVecs() async {
    String data = await rootBundle.loadString('eigVecs.csv');
    eigenVecs = [];
    List<String> lines = data.split('\n');
    for (int i = 0; i < lines.length; i++) {
      List<double> v = [];
      List<String> elems = lines[i].split(' ');
      for (int j = 0; j < elems.length; j++) {
        v.add(double.parse(elems[j]));
      }
      eigenVecs.add(v);
    }
    debugPrint('initialized eigenVecs');
  }

  void dummyObj() {
    baseModel = Object(
      fileName: 'assets/models/fitModel_Demo_Augmentation.obj',
      position: Vector3(-3, 1, 0),
      scale: Vector3(8, 8, 8),
      rotation: Vector3(180, 0, 0),
      visiable: true,
      lighting: true,
      backfaceCulling: false,
    );
  }
}

/*  
    base model
    torso1 = Object(
      fileName: 'assets/models/fitModel_Demo_Augmentation.obj',
      position: Vector3(-3, 1, 0),
      scale: Vector3(8, 8, 8),
      rotation: Vector3(180, 0, 0),
      visiable: true,
      lighting: true,
      backfaceCulling: false,
    );
*/

