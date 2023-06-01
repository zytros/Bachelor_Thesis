import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:test/uploadImages.dart';
import 'package:test/util.dart';

import 'globals.dart';

late List<CameraDescription> _availableCameras;
List<String> instrs = [
  'Take a Full body Picture',
  'Take a Right side Picture',
  'Take a Left side Picture',
  'Check your Pictures and send them'
];
int stage = 0;
Globals? g;
List<String> imgPaths = ['', '', '', ''];
bool takePic = false;
bool checkPic = true;

class ScanningPageWeb extends StatefulWidget {
  ScanningPageWeb(List<CameraDescription> cams, Globals gl, {super.key}) {
    _availableCameras = cams;
    g = gl;
  }

  @override
  _ScanningPageWebState createState() => _ScanningPageWebState();
}

class _ScanningPageWebState extends State<ScanningPageWeb> {
  CameraController? _cameraController;
  List<DropdownMenuItem<int>> cameraNames = [];
  int idx = 0;
  Widget instrText = Text(instrs[0], textScaleFactor: 2);

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
    _cameraController =
        CameraController(_availableCameras[0], ResolutionPreset.max);
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
    await _cameraController!.dispose();
    _cameraController =
        CameraController(_availableCameras[index], ResolutionPreset.max);
    await _cameraController!.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: FloatingActionButton.extended(
                      backgroundColor: g!.baseColor,
                      heroTag: 'back',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text('Scanning', textScaleFactor: 2),
                ),
                Expanded(flex: 5, child: instrText),
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
                  child: Center(
                    child: FloatingActionButton.extended(
                      backgroundColor: g!.baseColor,
                      heroTag: 'btn_takePic',
                      onPressed: takePic
                          ? null
                          : () async {
                              final image =
                                  await _cameraController!.takePicture();
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
                                  instrText = Text(
                                    instrs[stage],
                                    textScaleFactor: 2,
                                  );
                                },
                              );
                            },
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Take Picture',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Center(
                    child: FloatingActionButton.extended(
                      backgroundColor: g!.baseColor,
                      heroTag: 'btn_uploadPic',
                      onPressed: () async {
                        if (kIsWeb) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return UploadPage(g!);
                              },
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.upload_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Upload Pictures',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Center(
                    child: FloatingActionButton.extended(
                      backgroundColor: g!.baseColor,
                      heroTag: 'btn_showPics',
                      icon: const Icon(
                        Icons.slideshow_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Show Pictures',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: checkPic
                          ? null
                          : () async {
                              final val = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return const DisplayImages();
                                  },
                                ),
                              );
                              setState(() {
                                instrText = Text(
                                  instrs[stage],
                                  textScaleFactor: 3,
                                );
                              });
                            },
                    ),
                  ),
                ),
                const Expanded(flex: 1, child: SizedBox()),
              ],
            ),
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
    Widget imgDisp = Image.network(imgPaths[stage]);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: imgDisp,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: FloatingActionButton.extended(
                    backgroundColor: g!.baseColor,
                    heroTag: 'btn_retakePic',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    label: const Text(
                      'Retake Picture',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: FloatingActionButton.extended(
                    backgroundColor: g!.baseColor,
                    heroTag: 'btn_nextPic',
                    onPressed: () {
                      setState(
                        () {
                          stage++;
                          if (stage == 3) {
                            takePic = true;
                            checkPic = false;
                          }
                          //stage = stage == 3 ? 3 : stage++;
                        },
                      );
                      Navigator.of(context).pop();
                    },
                    label: const Text(
                      'Take next Picture',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class DisplayImages extends StatefulWidget {
  const DisplayImages({super.key});

  @override
  State<DisplayImages> createState() => _DisplayImagesState();
}

class _DisplayImagesState extends State<DisplayImages> {
  @override
  Widget build(BuildContext context) {
    List<Image> imgDisp = [
      Image.network(imgPaths[2]),
      Image.network(imgPaths[0]),
      Image.network(imgPaths[1])
    ];

    return Scaffold(
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
          const Text('What is the distance between your Nipples?',
              textScaleFactor: 2),
          Slider(
            label: 'Distance in cm: ${g!.nippleDistance.round().toString()}',
            value: g!.nippleDistance,
            divisions: 15,
            min: 15,
            max: 30,
            onChanged: (value) {
              setState(() {
                g!.nippleDistance = value;
              });
            },
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: FloatingActionButton.extended(
                      backgroundColor: g!.baseColor,
                      heroTag: 'btn_retakePics',
                      onPressed: () {
                        setState(() {
                          imgPaths = ['', '', '', ''];
                          stage = 0;
                          takePic = false;
                          checkPic = true;
                        });
                        Navigator.of(context).pop();
                      },
                      label: const Text(
                        'Retake Pictures',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: FloatingActionButton.extended(
                      backgroundColor: g!.baseColor,
                      heroTag: 'btn_SendPics',
                      onPressed: () {
                        String ident = getIdentifier();
                        int nd = g!.nippleDistance.round();
                        debugPrint('Sending Pictures');
                        debugPrint('imgPaths[0]: ${imgPaths[0]}');
                        debugPrint('imgPaths[1]: ${imgPaths[1]}');
                        debugPrint('imgPaths[2]: ${imgPaths[2]}');
                        debugPrint('ident: $ident');
                        debugPrint('nippleDistance: $nd');
                        sendImagesCamera('http://localhost:28080/', imgPaths[0],
                            imgPaths[1], imgPaths[2], ident, nd);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      label: const Text(
                        'Send Pictures',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
