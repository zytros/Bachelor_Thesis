import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test/globals.dart';

Widget centerShow = ChangeCamera();
late CameraPreview _cameraPreview;
late CameraController _controller;
Globals? g;
late List<CameraDescription> _cameras;
List<String> imgPaths = ['', '', '', ''];
int stage = 0;
List<String> instrs = [
  'Full body Picture',
  'Right side Picture',
  'Left side Picture',
  'Check your Pictures and send them'
];
bool first = true;

class ChangeCamera extends StatefulWidget {
  const ChangeCamera({super.key});

  @override
  State<ChangeCamera> createState() => _ChangeCameraState();
}

class _ChangeCameraState extends State<ChangeCamera> {
  List<DropdownMenuItem<int>> camDesc = [];

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      setState(() {
        g!.camera = g!.camera == 0 ? 1 : 0;
      });
      // pop this page and go back to the previous one
      Navigator.pop(context);
    }

    if (first) {
      first = false;
      for (int i = 0; i < _cameras.length; i++) {
        camDesc.add(
          DropdownMenuItem<int>(
            value: i,
            child: Text(_cameras[i].name),
          ),
        );
      }
    }

    for (var element in camDesc) {
      debugPrint(element.value.toString());
    }
    debugPrint(camDesc.toString());

    // return dropdown menu for web to select a camera
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Camera'),
      ),
      body: DropdownButton<int>(
        value: g!.camera,
        items: camDesc,
        onChanged: (int? value) {
          setState(
            () {
              g!.camera = value!;
              _controller =
                  CameraController(_cameras[g!.camera], ResolutionPreset.max);
              _cameraPreview = CameraPreview(_controller);
              centerShow = _cameraPreview;
            },
          );
        },
      ),
    );
  }
}

Text t = Text(
  instrs[stage],
  textScaleFactor: 3,
);

class DisplayImages extends StatefulWidget {
  const DisplayImages({super.key});

  @override
  State<DisplayImages> createState() => _DisplayImagesState();
}

class _DisplayImagesState extends State<DisplayImages> {
  @override
  Widget build(BuildContext context) {
    //changed from List<Widget> to List<Imgae>
    List<Image> imgDisp;
    if (kIsWeb) {
      imgDisp = [
        Image.network(imgPaths[2]),
        Image.network(imgPaths[0]),
        Image.network(imgPaths[1])
      ];
    } else {
      imgDisp = [
        Image.file(File(imgPaths[2])),
        Image.file(File(imgPaths[0])),
        Image.file(File(imgPaths[1]))
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Display Images'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  child: imgDisp[0],
                ),
                Expanded(
                  child: imgDisp[1],
                ),
                Expanded(
                  child: imgDisp[2],
                ),
              ],
            ),
          ),
          const Text('What is the distance between your Nipples?'),
          Slider(
            label: 'Distance in cm: ${g!.nippleDistance.round().toString()}',
            value: g!.nippleDistance,
            divisions: 38,
            min: 12,
            max: 50,
            onChanged: (value) {
              setState(() {
                g!.nippleDistance = value;
              });
            },
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      imgPaths = ['', '', '', ''];
                      stage = 0;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Retake Pictures'),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: implement send
                    Navigator.of(context).pop();
                  },
                  child: const Text('Send Pictures'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ImageDisplayer extends StatefulWidget {
  const ImageDisplayer({super.key});

  @override
  State<ImageDisplayer> createState() => _ImageDisplayerState();
}

class _ImageDisplayerState extends State<ImageDisplayer> {
  @override
  Widget build(BuildContext context) {
    Widget imgDisp;
    if (kIsWeb) {
      imgDisp = Image.network(imgPaths[stage]);
    } else {
      imgDisp = Image.file(File(imgPaths[stage]));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Display Image'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: imgDisp,
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Retake Picture'),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(
                      () {
                        stage++;
                        //stage = stage == 3 ? 3 : stage++;
                      },
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Take next Picture'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class StateWrapper extends StatefulWidget {
  const StateWrapper({super.key});

  @override
  State<StateWrapper> createState() => _StateWrapperState();
}

class _StateWrapperState extends State<StateWrapper> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ScanningPage extends StatefulWidget {
  ScanningPage(List<CameraDescription> cams, Globals gl, {super.key}) {
    _cameras = cams;
    g = gl;
  }

  @override
  State<ScanningPage> createState() => _ScanningPageState();
}

class _ScanningPageState extends State<ScanningPage> {
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    for (var c in _cameras) {
      debugPrint(c.name);
    }
    _controller = CameraController(_cameras[g!.camera], ResolutionPreset.max);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }

    _cameraPreview = CameraPreview(_controller);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanning'),
      ),
      body: Column(
        children: [
          t,
          Expanded(
            flex: 7,
            child: CameraPreview(_controller),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'btn_takePic',
                  onPressed: () async {
                    final image = await _controller.takePicture();
                    debugPrint(image.path);
                    imgPaths[stage] = image.path;
                    final val = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const ImageDisplayer();
                        },
                      ),
                    );
                    setState(
                      () {
                        debugPrint(stage.toString());
                        t = Text(
                          instrs[stage],
                          textScaleFactor: 3,
                        );
                      },
                    );
                  },
                  child: const Icon(Icons.camera_alt),
                ),
                FloatingActionButton(
                  heroTag: 'btn_showPic',
                  child: const Icon(Icons.slideshow_rounded),
                  onPressed: () async {
                    final val = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const DisplayImages();
                        },
                      ),
                    );
                    setState(() {
                      debugPrint(stage.toString());
                      t = Text(
                        instrs[stage],
                        textScaleFactor: 3,
                      );
                    });
                  },
                ),
                FloatingActionButton(
                  heroTag: 'btn_swapCam',
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Icon(Icons.switch_camera),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> cams() async {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
  }
}
