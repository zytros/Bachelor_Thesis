import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:test/adjustment_page.dart';
import 'package:test/comparison_page.dart';
import 'package:test/flutter_cube.dart';
import 'package:test/globals.dart';
import 'package:test/scanning_page_web.dart';
import 'package:test/util.dart';

late List<CameraDescription> cameras;
Globals g = Globals();

class HomePage extends StatelessWidget {
  HomePage(List<CameraDescription> cams, {super.key}) {
    cameras = cams;
    g.initEigenVecs();
    g.initMean();
    g.baseModel = true
        // ignore: dead_code
        ? Object(
            fileName: 'http://localhost:8080/',
            position: Vector3(0, 2, 0),
            scale: Vector3(10, 10, 10),
            rotation: Vector3(180, 0, 0),
            visiable: true,
            lighting: false,
            backfaceCulling: true,
            src: 's')
        :
        // ignore: dead_code
        Object(
            fileName: 'assets/models/fitModel_Demo_Augmentation.obj',
            position: Vector3(0, 2, 0),
            scale: Vector3(10, 10, 10),
            rotation: Vector3(180, 0, 0),
            visiable: true,
            lighting: false,
            backfaceCulling: true,
          );
    g.currentModel = true
        // ignore: dead_code
        ? Object(
            fileName: 'http://localhost:8080/',
            position: Vector3(0, 2, 0),
            scale: Vector3(10, 10, 10),
            rotation: Vector3(180, 0, 0),
            visiable: true,
            lighting: false,
            backfaceCulling: true,
            src: 's')
        :
        // ignore: dead_code
        Object(
            fileName: 'assets/models/fitModel_Demo_Augmentation.obj',
            position: Vector3(0, 2, 0),
            scale: Vector3(10, 10, 10),
            rotation: Vector3(180, 0, 0),
            visiable: true,
            lighting: false,
            backfaceCulling: true,
          );
    g.lowerModel = true
        // ignore: dead_code
        ? Object(
            fileName: 'http://localhost:8080/',
            position: Vector3(0, 2, 0),
            scale: Vector3(10, 10, 10),
            rotation: Vector3(180, 0, 0),
            visiable: true,
            lighting: false,
            backfaceCulling: true,
            src: 's')
        :
        // ignore: dead_code
        Object(
            fileName: 'assets/models/fitModel_Demo_Augmentation.obj',
            position: Vector3(0, 2, 0),
            scale: Vector3(10, 10, 10),
            rotation: Vector3(180, 0, 0),
            visiable: true,
            lighting: false,
            backfaceCulling: true,
          );
    g.upperModel = Object(
      fileName: 'assets/models/increasedModel_Demo_Augmentation.obj',
      position: Vector3(0, 2, 0),
      scale: Vector3(10, 10, 10),
      rotation: Vector3(180, 0, 0),
      visiable: true,
      lighting: true,
      backfaceCulling: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LindApp'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              backgroundColor: const Color.fromARGB(255, 134, 2, 2),
              heroTag: 'btn_scanning',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return ScanningPageWeb(cameras, g);
                    },
                  ),
                );
              },
              label: const Text('Scanning'),
            ),
            const SizedBox(width: 20),
            FloatingActionButton.extended(
              backgroundColor: const Color.fromARGB(255, 134, 2, 2),
              heroTag: 'btn_adjustment',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return AdjustmentPage(g);
                    },
                  ),
                );
              },
              label: const Text('Adjustment'),
            ),
            const SizedBox(width: 20),
            FloatingActionButton.extended(
              backgroundColor: const Color.fromARGB(255, 134, 2, 2),
              heroTag: 'btn_comparison',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return ComparisonPage(g);
                    },
                  ),
                );
              },
              label: const Text('Comparison'),
            ),
          ],
        ),
      ),
    );
  }
}
