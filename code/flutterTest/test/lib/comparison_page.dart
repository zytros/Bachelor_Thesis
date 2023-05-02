import 'package:flutter/material.dart';
import 'package:test/flutter_cube.dart';
import 'package:test/globals.dart';
import 'package:test/util.dart';

Globals? g;

// false = vertical, true = horizontal
bool rotationAxis = false;

class ComparisonPage extends StatefulWidget {
  ComparisonPage(Globals gl, {super.key}) {
    g = gl;
  }

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  late Scene _sceneLeft;
  late Scene _sceneRight;

  @override
  void initState() {
    setPosition(g!.baseModel, Vector3(0, 3, 0));
    setScaleUniform(g!.baseModel, g!.scales[0] * g!.cubeScale);
    setRotation(g!.baseModel, Vector3(180, 0, 0));
    g!.baseModel.updateTransform();

    setPosition(g!.currentModel, Vector3(0, 3, 0));
    setScaleUniform(g!.currentModel, g!.scales[0] * g!.cubeScale);
    setRotation(g!.currentModel, Vector3(180, 0, 0));
    g!.currentModel.updateTransform();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparison'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: GestureDetector(
              child: Row(
                children: [
                  Expanded(
                    child: Cube(
                      onSceneCreated: _onSceneLeftCreated,
                      interactive: false,
                    ),
                  ),
                  Expanded(
                    child: Cube(
                      onSceneCreated: _onSceneRightCreated,
                      interactive: false,
                    ),
                  ),
                ],
              ),
              onPanUpdate: (details) {
                if (!rotationAxis) {
                  g!.baseModel.rotation.y += details.delta.dx;
                  g!.currentModel.rotation.y += details.delta.dx;
                } else {
                  g!.baseModel.rotation.x += details.delta.dy;
                  g!.currentModel.rotation.x += details.delta.dy;
                }
                _sceneLeft.update();
                _sceneRight.update();
                g!.baseModel.updateTransform();
                g!.currentModel.updateTransform();
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                    backgroundColor: g!.baseColor,
                    heroTag: 'btn_resetModel',
                    onPressed: () {
                      setRotation(g!.baseModel, Vector3(180, 0, 0));
                      setRotation(g!.currentModel, Vector3(180, 0, 0));
                      _sceneLeft.update();
                      _sceneRight.update();
                      g!.baseModel.updateTransform();
                      g!.currentModel.updateTransform();
                    },
                    label: const Text('Reset Model')),
                const SizedBox(width: 20),
                FloatingActionButton.extended(
                    backgroundColor: g!.baseColor,
                    heroTag: 'btn_changeRotationAxis',
                    onPressed: () {
                      setState(
                        () {
                          rotationAxis = !rotationAxis;
                        },
                      );
                    },
                    label: const Text('Change Rotation Axis')),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _onSceneLeftCreated(Scene scene) {
    _sceneLeft = scene;
    scene.camera.position.z = 10;
    scene.light.setColor(Colors.white, 1.0, 0, 0);
    scene.world.add(g!.baseModel);
  }

  void _onSceneRightCreated(Scene scene) {
    _sceneRight = scene;
    scene.camera.position.z = 10;
    scene.light.setColor(Colors.white, 1.0, 0, 0);
    scene.world.add(g!.currentModel);
  }
}
