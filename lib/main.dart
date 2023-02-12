import 'package:cook_n_shop/api/chat_gpt_api.dart';
import 'package:cook_n_shop/ingredients/ingredients.dart';
import 'package:cook_n_shop/my_shared_preferences.dart';
import 'package:cook_n_shop/recipes/recipes.dart';
import 'package:cook_n_shop/settings/settings.dart';
import 'package:cook_n_shop/shop/shop.dart';
import 'package:flutter/material.dart';

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

class _MyAppState extends State<MyApp> {

  ThemeData _theme = ThemeData();

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
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Settings(
                    onThemeChanged: widget.onThemeChanged
                  )));
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
