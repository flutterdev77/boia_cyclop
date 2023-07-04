import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';

import '../../utils.dart';

const cyclopCellSize = 10;

const cyclopGridSize = 90.0;

class EyeDropOverlay extends StatelessWidget {
  final Offset? cursorPosition;
  final bool touchable;
  final VoidCallback onDone;

  final List<Color> colors;

  const EyeDropOverlay({
    required this.colors,
    required this.onDone,
    this.cursorPosition,
    this.touchable = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return cursorPosition != null
        ? Stack(
            children: [
              Positioned(
                left: cursorPosition!.dx - (cyclopGridSize / 2),

                /// Remove (cyclopGridSize / 2) - (touchable ? _gridSize / 2 : 0) to place below finger tip
                top: cursorPosition!.dy -
                    (cyclopGridSize / 2) -
                    (touchable ? cyclopGridSize / 2 : 0),
                width: cyclopGridSize,
                height: cyclopGridSize,
                child: _buildZoom(),
              ),
              Positioned(
                left: cursorPosition!.dx - (cyclopGridSize / 2),
                top: cursorPosition!.dy - (cyclopGridSize * 1.5),
                width: cyclopGridSize,
                child: IgnorePointer(
                  ignoring: true,
                  child: TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    onPressed: onDone,
                    child: const Text('Done'),
                  ),
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  Widget _buildZoom() {
    return IgnorePointer(
      ignoring: true,
      child: Container(
        foregroundDecoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              width: 8, color: colors.isEmpty ? Colors.white : colors.center),
        ),
        width: cyclopGridSize,
        height: cyclopGridSize,
        constraints: BoxConstraints.loose(const Size.square(cyclopGridSize)),
        child: ClipOval(
          child: CustomPaint(
            size: const Size.square(cyclopGridSize),
            painter: _PixelGridPainter(colors),
          ),
        ),
      ),
    );
  }
}

/// paint a hovered pixel/colors preview
class _PixelGridPainter extends CustomPainter {
  final List<Color> colors;

  static const gridSize = 9;
  static const eyeRadius = 35.0;

  final blackStroke = Paint()
    ..color = Colors.black
    ..strokeWidth = 10
    ..style = PaintingStyle.stroke;

  _PixelGridPainter(this.colors);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
/*    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke;*/

    final blackLine = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

/*    final selectedStroke = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;*/

    ///Removed pixels color filled squares
/*    // fill pixels color square
    for (final color in enumerate(colors)) {
      final fill = Paint()..color = color.value;
      final rect = Rect.fromLTWH(
        (color.index % gridSize).toDouble() * cyclopCellSize,
        ((color.index ~/ gridSize) % gridSize).toDouble() * cyclopCellSize,
        cyclopCellSize.toDouble(),
        cyclopCellSize.toDouble(),
      );
      canvas.drawRect(rect, fill);
    }*/

    // draw pixels borders after fills
    for (final color in enumerate(colors)) {
      final rect = Rect.fromLTWH(
        (color.index % gridSize).toDouble() * cyclopCellSize,
        ((color.index ~/ gridSize) % gridSize).toDouble() * cyclopCellSize,
        cyclopCellSize.toDouble(),
        cyclopCellSize.toDouble(),
      );

      ///Remove the rectangular borders
/*      canvas.drawRect(
          rect, color.index == colors.length ~/ 2 ? selectedStroke : stroke);*/

      if (color.index == colors.length ~/ 2) {
        canvas.drawRect(rect.deflate(1), blackLine);
      }
    }

    // black contrast ring
    canvas.drawCircle(
      const Offset((cyclopGridSize) / 2, (cyclopGridSize) / 2),
      eyeRadius,
      blackStroke,
    );
  }

  @override
  bool shouldRepaint(_PixelGridPainter oldDelegate) =>
      !listEquals(oldDelegate.colors, colors);
}
