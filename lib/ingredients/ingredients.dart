import 'package:cook_n_shop/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';

class Ingredients extends StatefulWidget {
  const Ingredients({Key? key}) : super(key: key);

  @override
  State<Ingredients> createState() => _IngredientsState();
}

class _IngredientsState extends State<Ingredients> {
  List<Ingredient> ingredients = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final List<FocusNode> _focusNodes;
  int? quantityIndex;

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
    _focusNodes = List.generate(
      ingredients.length,
          (index) => FocusNode(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.restaurant_menu),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                          hintText: 'Ajouter un ingrédient',
                          border: InputBorder.none
                      ),
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
                            MySharedPreferences.minusIngredientToShoppingList(ingredients[index]);
                          });
                        },
                      ),
                      quantityIndex == index
                        ? Row(
                          children: [
                            IntrinsicWidth(
                              child: Focus(
                                onFocusChange: (bool hasFocus) {
                                  setState(() {
                                    if (!hasFocus) quantityIndex = null;
                                  });
                                },
                                child: TextField(
                                  controller: _quantityController,
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none
                                  ),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onSubmitted: (String value) {
                                    if (quantityIndex != null) {
                                      if (_quantityController.text.isEmpty) {
                                        MySharedPreferences.removeIngredientFromShoppingList(ingredients[quantityIndex!]);
                                      } else {
                                        MySharedPreferences.setIngredientQuantityFromShoppingList(ingredients[quantityIndex!], int.parse(_quantityController.text));
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            Text(ingredients[index].unit.unit),
                          ],
                        )
                        : GestureDetector(
                          onTap: () {
                            if (quantityIndex != null) {
                              if (_quantityController.text.isEmpty) {
                                MySharedPreferences.removeIngredientFromShoppingList(ingredients[quantityIndex!]);
                              } else {
                                MySharedPreferences.setIngredientQuantityFromShoppingList(ingredients[quantityIndex!], int.parse(_quantityController.text));
                              }
                            }
                            setState(() {
                              _quantityController.text = MySharedPreferences.checkIngredientFromShoppingList(ingredients[index]) ? MySharedPreferences.getIngredientQuantityFromShoppingList(ingredients[index]).toString() : "";
                              quantityIndex = index;
                              _focusNodes[index].requestFocus();
                            });
                          },
                          child: Text((MySharedPreferences.checkIngredientFromShoppingList(ingredients[index]) ? MySharedPreferences.getIngredientQuantityFromShoppingList(ingredients[index]).toString() : "0") + ingredients[index].unit.unit)
                      ),
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
                            List<Recipe> recipes = MySharedPreferences.checkIngredientInRecipes(ingredients[index]);
                            if (recipes.isEmpty) {
                              Ingredient ingredientRemoved = ingredients.removeAt(index);
                              MySharedPreferences.removeIngredient(ingredientRemoved);
                              MySharedPreferences.removeIngredientFromShoppingList(ingredientRemoved);
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Supprimer l'ingrédient"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Cet ingrédient est utilisé dans les recettes suivantes :"),
                                        ...recipes.map((recipe) => Text("- ${recipe.name}")).toList(),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text("Annuler"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("Supprimer"),
                                        onPressed: () {
                                          Ingredient ingredientRemoved = ingredients.removeAt(index);
                                          MySharedPreferences.removeIngredient(ingredientRemoved);
                                          MySharedPreferences.removeIngredientFromShoppingList(ingredientRemoved);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                }
                              );
                            }
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
