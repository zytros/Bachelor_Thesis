import 'package:flutter/material.dart';
import 'package:test/flutter_cube.dart';
import 'package:test/globals.dart';
import 'package:test/util.dart';

Globals? g;
List<String> txt_btn_draw = ['Draw on Model', 'Rotate Model'];
// false = vertical, true = horizontal
bool rotationAxis = false;
// 0 = front, 1 = above, 2 = below
int view = 0;
bool draw = false;

class AdjustmentPage extends StatefulWidget {
  AdjustmentPage(Globals gl, {super.key}) {
    g = gl;
  }

  @override
  State<AdjustmentPage> createState() => _AdjustmentPageState();
}

class _AdjustmentPageState extends State<AdjustmentPage> {
  void changeModelL() {}
  late Scene _scene;

  @override
  void initState() {
    setPosition(g!.currentModel, Vector3(0, 3, 0));
    setScaleUniform(g!.currentModel, g!.scales[0] * g!.cubeScale);
    setRotation(g!.currentModel, Vector3(180, 0, 0));
    g!.currentModel.updateTransform();

    g!.eigValsVec = calcEigVals(g!.baseModel, g!.eigenVecsMat, g!.meanVec, g!);
    g!.baseVec = createModelVector(g!.size, g!.clWidth, g!.vertLift, g!);
    changeModel(g!.currentModel,
        createModelVector(g!.size, g!.clWidth, g!.vertLift, g!), g!);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjustment'),
      ),
      backgroundColor: Colors.black,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(flex: 1, child: SizedBox.expand()),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Cube(
                      onSceneCreated: _onSceneCreated,
                      interactive: false,
                      draw: draw,
                      globlas: g!,
                    ),
                    onPanUpdate: (details) {
                      double rot = g!.currentModel.rotation.y;

                      if (view == 0) {
                        camSetDegreeY(_scene, details.delta.dx / 300, 0, 180);
                      } else if (view == 1) {
                        //debugPrint('dy: ${details.delta.dy}');
                        camSetDegreeX(_scene, details.delta.dy / -300, 0, 10);
                      } else {
                        camSetDegreeX(_scene, details.delta.dy / 300, 0, 10);
                      }
                      _scene.update();
                      g!.currentModel.updateTransform();
                    },
                  ),
                ),
                const Text('Breast Size'),
                Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: SizedBox(
                        width: 100,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Slider(
                        value: g!.size,
                        min: -3,
                        max: 3,
                        onChanged: (value) {
                          setState(
                            () {
                              g!.size = value;

                              changeModel(
                                  g!.currentModel,
                                  interpolateVectors(
                                      createModelVector(
                                          g!.size, g!.clWidth, g!.vertLift, g!),
                                      g!),
                                  g!);
                            },
                          );
                        },
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: SizedBox(
                        width: 100,
                      ),
                    ),
                  ],
                ),
                const Text('Vertical Lift'),
                Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: SizedBox(
                        width: 100,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Slider(
                        value: g!.vertLift,
                        min: -3,
                        max: 3,
                        onChanged: (value) {
                          setState(
                            () {
                              g!.vertLift = value;
                              changeModel(
                                  g!.currentModel,
                                  interpolateVectors(
                                      createModelVector(
                                          g!.size, g!.clWidth, g!.vertLift, g!),
                                      g!),
                                  g!);
                            },
                          );
                        },
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: SizedBox(
                        width: 100,
                      ),
                    ),
                  ],
                ),
                const Text('Cleavage Width'),
                Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: SizedBox(
                        width: 100,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Slider(
                        value: g!.clWidth,
                        min: -3,
                        max: 3,
                        onChanged: (value) {
                          setState(
                            () {
                              g!.clWidth = value;
                              changeModel(
                                  g!.currentModel,
                                  interpolateVectors(
                                      createModelVector(
                                          g!.size, g!.clWidth, g!.vertLift, g!),
                                      g!),
                                  g!);
                            },
                          );
                        },
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: SizedBox(
                        width: 100,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'btn_changeRotationAxis',
                  backgroundColor: g!.baseColor,
                  onPressed: () {
                    view = (view + 1) % 3;
                    if (view == 0) {
                      setModelAndCamera(
                          g!.currentModel,
                          _scene,
                          Vector3(180, 0, 0),
                          Vector3(0, 3, 0),
                          Vector3(0, 0, 10));
                    } else if (view == 1) {
                      setModelAndCamera(
                          g!.currentModel,
                          _scene,
                          Vector3(90, 180, 0),
                          Vector3(0, 0, 0),
                          Vector3(0, 0, 8));
                    } else {
                      setModelAndCamera(
                          g!.currentModel,
                          _scene,
                          Vector3(95, 0, 0),
                          Vector3(0, -1.5, 0),
                          Vector3(0, 0, 12));
                    }
                  },
                  label: const Text(
                    'Perspective',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FloatingActionButton.extended(
                  heroTag: 'btn_reset',
                  backgroundColor: g!.baseColor,
                  onPressed: () {
                    if (view == 0) {
                      setModelAndCamera(
                          g!.currentModel,
                          _scene,
                          Vector3(180, 0, 0),
                          Vector3(0, 3, 0),
                          Vector3(0, 0, 10));
                    } else if (view == 1) {
                      setModelAndCamera(
                          g!.currentModel,
                          _scene,
                          Vector3(90, 180, 0),
                          Vector3(0, 0, 0),
                          Vector3(0, 0, 8));
                    } else {
                      setModelAndCamera(
                          g!.currentModel,
                          _scene,
                          Vector3(95, 0, 0),
                          Vector3(0, -1.5, 0),
                          Vector3(0, 0, 12));
                    }
                    _scene.update();
                    g!.currentModel.updateTransform();
                    setState(() {
                      g!.size = g!.baseSize;
                      g!.clWidth = g!.baseClWidth;
                      g!.vertLift = g!.baseVertLift;
                      changeModel(
                          g!.currentModel,
                          createModelVector(
                              g!.size, g!.clWidth, g!.vertLift, g!),
                          g!);
                    });
                  },
                  label: const Text(
                    'Reset',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FloatingActionButton.extended(
                  heroTag: 'btn_draw',
                  backgroundColor: g!.baseColor,
                  onPressed: () {
                    setState(() {
                      draw = !draw;
                    });
                  },
                  label: draw
                      ? Text(
                          txt_btn_draw[1],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        )
                      : Text(
                          txt_btn_draw[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _onSceneCreated(Scene scene) {
    _scene = scene;
    scene.camera.position.z = 10;
    scene.light.setColor(Colors.white, 1.0, 0, 0);
    scene.world.add(g!.currentModel);
  }
}
