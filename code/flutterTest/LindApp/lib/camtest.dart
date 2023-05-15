import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> _availableCameras;

class CameraWidget extends StatefulWidget {
  CameraWidget(List<CameraDescription> cams, {super.key}) {
    _availableCameras = cams;
  }

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController? _cameraController;
  List<DropdownMenuItem<int>> cameraNames = [];
  int idx = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    for (int i = 0; i < _availableCameras.length; i++) {
      cameraNames.add(DropdownMenuItem(
        value: i,
        child: Text(_availableCameras[i].name),
      ));
    }
  }

  void _initializeCamera() async {
    // Set the initial camera as the first available camera
    _cameraController =
        CameraController(_availableCameras[0], ResolutionPreset.max);

    // Initialize the camera
    await _cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _cameraController!.dispose();
    super.dispose();
  }

  void _selectCamera(int index) async {
    // Dispose of the old camera controller
    await _cameraController!.dispose();

    // Initialize the new camera controller
    _cameraController =
        CameraController(_availableCameras[index], ResolutionPreset.max);
    await _cameraController!.initialize();

    // Update the state to display the new camera preview
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: FloatingActionButton(
                  heroTag: 'back',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios),
                ),
              ),
              const Expanded(flex: 5, child: Text('Scanning')),
            ],
          ),
        ),
        Expanded(
          flex: 9,
          child: CameraPreview(_cameraController!),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              const Expanded(flex: 1, child: SizedBox()),
              Expanded(
                flex: 5,
                child: DropdownButton(
                  value: idx,
                  items: cameraNames,
                  onChanged: (int? value) {
                    setState(() {
                      idx = value!;
                      _selectCamera(idx);
                    });
                  },
                ),
              ),
              Expanded(
                flex: 5,
                child: FloatingActionButton(
                  heroTag: 'right',
                  onPressed: () {},
                  child: const Icon(Icons.camera_alt),
                ),
              ),
              const Expanded(flex: 5, child: SizedBox()),
              const Expanded(flex: 1, child: SizedBox()),
            ],
          ),
        )
      ],
    );
  }
}
