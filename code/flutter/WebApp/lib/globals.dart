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

  List<List<double>> xs = [
    [
      50.12743377685547,
      -0.31049561500549316,
      14.600205421447754,
      1.333493947982788,
      -6.932319641113281,
      -3.27310848236084,
      -34.485748291015625,
      6.325933933258057,
      -1.8899037837982178,
      -17.37732696533203,
      -9.518200874328613,
      -6.22232723236084,
      -8.545461654663086,
      -9.162025451660156,
      -2.3965272903442383,
      -2.4321370124816895,
      -2.045649766921997,
      9.266813278198242,
      4.265425205230713,
      -7.244007110595703,
      2.152892589569092,
      4.201935768127441,
      6.585594177246094,
      4.166678428649902,
      4.248940467834473,
      -1.0295194387435913,
      -12.907297134399414,
      -2.4979376792907715,
      0.4884466528892517,
      2.9225635528564453
    ],
    [
      41.06588363647461,
      12.865530014038086,
      20.965726852416992,
      0.7192802429199219,
      -6.932319641113281,
      -4.219675064086914,
      -34.346012115478516,
      13.084842681884766,
      -1.8899037837982178,
      -17.37732696533203,
      -9.518200874328613,
      -6.22232723236084,
      -8.545461654663086,
      -9.162025451660156,
      -2.3965272903442383,
      -2.4321370124816895,
      -2.045649766921997,
      9.266813278198242,
      4.265425205230713,
      -7.244007110595703,
      2.152892589569092,
      4.201935768127441,
      6.585594177246094,
      4.166678428649902,
      4.248940467834473,
      -1.0295194387435913,
      -12.907297134399414,
      -2.4979376792907715,
      0.4884466528892517,
      2.9225635528564453
    ],
    [
      35.873878479003906,
      20.163057327270508,
      24.236955642700195,
      0.6154223680496216,
      -6.932319641113281,
      -4.700808048248291,
      -34.43065643310547,
      17.1710205078125,
      -1.8899037837982178,
      -17.37732696533203,
      -9.518200874328613,
      -6.22232723236084,
      -8.545461654663086,
      -9.162025451660156,
      -2.3965272903442383,
      -2.4321370124816895,
      -2.045649766921997,
      9.266813278198242,
      4.265425205230713,
      -7.244007110595703,
      2.152892589569092,
      4.201935768127441,
      6.585594177246094,
      4.166678428649902,
      4.248940467834473,
      -1.0295194387435913,
      -12.907297134399414,
      -2.4979376792907715,
      0.4884466528892517,
      2.9225635528564453
    ],
    [
      32.8580322265625,
      24.13523292541504,
      25.86438751220703,
      0.7005290985107422,
      -6.932319641113281,
      -4.969066143035889,
      -34.61848068237305,
      19.693849563598633,
      -1.8899037837982178,
      -17.37732696533203,
      -9.518200874328613,
      -6.22232723236084,
      -8.545461654663086,
      -9.162025451660156,
      -2.3965272903442383,
      -2.4321370124816895,
      -2.045649766921997,
      9.266813278198242,
      4.265425205230713,
      -7.244007110595703,
      2.152892589569092,
      4.201935768127441,
      6.585594177246094,
      4.166678428649902,
      4.248940467834473,
      -1.0295194387435913,
      -12.907297134399414,
      -2.4979376792907715,
      0.4884466528892517,
      2.9225635528564453
    ],
    [
      30.94725227355957,
      26.48598289489746,
      26.540390014648438,
      0.8545689582824707,
      -6.932319641113281,
      -5.103184700012207,
      -34.83872985839844,
      21.3987979888916,
      -1.8899037837982178,
      -17.37732696533203,
      -9.518200874328613,
      -6.22232723236084,
      -8.545461654663086,
      -9.162025451660156,
      -2.3965272903442383,
      -2.4321370124816895,
      -2.045649766921997,
      9.266813278198242,
      4.265425205230713,
      -7.244007110595703,
      2.152892589569092,
      4.201935768127441,
      6.585594177246094,
      4.166678428649902,
      4.248940467834473,
      -1.0295194387435913,
      -12.907297134399414,
      -2.4979376792907715,
      0.4884466528892517,
      2.9225635528564453
    ],
    [
      29.659122467041016,
      27.935941696166992,
      26.75187873840332,
      1.028856873512268,
      -6.932319641113281,
      -5.176101207733154,
      -35.07464599609375,
      22.6202392578125,
      -1.8899037837982178,
      -17.37732696533203,
      -9.518200874328613,
      -6.22232723236084,
      -8.545461654663086,
      -9.162025451660156,
      -2.3965272903442383,
      -2.4321370124816895,
      -2.045649766921997,
      9.266813278198242,
      4.265425205230713,
      -7.244007110595703,
      2.152892589569092,
      4.201935768127441,
      6.585594177246094,
      4.166678428649902,
      4.248940467834473,
      -1.0295194387435913,
      -12.907297134399414,
      -2.4979376792907715,
      0.4884466528892517,
      2.9225635528564453
    ],
    [
      28.765588760375977,
      28.82048225402832,
      26.789241790771484,
      1.2089402675628662,
      -6.932319641113281,
      -5.221610069274902,
      -35.30158615112305,
      23.526391983032227,
      -1.8899037837982178,
      -17.37732696533203,
      -9.518200874328613,
      -6.22232723236084,
      -8.545461654663086,
      -9.162025451660156,
      -2.3965272903442383,
      -2.4321370124816895,
      -2.045649766921997,
      9.266813278198242,
      4.265425205230713,
      -7.244007110595703,
      2.152892589569092,
      4.201935768127441,
      6.585594177246094,
      4.166678428649902,
      4.248940467834473,
      -1.0295194387435913,
      -12.907297134399414,
      -2.4979376792907715,
      0.4884466528892517,
      2.9225635528564453
    ],
    [
      28.111286163330078,
      29.379899978637695,
      26.782608032226562,
      1.3911906480789185,
      -6.932319641113281,
      -5.248893737792969,
      -35.506744384765625,
      24.23890495300293,
      -1.8899037837982178,
      -17.37732696533203,
      -9.518200874328613,
      -6.22232723236084,
      -8.545461654663086,
      -9.162025451660156,
      -2.3965272903442383,
      -2.4321370124816895,
      -2.045649766921997,
      9.266813278198242,
      4.265425205230713,
      -7.244007110595703,
      2.152892589569092,
      4.201935768127441,
      6.585594177246094,
      4.166678428649902,
      4.248940467834473,
      -1.0295194387435913,
      -12.907297134399414,
      -2.4979376792907715,
      0.4884466528892517,
      2.9225635528564453
    ],
    [
      27.614896774291992,
      29.75214958190918,
      26.712905883789062,
      1.5655040740966797,
      -6.932319641113281,
      -5.26055908203125,
      -35.686519622802734,
      24.814735412597656,
      -1.8899037837982178,
      -17.37732696533203,
      -9.518200874328613,
      -6.22232723236084,
      -8.545461654663086,
      -9.162025451660156,
      -2.3965272903442383,
      -2.4321370124816895,
      -2.045649766921997,
      9.266813278198242,
      4.265425205230713,
      -7.244007110595703,
      2.152892589569092,
      4.201935768127441,
      6.585594177246094,
      4.166678428649902,
      4.248940467834473,
      -1.0295194387435913,
      -12.907297134399414,
      -2.4979376792907715,
      0.4884466528892517,
      2.9225635528564453
    ],
    [
      27.22561264038086,
      30.000411987304688,
      26.617643356323242,
      1.723348617553711,
      -6.932319641113281,
      -5.26615047454834,
      -35.85356140136719,
      25.29129409790039,
      -1.8899037837982178,
      -17.37732696533203,
      -9.518200874328613,
      -6.22232723236084,
      -8.545461654663086,
      -9.162025451660156,
      -2.3965272903442383,
      -2.4321370124816895,
      -2.045649766921997,
      9.266813278198242,
      4.265425205230713,
      -7.244007110595703,
      2.152892589569092,
      4.201935768127441,
      6.585594177246094,
      4.166678428649902,
      4.248940467834473,
      -1.0295194387435913,
      -12.907297134399414,
      -2.4979376792907715,
      0.4884466528892517,
      2.9225635528564453
    ]
  ];
}
