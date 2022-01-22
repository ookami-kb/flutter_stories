import 'dart:math';

import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

final fractalTreeStory = Story(
  name: 'Fractal Tree',
  builder: (context) {
    final depth = context.knobs.sliderInt(
      label: 'Depth',
      description: 'Depth of the tree',
      min: 1,
      max: 15,
      initial: 10,
    );

    final angle = context.knobs.sliderInt(
      label: 'Angle',
      description: 'Angle (in degrees) for each branch.',
      min: 0,
      max: 90,
      initial: 20,
    );

    final length = context.knobs.slider(
      label: 'Length',
      description: 'Length of the root branch, as a fraction of '
          'the screen height.',
      min: 0,
      max: 0.5,
      initial: 0.1,
    );

    return FractalTree(
      depth: depth,
      angle: angle,
      length: length,
    );
  },
);

class FractalTree extends StatelessWidget {
  const FractalTree({
    Key? key,
    required this.depth,
    required this.angle,
    required this.length,
  }) : super(key: key);

  final int depth;
  final int angle;
  final double length;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: FractalTreePainter(
          depth: depth,
          angle: angle,
          length: length,
        ),
        size: Size.infinite,
      );
}

class FractalTreePainter extends CustomPainter {
  FractalTreePainter({
    required this.depth,
    required this.angle,
    required this.length,
  });

  final int depth;
  final int angle;
  final double length;

  final _paint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    _drawTree(
      canvas,
      size.width / 2,
      size.height,
      -pi / 2,
      depth,
      size.height / depth * length,
    );
  }

  void _drawTree(
    Canvas canvas,
    double x1,
    double y1,
    double angle,
    int depth,
    double length,
  ) {
    if (depth == 0) return;

    final x2 = x1 + (cos(angle) * depth * length);
    final y2 = y1 + (sin(angle) * depth * length);
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), _paint);
    _drawTree(canvas, x2, y2, angle - this.angle.radians, depth - 1, length);
    _drawTree(canvas, x2, y2, angle + this.angle.radians, depth - 1, length);
  }

  @override
  bool shouldRepaint(FractalTreePainter oldDelegate) =>
      oldDelegate.depth != depth ||
      oldDelegate.angle != angle ||
      oldDelegate.length != length;
}

extension on int {
  double get radians => this * pi / 180;
}
