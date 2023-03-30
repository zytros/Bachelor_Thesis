import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'globals.dart';

Globals? g;
late List<CameraDescription> _availableCameras;

class ScanningPageAndroid extends StatefulWidget {
  ScanningPageAndroid(List<CameraDescription> cams, Globals gl, {super.key}) {
    g = gl;
    _availableCameras = cams;
  }

  @override
  State<ScanningPageAndroid> createState() => _ScanningPageAndroidState();
}

class _ScanningPageAndroidState extends State<ScanningPageAndroid> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
