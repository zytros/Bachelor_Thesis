import 'package:flutter/material.dart';
import 'package:test/flutter_cube.dart';
import 'package:test/globals.dart';
import 'package:test/util.dart';

Globals? g;

class ComparisonPage extends StatefulWidget {
  ComparisonPage(Globals gl, {super.key}) {
    g = gl;
  }

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  late Scene _scene;

  @override
  void initState() {
    setPosition(g!.baseModel, Vector3(-3, 1, 0));
    setScaleUniform(g!.baseModel, g!.scales[0] * 8);
    setRotation(g!.baseModel, Vector3(180, 0, 0));
    g!.baseModel.updateTransform();

    setPosition(g!.currentModel, Vector3(3, 1, 0));
    setScaleUniform(g!.currentModel, 8);
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
      body: GestureDetector(
        child: Cube(
          onSceneCreated: _onSceneCreated,
          interactive: false,
        ),
        onPanUpdate: (details) {
          g!.baseModel.rotation.x += details.delta.dy;
          g!.baseModel.rotation.y += details.delta.dx;
          g!.currentModel.rotation.x += details.delta.dy;
          g!.currentModel.rotation.y += details.delta.dx;
          _scene.update();
          g!.baseModel.updateTransform();
          g!.currentModel.updateTransform();
        },
      ),
    );
  }

  void _onSceneCreated(Scene scene) {
    _scene = scene;
    scene.camera.position.z = 10;
    scene.light.setColor(Colors.white, 1.0, 0, 0);
    scene.world.add(g!.baseModel);
    scene.world.add(g!.currentModel);
  }
}
