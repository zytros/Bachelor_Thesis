import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;
late int _cameraIndex;

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  CameraApp(List<CameraDescription> cams, int idx, {Key? key})
      : super(key: key) {
    _cameras = cams;
    _cameraIndex = idx;
  }

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[_cameraIndex], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return CameraPreview(controller);
  }
}
