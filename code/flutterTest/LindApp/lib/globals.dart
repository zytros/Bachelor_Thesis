import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ml_linalg/linalg.dart' as ml;
import 'package:test/flutter_cube.dart';

class Globals {
  Globals();

  late Object currentModel;
  late Object baseModel;
  List<int> outline = [];
  List<double> baseVec = [];
  List<int> brestIndices = [];
  List<Offset> line = [];
  double screenwidth = 0;
  double screenheight = 0;
  ml.Vector meanVec = ml.Vector.fromList([]);
  ml.Matrix eigenVecsMat = ml.Matrix.fromList([]);
  ml.Vector eigValsVec = ml.Vector.fromList([]);

  double baseSize = 0;
  double size = 0;
  double baseVertLift = 0;
  double vertLift = 0;
  double baseClWidth = 0;
  double clWidth = 0;
  double nippleDistance = 20;
  double distCutoff = 5;

  // rgba(111,39,145,255)
  Color baseColor = const Color.fromARGB(255, 111, 39, 145);
  Matrix4 transform = Matrix4.identity();

  // scales x,y,z obj*scale = cube space
  final List<double> scales = [0.011431561, 0.008130968, 0.007232266];
  final double cubeScale = 15;

  // size, vertLift, clWidth
  final List<double> stddevs = [
    50.187588073453,
    40.423292736364,
    25.940261854601
  ];

  String obj = '';
  String mtl = '';
  late Image image;

  void initBrestIndices() async {
    String ind1 = await rootBundle
        .loadString('breast_indices/leftBreastIdxLargeArea.txt');
    String ind2 = await rootBundle
        .loadString('breast_indices/rightBreastIdxLargeArea.txt');
    List<String> lines1 = ind1.split('\n');
    List<String> lines2 = ind2.split('\n');
    brestIndices = [];
    for (var i = 0; i < lines1.length; i++) {
      if (lines1[i] == '') continue;
      brestIndices.add(int.parse(lines1[i]));
    }
    brestIndices.sort();
    for (var i = 0; i < lines2.length; i++) {
      if (lines2[i] == '') continue;
      brestIndices.add(int.parse(lines2[i]));
    }
    brestIndices.sort();
    brestIndices = brestIndices.toSet().toList();
    debugPrint('initialized indices with length ${brestIndices.length}');
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
    List<double> mean = [];
    for (var i = 0; i < lines.length; i++) {
      if (lines[i] == '') continue;
      mean.add(double.parse(lines[i]));
    }
    meanVec = ml.Vector.fromList(mean);
    debugPrint('initialized mean');
  }

  void initEigenVecs() async {
    String data = await rootBundle.loadString('eigVecs.csv');
    List<List<double>> eigenVecs = [];
    List<String> lines = data.split('\n');
    for (int i = 0; i < lines.length; i++) {
      List<double> v = [];
      List<String> elems = lines[i].split(' ');
      for (int j = 0; j < elems.length; j++) {
        v.add(double.parse(elems[j]));
      }
      eigenVecs.add(v);
    }
    eigenVecsMat = ml.Matrix.fromList(eigenVecs);
    debugPrint('initialized eigenVecs');
  }
}
