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
Stopwatch stopwatch = Stopwatch();

class HomePage extends StatelessWidget {
  HomePage(List<CameraDescription> cams, {super.key}) {
    cameras = cams;
    g.initEigenVecs();
    g.initMean();
    g.initbreastIndices();
    g.initOutline();
    g.initBreasLineIndices();
    String url = 'http://lsic.duckdns.org:28080/';
    g.baseModel = Object(
        fileName: url,
        position: Vector3(0, 2, 0),
        scale: Vector3(10, 10, 10),
        rotation: Vector3(180, 0, 0),
        visiable: true,
        lighting: false,
        backfaceCulling: true,
        src: 's');
    g.currentModel = Object(
        fileName: url,
        position: Vector3(0, 2, 0),
        scale: Vector3(10, 10, 10),
        rotation: Vector3(180, 0, 0),
        visiable: true,
        lighting: false,
        backfaceCulling: true,
        src: 's');
    stopwatch.start();
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
              backgroundColor: g.baseColor,
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
              label: const Text(
                'Scanning',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
            const SizedBox(width: 20),
            FloatingActionButton.extended(
              backgroundColor: g.baseColor,
              heroTag: 'btn_adjustment',
              onPressed: () {
                if (stopwatch.elapsedMilliseconds < 2000) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return AdjustmentPage(g);
                    },
                  ),
                );
              },
              label: const Text(
                'Adjustment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 20),
            FloatingActionButton.extended(
              backgroundColor: g.baseColor,
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
              label: const Text(
                'Comparison',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
