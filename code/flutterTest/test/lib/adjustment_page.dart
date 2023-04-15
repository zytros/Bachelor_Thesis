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
    setScaleUniform(g!.currentModel, 10);
    setRotation(g!.currentModel, Vector3(180, 0, 0));
    g!.currentModel.updateTransform();

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
            OutlinedButton(
              onPressed: () {
                double currScale = g!.currentModel.scale.x;
                setScaleUniform(g!.currentModel, currScale * 0.5);
                _scene.update();
                g!.currentModel.updateTransform();
              },
              child: const Text('scale down'),
            ),
            OutlinedButton(
              onPressed: () {
                double currScale = g!.currentModel.scale.x;
                setScaleUniform(g!.currentModel, currScale / 0.5);
                _scene.update();
                g!.currentModel.updateTransform();
              },
              child: const Text('scale up'),
            ),
            OutlinedButton(
              onPressed: () {
                /*
                for (int i = 0; i < 3354; i++) {
                  g!.currentModel.mesh.vertices[i].x = g!.mean[i * 3];
                  g!.currentModel.mesh.vertices[i].y = g!.mean[i * 3 + 1];
                  g!.currentModel.mesh.vertices[i].z = g!.mean[i * 3 + 2];
                }
                var ob = Object(
                    fileName: vectorToObjString(listToVecs(g!.mean)),
                    position: Vector3(0, 2, 0),
                    scale: Vector3(10, 10, 10),
                    rotation: Vector3(180, 0, 0),
                    visiable: true,
                    lighting: false,
                    backfaceCulling: true,
                    src: 'str');
                thisisit(
                    'currentModel length: ${g!.currentModel.mesh.vertices.length}');
                thisisit('ob length: ${ob.mesh.vertices.length}');
                //g!.currentModel.mesh.vertices = ob.mesh.vertices;
                //_scene.update();
                //g!.currentModel.updateTransform();*/
                g!.currentModel.mesh.vertices = listToVecs(g!.mean);
                rebuildVertices(
                  g!.currentModel.mesh.vertices,
                  g!.currentModel.mesh.init_texcoords,
                  g!.currentModel.mesh.init_vertexIndices,
                  g!.currentModel.mesh.init_TextIndices,
                );
              },
              child: const Text('debug2'),
            )
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
