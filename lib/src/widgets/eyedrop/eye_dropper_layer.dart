import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

import '../../utils.dart';
import 'eye_dropper_overlay.dart';

final captureKey = GlobalKey();

class _EyeDropperModel {
  /// based on PointerEvent.kind
  bool touchable = false;

  OverlayEntry? eyeOverlayEntry;

  img.Image? snapshot;

  Offset cursorPosition = screenSize.topCenter(Offset.zero);

  Color hoverColor = Colors.black;

  List<Color> hoverColors = [];

  Color selectedColor = Colors.black;

  ValueChanged<Color>? onColorSelected;

  ValueChanged<Color>? onColorChanged;

  _EyeDropperModel();
}

class EyeDrop extends InheritedWidget {
  static _EyeDropperModel data = _EyeDropperModel();

  EyeDrop({required Widget child, Key? key})
      : super(
          key: key,
          child: RepaintBoundary(
            key: captureKey,
            child: Listener(
              /// Causes Overlay to move based on our gesture
              onPointerMove: (details) => _onHover(
                details.position,
                details.kind == PointerDeviceKind.touch,
              ),
              onPointerHover: (details) => _onHover(
                details.position,
                details.kind == PointerDeviceKind.touch,
              ),

              /// Causes Overlay to vanish once the tap is released
              onPointerUp: (details) {
                _onHover(
                  details.position,
                  details.kind == PointerDeviceKind.touch,
                );
              },
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

  void _removeOverlay() {
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
        debugPrint('ERROR !!! removeOverlay $err');
      }
    }
  }

  static void _onHover(Offset offset, bool touchable) {
    if (data.eyeOverlayEntry != null) data.eyeOverlayEntry!.markNeedsBuild();

    data.cursorPosition = Offset(
      offset.dx,
      offset.dy - cyclopGridSize / 4,
    );

    data.touchable = touchable;

    if (data.snapshot != null) {
      data.hoverColor = getPixelColor(
        data.snapshot!,
        Offset(
          offset.dx,
          offset.dy - ((cyclopGridSize / 2) + (cyclopGridSize / 4)),
        ),
      );
      data.hoverColors = getPixelColors(
          data.snapshot!,
          Offset(
            offset.dx,
            offset.dy - ((cyclopGridSize / 2) + (cyclopGridSize / 4)),
          ));
    }

    if (data.onColorChanged != null) {
      data.onColorChanged!(data.hoverColors.center);
    }
  }

  void capture(BuildContext context, ValueChanged<Color> onColorSelected,
      ValueChanged<Color>? onColorChanged) async {
    final renderer =
        captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (renderer == null) return;

    data.onColorSelected = onColorSelected;
    data.onColorChanged = onColorChanged;

    data.snapshot = await repaintBoundaryToImage(renderer);

    if (data.snapshot == null) return;

    data.cursorPosition = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );

    data.eyeOverlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          EyeDropOverlay(
            touchable: data.touchable,
            colors: data.hoverColors,
            cursorPosition: data.cursorPosition,
          ),
          Positioned(
            left: data.cursorPosition.dx - (cyclopGridSize / 2),
            top: data.cursorPosition.dy - (cyclopGridSize * 1.5),
            width: cyclopGridSize,
            child: IgnorePointer(
              ignoring: true,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    // If the button is pressed, return green, otherwise blue
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.green;
                    }
                    return Colors.blue;
                  }),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                onPressed: _removeOverlay,
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(data.eyeOverlayEntry!);
  }

  @override
  bool updateShouldNotify(EyeDrop oldWidget) {
    return true;
  }
}
