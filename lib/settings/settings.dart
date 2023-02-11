import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Settings extends StatefulWidget {
  final Function(ThemeData) onThemeChanged;

  const Settings({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late Color pickerColor;

  MaterialColor getMaterialColorFromColor(Color color) {
    final primaryValue = color.value;

    Map<int, Color> swatch = <int, Color>{};
    swatch[50] = color.withOpacity(0.1);
    for (int i = 1; i <= 9; i++) {
      final int index = i * 100;
      swatch[index] = color.withAlpha(255 - (i * 10));
    }

    return MaterialColor(primaryValue, swatch);
  }

  @override
  Widget build(BuildContext context) {
    pickerColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor: pickerColor,
                    onColorChanged: (color) {
                      setState(() {
                        widget.onThemeChanged(ThemeData(primarySwatch: getMaterialColorFromColor(color)));
                      });
                    },
                  ),
                ),
              )
            );
          },
          child: const Text("Choisis ta couleur batard"),
        ),
      ),
    );
  }
}
