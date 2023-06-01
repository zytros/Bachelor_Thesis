import 'package:flutter/widgets.dart' hide Image;
import 'package:test/util.dart';
import 'package:vector_math/vector_math_64.dart';
import '../globals.dart';
import 'scene.dart';
import 'package:flutter/material.dart' as m;

typedef void SceneCreatedCallback(Scene scene);
bool drawGlob = false;
late Globals g;

class Cube extends StatefulWidget {
  Cube({
    Key? key,
    this.interactive = true,
    this.draw = false,
    this.onSceneCreated,
    this.onObjectCreated,
    required this.globlas,
  }) : super(key: key) {
    drawGlob = draw;
    g = globlas;
  }

  final bool interactive;
  bool draw;
  Globals globlas;
  final SceneCreatedCallback? onSceneCreated;
  final ObjectCreatedCallback? onObjectCreated;

  @override
  _CubeState createState() => _CubeState();
}

class _CubeState extends State<Cube> {
  late Scene scene;
  late Offset _lastFocalPoint;
  double? _lastZoom;

  void _handleScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.localFocalPoint;
    _lastZoom = null;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    scene.camera.trackBall(
        toVector2(_lastFocalPoint), toVector2(details.localFocalPoint), 1.5);
    _lastFocalPoint = details.localFocalPoint;
    if (_lastZoom == null) {
      _lastZoom = scene.camera.zoom;
    } else {
      scene.camera.zoom = _lastZoom! * details.scale;
    }
    setState(() {});
  }

  void _onPointerDown(DragDownDetails details) {
    setState(() {
      g.line = <Offset>[];
      g.line.add(details.localPosition);
    });
  }

  void _onPointerMove(DragUpdateDetails details) {
    setState(() {
      g.line.add(details.localPosition);
    });
  }

  @override
  void initState() {
    super.initState();
    scene = Scene(
      onUpdate: () => setState(() {}),
      onObjectCreated: widget.onObjectCreated,
      gl: g,
    );
    // prevent setState() or markNeedsBuild called during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSceneCreated?.call(scene);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      g.screenwidth = constraints.maxWidth;
      g.screenheight = constraints.maxHeight;
      scene.camera.viewportWidth = constraints.maxWidth;
      scene.camera.viewportHeight = constraints.maxHeight;
      final customPaint = CustomPaint(
        painter: _CubePainter(scene, g.line, drawGlob),
        size: Size(constraints.maxWidth, constraints.maxHeight),
      );
      return drawGlob
          ? GestureDetector(
              onPanDown: _onPointerDown,
              onPanUpdate: _onPointerMove,
              child: customPaint,
            )
          : customPaint;
    });
  }
}

class _CubePainter extends CustomPainter {
  int c = 0;
  bool draw;
  final Scene _scene;
  final List<Offset> _points;
  _CubePainter(this._scene, this._points, this.draw);

  @override
  void paint(Canvas canvas, Size size) {
    _scene.render(canvas, size);
    if (!draw) {
      _points.clear();
    }
    // Draw line on canvas
    Paint paint = Paint()
      ..color = m.Colors.grey[100]!
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < _points.length - 1; i++) {
      canvas.drawLine(_points[i], _points[i + 1], paint);
    }
  }

  // We should repaint whenever the board changes, such as board.selected.
  @override
  bool shouldRepaint(_CubePainter oldDelegate) {
    return true;
  }
}

/// Convert Offset to Vector2
Vector2 toVector2(Offset value) {
  return Vector2(value.dx, value.dy);
}
