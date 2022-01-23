import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:storybook_flutter/storybook_flutter.dart';

final mandelbrotStory = Story(
  name: 'Mandelbrot Set',
  builder: (context) => MandelbrotSet(
    data: Data(
      maxIterations: context.knobs.sliderInt(
        label: 'Max iterations',
        min: 1,
        max: 500,
        initial: 200,
      ),
      zoom: context.knobs.slider(
        label: 'Zoom',
        min: 50,
        max: 500,
        initial: 150,
      ),
      red: context.knobs.sliderInt(
        label: 'Red',
        min: 0,
        max: 255,
        initial: 0,
      ),
      green: context.knobs.sliderInt(
        label: 'Green',
        min: 0,
        max: 255,
        initial: 255,
      ),
      blue: context.knobs.sliderInt(
        label: 'Blue',
        min: 0,
        max: 255,
        initial: 255,
      ),
    ),
  ),
);

@immutable
class Data {
  const Data({
    required this.maxIterations,
    required this.zoom,
    required this.red,
    required this.green,
    required this.blue,
  });

  final int maxIterations;
  final double zoom;
  final int red;
  final int green;
  final int blue;

  @override
  bool operator ==(Object other) =>
      other is Data &&
      other.maxIterations == maxIterations &&
      other.zoom == zoom &&
      other.red == red &&
      other.green == green &&
      other.blue == blue;

  @override
  int get hashCode => Object.hash(maxIterations, zoom, red, green, blue);
}

class MandelbrotSet extends StatefulWidget {
  const MandelbrotSet({Key? key, required this.data}) : super(key: key);

  final Data data;

  @override
  State<MandelbrotSet> createState() => _MandelbrotSetState();
}

class _MandelbrotSetState extends State<MandelbrotSet> {
  Image? _image;
  double? _width, _height;

  void _updateImage() {
    final maxIter = widget.data.maxIterations;
    final zoom = widget.data.zoom;

    final width = _width?.toInt();
    final height = _height?.toInt();

    if (width == null || height == null) return;

    final pixels = Uint8List(width * height * 4);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        var zx = 0.0;
        var zy = 0.0;
        final cX = (x - width / 2) / zoom;
        final cY = (y - height / 2) / zoom;
        var iter = maxIter;

        while (zx * zx + zy * zy < 4.0 && iter > 0) {
          final tmp = zx * zx - zy * zy + cX;
          zy = 2.0 * zx * zy + cY;
          zx = tmp;
          iter--;
        }
        final i = (width * y + x) * 4;
        pixels[i] = iter * widget.data.red;
        pixels[i + 1] = iter * widget.data.green;
        pixels[i + 2] = iter * widget.data.blue;
        pixels[i + 3] = 255;
      }
    }

    decodeImageFromPixels(
      pixels,
      width.toInt(),
      height.toInt(),
      PixelFormat.rgba8888,
      (image) {
        if (!mounted) return;

        setState(() => _image = image);
      },
    );
  }

  @override
  void didUpdateWidget(covariant MandelbrotSet oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateImage();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (_width != constraints.maxWidth ||
              _height != constraints.maxHeight) {
            _width = constraints.maxWidth;
            _height = constraints.maxHeight;
            WidgetsBinding.instance
                ?.addPostFrameCallback((timeStamp) => _updateImage());
          }
          return CustomPaint(
            painter: MandelbrotSetPainter(_image),
            size: Size.infinite,
          );
        },
      );
}

class MandelbrotSetPainter extends CustomPainter {
  MandelbrotSetPainter(this.image);

  final Image? image;

  final _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final image = this.image;
    if (image == null) return;

    canvas.drawImage(image, Offset.zero, _paint);
  }

  @override
  bool shouldRepaint(MandelbrotSetPainter oldDelegate) =>
      oldDelegate.image != image;
}
