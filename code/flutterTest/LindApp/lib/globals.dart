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
  List<int> breastIndices = [];
  List<Offset> line = [];
  List<int> breastLineIndicesRight = [];
  List<int> breastLineIndicesLeft = [];
  double screenwidth = 0;
  double screenheight = 0;
  ml.Vector meanVec = ml.Vector.fromList([]);
  ml.Matrix eigenVecsMat = ml.Matrix.fromList([]);
  ml.Vector eigValsVec = ml.Vector.fromList([]);
  ml.Vector baseEigVals = ml.Vector.fromList([]);

  double baseSize = 0;
  double size = 0;
  double baseVertLift = 0;
  double vertLift = 0;
  double baseClWidth = 0;
  double clWidth = 0;
  double nippleDistance = 20;
  double distCutoff = 5;

  Color baseColor = const Color.fromARGB(255, 111, 39, 145);
  Matrix4 transform = Matrix4.identity();

  final double cubeScale = 15 * 0.011431561;

  // size, vertLift, clWidth
  final List<double> stddevs = [
    50.187588073453,
    40.423292736364,
    25.940261854601
  ];

  void initBreasLineIndices() async {
    String idxRight = await rootBundle
        .loadString('assets/breast_indices/breastLineIndicesRight.txt');
    String idxLeft = await rootBundle
        .loadString('assets/breast_indices/breastLineIndicesLeft.txt');
    List<String> valuesRight = idxRight.split(', ');
    List<String> valuesLeft = idxLeft.split(', ');
    for (var i = 0; i < valuesRight.length; i++) {
      if (valuesRight[i] == '') continue;
      breastLineIndicesRight.add(int.parse(valuesRight[i]));
    }
    for (var i = 0; i < valuesLeft.length; i++) {
      if (valuesLeft[i] == '') continue;
      breastLineIndicesLeft.add(int.parse(valuesLeft[i]));
    }
    debugPrint(
        'initialized breast lines indices with lengths ${breastLineIndicesLeft.length} and ${breastLineIndicesRight.length}');
  }

  void initbreastIndices() async {
    String ind1 = await rootBundle
        .loadString('assets/breast_indices/leftBreastIdxLargeArea.txt');
    String ind2 = await rootBundle
        .loadString('assets/breast_indices/rightBreastIdxLargeArea.txt');
    List<String> lines1 = ind1.split('\n');
    List<String> lines2 = ind2.split('\n');
    breastIndices = [];
    for (var i = 0; i < lines1.length; i++) {
      if (lines1[i] == '') continue;
      breastIndices.add(int.parse(lines1[i]));
    }
    breastIndices.sort();
    for (var i = 0; i < lines2.length; i++) {
      if (lines2[i] == '') continue;
      breastIndices.add(int.parse(lines2[i]));
    }
    breastIndices.sort();
    breastIndices = breastIndices.toSet().toList();
    debugPrint('initialized indices with length ${breastIndices.length}');
  }

  void initOutline() async {
    String data1 = await rootBundle
        .loadString('assets/breast_indices/leftBreastIdxLargeAreaOutline.txt');
    String data2 = await rootBundle
        .loadString('assets/breast_indices/rightBreastIdxLargeAreaOutline.txt');
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
    String data = await rootBundle.loadString('assets/mean.txt');
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
    String data = await rootBundle.loadString('assets/eigVecs.csv');
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
