import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:test/flutter_cube.dart';

class Globals {
  Globals();

  late Object currentModel;
  late Object baseModel;
  late Object debO;
  late List<List<double>> eigenVecs;
  late List<double> mean;
  List<int> outline = [];
  List<double> baseVec = [];
  List<int> indices = [];
  List<double> eigVals = [];

  double baseSize = 0;
  double size = 0;
  double baseVertLift = 0;
  double vertLift = 0;
  double baseClWidth = 0;
  double clWidth = 0;
  double nippleDistance = 12;
  double distCutoff = 5;

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

  void initIndices() async {
    String ind1 = await rootBundle
        .loadString('breast_indices/leftBreastIdxLargeArea.txt');
    String ind2 = await rootBundle
        .loadString('breast_indices/rightBreastIdxLargeArea.txt');
    List<String> lines1 = ind1.split('\n');
    List<String> lines2 = ind2.split('\n');
    indices = [];
    for (var i = 0; i < lines1.length; i++) {
      if (lines1[i] == '') continue;
      indices.add(int.parse(lines1[i]));
    }
    indices.sort();
    for (var i = 0; i < lines2.length; i++) {
      if (lines2[i] == '') continue;
      indices.add(int.parse(lines2[i]));
    }
    indices.sort();
    indices = indices.toSet().toList();
    debugPrint('initialized indices with length ${indices.length}');
  }

  void initOutline() async {
    String data1 = await rootBundle
        .loadString('breast_indices/leftBreastIdxLargeAreaOutline.txt');
    String data2 = await rootBundle
        .loadString('breast_indices/rightBreastIdxLargeAreaOutline.txt');
    List<String> lines1 = data1.split('\n');
    List<String> lines2 = data2.split('\n');
    outline = [];
    for (var i = 0; i < lines1.length; i++) {
      if (lines1[i] == '') continue;
      outline.add(int.parse(lines1[i]));
    }
    for (var i = 0; i < lines2.length; i++) {
      if (lines2[i] == '') continue;
      outline.add(int.parse(lines2[i]));
    }
    debugPrint('initialized outline with length ${outline.length}');
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
