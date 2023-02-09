import 'package:cook_n_shop/api/chat_gpt_api.dart';
import 'package:cook_n_shop/ingredients/ingredients.dart';
import 'package:cook_n_shop/my_shared_preferences.dart';
import 'package:cook_n_shop/recipes/recipes.dart';
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
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    const Shop(),
    const Ingredients(),
    const Recipes()
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cook'N Shop",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        //useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Cook'N Shop"),
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
      ),
    );
  }
}