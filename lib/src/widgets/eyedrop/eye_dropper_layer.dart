import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

import '../../utils.dart';
import 'eye_dropper_overlay.dart';

const _gridSize = 90.0;

class EyeDropperModel {
  /// based on PointerEvent.kind
  bool touchable = false;

  OverlayEntry? eyeOverlayEntry;

  img.Image? snapshot;

  Offset cursorPosition = screenSize.center(Offset.zero);

  Color hoverColor = Colors.black;

  List<Color> hoverColors = [];

  Color selectedColor = Colors.black;

  ValueChanged<Color>? onColorSelected;

  ValueChanged<Color>? onColorChanged;

  EyeDropperModel();
}

class EyeDrop extends InheritedWidget {
  static EyeDropperModel data = EyeDropperModel();

  final GlobalKey captureKey;

  EyeDrop({
    required Widget child,
    required this.captureKey,
    Key? key,
  }) : super(
          key: key,
          child: RepaintBoundary(
            key: captureKey,
            child: Listener(
              onPointerMove: (details) => _onHover(
                details.position,
                details.kind == PointerDeviceKind.touch,
              ),
              onPointerHover: (details) => _onHover(
                details.position,
                details.kind == PointerDeviceKind.touch,
              ),
              onPointerUp: (details) {},
              child: child,
            ),
          ),
        );

  static EyeDrop of(BuildContext context) {
    final eyeDrop = context.dependOnInheritedWidgetOfExactType<EyeDrop>();
    if (eyeDrop == null) {
      throw Exception(
          'No EyeDrop found. You must wrap your application within an EyeDrop widget.');
    }
    return eyeDrop;
  }

  static void _onPointerUp(Offset position) {
    _onHover(position, data.touchable);
    if (data.onColorSelected != null) {
      data.onColorSelected!(data.hoverColors.center);
    }

    if (data.eyeOverlayEntry != null) {
      try {
        data.eyeOverlayEntry!.remove();
        data.eyeOverlayEntry = null;
        data.onColorSelected = null;
        data.onColorChanged = null;
      } catch (err) {
        debugPrint('ERROR !!! _onPointerUp $err');
      }
    }
  }

  static void _onHover(Offset offset, bool touchable) {
    if (data.eyeOverlayEntry != null) data.eyeOverlayEntry!.markNeedsBuild();

    data.cursorPosition = offset;

    data.touchable = touchable;

    if (data.snapshot != null) {
      data.hoverColor = getPixelColor(data.snapshot!, offset);
      data.hoverColors = getPixelColors(data.snapshot!, offset);
    }

    if (data.onColorChanged != null) {
      data.onColorChanged!(data.hoverColors.center);
    }
  }

  Future<OverlayEntry?> capture(
    BuildContext context,
    ValueChanged<Color> onColorSelected,
    ValueChanged<Color>? onColorChanged,
  ) async {
    final renderer =
        captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (renderer == null) return null;

    data.onColorSelected = onColorSelected;
    data.onColorChanged = onColorChanged;

    data.snapshot = await repaintBoundaryToImage(renderer);

    if (data.snapshot == null) return null;

    data.eyeOverlayEntry = OverlayEntry(
      builder: (_) => Stack(
        clipBehavior: Clip.none,
        children: [
          EyeDropOverlay(
            touchable: data.touchable,
            colors: data.hoverColors,
            cursorPosition: data.cursorPosition,
          ),
          Positioned(
            ///80 is the width of button
            left: data.cursorPosition.dx - 80 / 2,

            ///32 is the size of button and 8 is the padding
            top: (data.cursorPosition.dy - _gridSize) - 32 - 8,
            child: SizedBox(
              height: 32,
              width: 80,
              child: CustomTabButtons(
                title: 'Done',
                onTap: () {
                  _onPointerUp(
                    Offset(
                      data.cursorPosition.dx,
                      data.cursorPosition.dy,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );

    if (context.mounted) {
      Overlay.of(context).insert(data.eyeOverlayEntry!);
    }

    return data.eyeOverlayEntry;
  }

  @override
  bool updateShouldNotify(EyeDrop oldWidget) {
    return true;
  }
}

class CustomTabButtons extends StatelessWidget {
  const CustomTabButtons({
    required this.title,
    required this.onTap,
    super.key,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: title,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            elevation: 2,
            backgroundColor: const Color(0xff366cf8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(48)),
            alignment: Alignment.center,
          ),
          onPressed: onTap,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD9DEEF),
            ),
          )),
    );
  }
}
