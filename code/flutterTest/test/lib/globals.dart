import 'package:flutter/material.dart';

import 'src/object.dart';

class Globals {
  Globals();

  late Object currentModel;
  late Object lowerModel;
  late Object upperModel;
  late Object baseModel;

  double baseSize = 0;
  double size = 0;
  double baseVertLift = 0;
  double vertLift = 0;
  double baseClWidth = 0;
  double clWidth = 0;
  double nippleDistance = 12;

  String obj = '';
  String mtl = '';
  late Image image;
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
