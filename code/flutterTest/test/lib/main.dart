import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return DrawingArea();
  }
}

class DrawingArea extends StatefulWidget {
  @override
  _DrawingAreaState createState() => _DrawingAreaState();
}

class _DrawingAreaState extends State<DrawingArea> {
  List<Offset> _points = <Offset>[];
  List<bool> _isDrawing = <bool>[];

  void _onPointerDown(DragDownDetails details) {
    debugPrint('down');
    setState(() {
      _points = <Offset>[];
      _points.add(details.localPosition);
      _isDrawing.add(false);
    });
  }

  void _onPointerMove(DragUpdateDetails details) {
    debugPrint('move');
    setState(() {
      _points.add(details.localPosition);
      _isDrawing.add(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: _onPointerDown,
      onPanUpdate: _onPointerMove,
      onPanCancel: () {
        debugPrint('cancel');
      },
      onPanEnd: (details) {
        debugPrint('end');
      },
      onPanStart: (details) {
        debugPrint('start');
      },
      child: CustomPaint(
        painter: DrawingPainter(_points),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return true;
  }
}
