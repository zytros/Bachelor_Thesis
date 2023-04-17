import 'package:flutter/material.dart';
import 'package:test/flutter_cube.dart';
import 'package:test/globals.dart';
import 'package:test/util.dart';

Globals? g;

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

    calcEigVals(g!.eigVals, g!.baseModel, g!.eigenVecs, g!.mean, g!);
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
            const Text('Adjustment'),
            Expanded(
              child: GestureDetector(
                child: Cube(
                  onSceneCreated: _onSceneCreated,
                  interactive: false,
                ),
                onPanUpdate: (details) {
                  g!.currentModel.rotation.x += details.delta.dy;
                  g!.currentModel.rotation.y += details.delta.dx;
                  _scene.update();
                  g!.currentModel.updateTransform();
                },
              ),
            ),
            const Text('Breast Size'),
            Slider(
              value: g!.size,
              min: -3,
              max: 3,
              onChanged: (value) {
                setState(
                  () {
                    g!.size = value;
                    calcEigVals(
                        g!.eigVals, g!.baseModel, g!.eigenVecs, g!.mean, g!);
                    changeModel(
                        g!.currentModel,
                        createModelVector(g!.size, g!.clWidth, g!.vertLift, g!),
                        g!);
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
                    calcEigVals(
                        g!.eigVals, g!.baseModel, g!.eigenVecs, g!.mean, g!);
                    changeModel(
                        g!.currentModel,
                        createModelVector(g!.size, g!.clWidth, g!.vertLift, g!),
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
                    calcEigVals(
                        g!.eigVals, g!.baseModel, g!.eigenVecs, g!.mean, g!);
                    changeModel(
                        g!.currentModel,
                        createModelVector(g!.size, g!.clWidth, g!.vertLift, g!),
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
