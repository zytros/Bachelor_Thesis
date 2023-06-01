import 'package:flutter/material.dart';
import 'package:test/flutter_cube.dart';
import 'package:test/globals.dart';
import 'package:test/util.dart';

Globals? g;

// false = vertical, true = horizontal
bool rotationAxis = false;
// 0 = front, 1 = above, 2 = below
int view = 0;

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
    setScaleUniform(g!.currentModel, g!.cubeScale);
    setRotation(g!.currentModel, Vector3(180, 0, 0));
    g!.currentModel.updateTransform();

    g!.eigValsVec = calculateEigenValues(g!.baseModel, g!.meanVec, g!);
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                child: Cube(
                  onSceneCreated: _onSceneCreated,
                  interactive: false,
                  globlas: g!,
                ),
                onPanUpdate: (details) {
                  if (!rotationAxis) {
                  } else {}
                  _scene.update();
                  g!.currentModel.updateTransform();
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'btn_changeRotationAxis',
                  backgroundColor: g!.baseColor,
                  onPressed: () {
                    rotationAxis = !rotationAxis;
                  },
                  label: const Text('Change Rotation Axis'),
                ),
                const SizedBox(width: 20),
                FloatingActionButton.extended(
                  heroTag: 'btn_reset',
                  backgroundColor: g!.baseColor,
                  onPressed: () {
                    g!.currentModel.rotation.x = 180;
                    g!.currentModel.rotation.y = 0;
                    g!.currentModel.rotation.z = 0;
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
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
    );
  }

  void _onSceneCreated(Scene scene) {
    _scene = scene;
    scene.camera.position.z = 10;
    scene.light.setColor(Colors.white, 1.0, 0, 0);
    scene.world.add(g!.currentModel);
  }
}
