import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:test/adjustment_page.dart';
import 'package:test/comparison_page.dart';
import 'package:test/flutter_cube.dart';
import 'package:test/globals.dart';
import 'package:test/scanning_page.dart';
import 'package:test/util.dart';

late List<CameraDescription> cameras;
Globals g = Globals();

class HomePage extends StatelessWidget {
  HomePage(List<CameraDescription> cams, {super.key}) {
    cameras = cams;
    g.baseModel = Object(
      fileName: 'assets/models/fitModel_Demo_Augmentation.obj',
      position: Vector3(0, 2, 0),
      scale: Vector3(10, 10, 10),
      rotation: Vector3(180, 0, 0),
      visiable: true,
      lighting: true,
      backfaceCulling: false,
    );
    g.currentModel = Object(
      fileName: 'assets/models/fitModel_Demo_Augmentation.obj',
      position: Vector3(0, 2, 0),
      scale: Vector3(10, 10, 10),
      rotation: Vector3(180, 0, 0),
      visiable: true,
      lighting: true,
      backfaceCulling: false,
    );
    g.lowerModel = Object(
      fileName: 'assets/models/fitModel_Demo_Augmentation.obj',
      position: Vector3(0, 2, 0),
      scale: Vector3(10, 10, 10),
      rotation: Vector3(180, 0, 0),
      visiable: true,
      lighting: true,
      backfaceCulling: false,
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
        title: const Text('LindAppPlus'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return ScanningPage(cameras, g);
                    },
                  ),
                );
              },
              child: const Text('Scanning'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return AdjustmentPage(g);
                    },
                  ),
                );
              },
              child: const Text('Adjustment'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return ComparisonPage(g);
                    },
                  ),
                );
              },
              child: const Text('Comparison'),
            ),
            ElevatedButton(
              onPressed: () {
                saveLines(
                    add_usemtl_line(splitLines(readFile('assets/test.obj'))),
                    'assets/test.obj');
              },
              child: const Text('debug'),
            )
          ],
        ),
      ),
    );
  }
}
