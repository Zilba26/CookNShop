import 'package:cook_n_shop/api/chat_gpt_api.dart';
import 'package:cook_n_shop/ingredients/ingredients.dart';
import 'package:cook_n_shop/my_shared_preferences.dart';
import 'package:cook_n_shop/recipes/recipes.dart';
import 'package:cook_n_shop/shop/shop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MySharedPreferences.init();
  // ChatGPTAPI api = ChatGPTAPI();
  // api.request("Combien mesure la tour eiffel ?");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

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

class _MyAppState extends State<MyApp> {

  ThemeData _theme = ThemeData(primarySwatch: getMaterialColorFromColor(MySharedPreferences.themeColor));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cook'N Shop",
      debugShowCheckedModeBanner: false,
      theme: _theme,
      home: Main(
        onThemeChanged: (theme) {
          setState(() {
            _theme = theme;
          });
          MySharedPreferences.themeColor = theme.primaryColor;
        },
      ),
    );
  }
}

class Main extends StatefulWidget {
  final Function(ThemeData) onThemeChanged;

  const Main({super.key, required this.onThemeChanged});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    const Shop(),
    const Ingredients(),
    const Recipes()
  ];

  String getAppbarTitle() {
    switch (_selectedIndex) {
      case 0:
        return "Ma liste de courses";
      case 1:
        return "Mes ingrédients";
      case 2:
        return "Mes recettes";
      default:
        return "Cook'N Shop";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getAppbarTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Color pickerColor = Theme.of(context).primaryColor;
              showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setDialogState) {
                    return AlertDialog(
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: Theme.of(context).primaryColor,
                          onColorChanged: (color) {
                            setDialogState(() {
                              widget.onThemeChanged(ThemeData(primarySwatch: getMaterialColorFromColor(color)));
                            });
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              widget.onThemeChanged(ThemeData(primarySwatch: getMaterialColorFromColor(const Color(MySharedPreferences.baseColor))));
                            });
                          },
                          child: const Text("Reset"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              widget.onThemeChanged(ThemeData(primarySwatch: getMaterialColorFromColor(pickerColor)));
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text("Fermer"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Valider"),
                        ),
                      ],
                    );
                  }
                )
              );
            },
          ),
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Ingrédients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Recettes',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
