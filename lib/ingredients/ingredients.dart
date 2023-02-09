import 'dart:convert';

import 'package:cook_n_shop/ingredients/add_ingredient.dart';
import 'package:cook_n_shop/api/marmiton_api.dart';
import 'package:cook_n_shop/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/ingredient.dart';

class Ingredients extends StatefulWidget {
  const Ingredients({Key? key}) : super(key: key);

  @override
  State<Ingredients> createState() => _IngredientsState();
}

class _IngredientsState extends State<Ingredients> {
  List<Ingredient> ingredients = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    getIngredients();
    super.initState();
  }

  Future<void> getIngredients() async {
    // final String response = await rootBundle.loadString('assets/data/ingredients.json');
    // final data = await json.decode(response);
    // List<Ingredient> baseIngredients = List<Ingredient>.from(data.map((model) => Ingredient.fromJson(model)));
    List<Ingredient> localIngredients = MySharedPreferences.ingredients;
    setState(() {
      ingredients = localIngredients;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding:
                  const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                          hintText: 'Ajouter un ingrédient',
                          border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        setState(() {
                          MySharedPreferences.addIngredient(
                              Ingredient.fromName(_controller.text));
                          _controller.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ingredients.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(ingredients[index].name),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            MySharedPreferences.removeIngredientFromShoppingList(ingredients[index]);
                          });
                        },
                      ),
                      Text((MySharedPreferences.checkIngredientFromShoppingList(ingredients[index]) ? MySharedPreferences.getIngredientQuantityFromShoppingList(ingredients[index]).toString() : "0") + ingredients[index].unit.unit),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            MySharedPreferences.addIngredientToShoppingList(ingredients[index]);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            Ingredient ingredientRemoved =
                                ingredients.removeAt(index);
                            MySharedPreferences.removeIngredient(
                                ingredientRemoved);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     showDialog(
      //         context: context,
      //         builder: (BuildContext context) {
      //           return AddIngredient();
      //         }
      //     );
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
