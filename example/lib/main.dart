import 'package:flutter/material.dart';
import 'package:cyclop/cyclop.dart';

void main() async => runApp(const App());

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final captureKey = GlobalKey();

  @override
  void dispose() {
    captureKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: EyeDrop(
          captureKey: captureKey,
          child: const MainScreen(),
        ),
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blueGrey,
            accentColor: Colors.teal,
          ),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
      );
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  Color appbarColor = Colors.blueGrey;

  Color backgroundColor = Colors.grey.shade200;

  Set<Color> swatches = Colors.primaries.map((e) => Color(e.value)).toSet();

  final ValueNotifier<Color?> hoveredColor = ValueNotifier<Color?>(null);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final bodyTextColor =
        ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
            ? Colors.white70
            : Colors.black87;

    final appbarTextColor =
        ThemeData.estimateBrightnessForColor(appbarColor) == Brightness.dark
            ? Colors.white70
            : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Cyclop Demo',
            style: textTheme.titleLarge?.copyWith(color: appbarTextColor)),
        backgroundColor: appbarColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: ColorButton(
                darkMode: true,
                key: const Key('c2'),
                color: appbarColor,
                boxShape: BoxShape.rectangle,
                swatches: swatches,
                size: 32,
                config: const ColorPickerConfig(
                  enableOpacity: false,
                  enableLibrary: false,
                ),
                onColorChanged: (value) => setState(() => appbarColor = value),
                onSwatchesChanged: (newSwatches) =>
                    setState(() => swatches = newSwatches),
              ),
            ),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            children: [
              Text(
                'Select the background & appbar colors',
                style: textTheme.titleLarge?.copyWith(color: bodyTextColor),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: ColorButton(
                        key: const Key('c1'),
                        color: backgroundColor,
                        swatches: swatches,
                        onColorChanged: (value) =>
                            setState(() => backgroundColor = value),
                        onSwatchesChanged: (newSwatches) =>
                            setState(() => swatches = newSwatches),
                      ),
                    ),
                    Center(
                      child: ColorButton(
                        key: const Key('c1'),
                        size: 32,
                        color: backgroundColor,
                        config: const ColorPickerConfig(enableLibrary: false),
                        swatches: swatches,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: backgroundColor,
                          border: Border.all(width: 4, color: Colors.black),
                        ),
                        onColorChanged: (value) => setState(
                          () => backgroundColor = value,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        EyedropperButton(
                          onColor: (value) =>
                              setState(() => backgroundColor = value),
                          onColorChanged: (value) => hoveredColor.value = value,
                        ),
                        ValueListenableBuilder<Color?>(
                          valueListenable: hoveredColor,
                          builder: (context, value, _) => Container(
                            color: value ?? Colors.transparent,
                            width: 24,
                            height: 24,
                          ),
                        )
                      ],
                    ),
                    Center(
                      child: ElevatedButton(
                        child: const Text('Open ColorPicker'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: ColorPicker(
                                  selectedColor: backgroundColor,
                                  onColorSelected: (value) =>
                                      setState(() => backgroundColor = value),
                                  config: const ColorPickerConfig(
                                    enableLibrary: false,
                                    enableEyePicker: false,
                                  ),
                                  onClose: Navigator.of(context).pop,
                                  onEyeDropper: () {},
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Center(child: Image.asset('images/img.png')),
            ],
          ),
        ),
      ),
    );
  }
}
