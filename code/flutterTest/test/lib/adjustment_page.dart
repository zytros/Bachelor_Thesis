import 'package:flutter/material.dart';
import 'package:test/flutter_cube.dart';
import 'package:test/globals.dart';
import 'package:test/util.dart';

Globals? g;
int count = 0;

// false = vertical, true = horizontal
bool rotationAxis = false;

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
    setPosition(g!.currentModel, Vector3(0, 2, 0));
    setScaleUniform(g!.currentModel, g!.scales[0] * 8);
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                child: Cube(
                  onSceneCreated: _onSceneCreated,
                  interactive: false,
                ),
                onPanUpdate: (details) {
                  if (!rotationAxis) {
                    g!.currentModel.rotation.y += details.delta.dx;
                  } else {
                    g!.currentModel.rotation.x += details.delta.dy;
                  }
                  _scene.update();
                  g!.currentModel.updateTransform();
                },
              ),
            ),
            FloatingActionButton.extended(
              heroTag: 'btn_changeRotationAxis',
              backgroundColor: const Color.fromARGB(255, 134, 2, 2),
              onPressed: () {
                rotationAxis = !rotationAxis;
              },
              label: const Text('Change Rotation Axis'),
            ),
            const SizedBox(height: 20),
            const Text('Breast Size'),
            Slider(
              value: g!.size,
              min: -3,
              max: 3,
              onChanged: (value) {
                setState(
                  () {
                    g!.size = value;
                    if (count <= 100) {
                      count++;
                      return;
                    }
                    changeModel(
                        g!.currentModel,
                        interpolateVectors(
                            createModelVector(
                                g!.size, g!.clWidth, g!.vertLift, g!),
                            g!),
                        g!);
                    count = 0;
                  },
                );
              },
            ),
            const Text('Vertical Lift'),
            Slider(
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
            const Text('Cleavage Width'),
            Slider(
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
            OutlinedButton(
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
                      createModelVector(g!.size, g!.clWidth, g!.vertLift, g!),
                      g!);
                });
              },
              child: const Text('Reset'),
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
