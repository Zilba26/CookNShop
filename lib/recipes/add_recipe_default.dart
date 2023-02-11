import 'package:cook_n_shop/components/unite_dropdown_button.dart';
import 'package:cook_n_shop/models/ingredient.dart';
import 'package:cook_n_shop/models/recipe.dart';
import 'package:cook_n_shop/models/recipe_ingredient.dart';
import 'package:cook_n_shop/models/units.dart';
import 'package:flutter/material.dart';

import '../my_shared_preferences.dart';

class _IngredientOption {
  Ingredient? ingredient;
  TextEditingController controller;
  ValueNotifier<Unit> unitNotifier;
  TextEditingController quantityController = TextEditingController();

  _IngredientOption({required this.controller}) : unitNotifier = ValueNotifier(baseUnits[0]);
}

class AddRecipeDefault extends StatefulWidget {
  const AddRecipeDefault({Key? key}) : super(key: key);

  @override
  State<AddRecipeDefault> createState() => _AddRecipeDefaultState();
}

class _AddRecipeDefaultState extends State<AddRecipeDefault> {

  String? image;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<_IngredientOption> _ingredientsControllers = [_IngredientOption(controller: TextEditingController())];
  final List<TextEditingController> _stepsControllers = [TextEditingController()];

  @override
  void initState() {
    _stepsControllers.first.addListener(() {
      if (_stepsControllers.last.text.isNotEmpty) {
        _addStepController();
      }
    });

    super.initState();
  }

  void _addStepController() {
    setState(() {
      _stepsControllers.add(TextEditingController());
    });
    _stepsControllers.last.addListener(() {
      if (_stepsControllers.last.text.isNotEmpty) {
        _addStepController();
      } else {
        if (_stepsControllers[_stepsControllers.length - 2].text.isEmpty) {
          setState(() {
            _stepsControllers.removeLast();
          });
        }
      }
    });
  }

  void _addIngredientController() {
    setState(() {
      _ingredientsControllers.add(_IngredientOption(controller: TextEditingController()));
    });
    _ingredientsControllers.last.controller.addListener(() {
      if (_ingredientsControllers.last.controller.text.isNotEmpty) {
        _addIngredientController();
      } else {
        if (_ingredientsControllers[_ingredientsControllers.length - 2].controller.text.isEmpty) {
          setState(() {
            _ingredientsControllers.removeLast();
          });
        }
      }
    });
  }

  static String _displayStringForOption(Ingredient option) => option.name;

  void showDialogImage(context) {
    TextEditingController imageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter une image"),
          content: TextField(
            controller: imageController,
            decoration: const InputDecoration(
                labelText: "URL de l'image"
            ),
            onSubmitted: (value) {
              setState(() {
                if (value.isEmpty) {
                  image = null;
                } else {
                  image = value;
                }
              });
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (imageController.text.isEmpty) {
                    image = null;
                  } else {
                    image = imageController.text;
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text("Valider"),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Création d'une recette"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black)
                ),
                child: image != null
                    ? GestureDetector(
                      onTap: () {
                        showDialogImage(context);
                      },
                      child: Image.network(image!),
                    )
                    : Center(
                      child: CircleAvatar(
                        child: IconButton(
                          onPressed: () {
                            showDialogImage(context);
                          },
                          icon: const Icon(Icons.download, color: Colors.white,),
                        ),
                      ),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nom de la recette",
                  border: OutlineInputBorder()
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _descriptionController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder()
                ),
              ),
            ),
            Column(
              children: _ingredientsControllers.map((controller) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Autocomplete<Ingredient>(
                          displayStringForOption: _displayStringForOption,
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<Ingredient>.empty();
                            }
                            return MySharedPreferences.ingredients.where((ingredient) {
                              return ingredient.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (Ingredient selection) {
                            setState(() {
                              controller.ingredient = selection;
                              controller.unitNotifier.value = selection.unit;
                            });
                          },
                          fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                            fieldTextEditingController.addListener(() {
                              if (_ingredientsControllers.last.controller.text.isNotEmpty) {
                                _addIngredientController();
                              } else {
                                if (_ingredientsControllers.length > 1 && _ingredientsControllers[_ingredientsControllers.length - 2].controller.text.isEmpty) {
                                  setState(() {
                                    _ingredientsControllers.removeLast();
                                  });
                                }
                              }
                            });
                            _ingredientsControllers[_ingredientsControllers.indexOf(controller)].controller = fieldTextEditingController;
                            return TextField(
                              controller: fieldTextEditingController,
                              focusNode: fieldFocusNode,
                              onSubmitted: (String value) {
                                onFieldSubmitted();
                              },
                              decoration: const InputDecoration(
                                labelText: "Ingrédient",
                                border: OutlineInputBorder()
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: TextField(
                          controller: _ingredientsControllers[_ingredientsControllers.indexOf(controller)].quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Quantité",
                            border: OutlineInputBorder()
                          ),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      UniteDropdownButton(
                        // onTap: (value) {
                        //   _ingredientsControllers[_ingredientsControllers.indexOf(controller)].unit = value;
                        // },
                        controller: _ingredientsControllers[_ingredientsControllers.indexOf(controller)].unitNotifier,
                      ),
                      const SizedBox(width: 10,),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                child: Text("Etapes :", style: Theme.of(context).textTheme.titleLarge,),
              ),
            ),
            Column(
              children: _stepsControllers.map((controller) {
                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text("${_stepsControllers.indexOf(controller) + 1}. "),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: controller,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Etape ${_stepsControllers.indexOf(controller) + 1}",
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String name = _nameController.text;
                String description = _descriptionController.text;
                List<RecipeIngredient> ingredients = [];
                for (int i = 0; i < _ingredientsControllers.length; i++) {
                  if (_ingredientsControllers[i].controller.text.isNotEmpty) {
                    Ingredient ingredient;
                    if (_ingredientsControllers[i].ingredient != null && _ingredientsControllers[i].ingredient?.name == _ingredientsControllers[i].controller.text) {
                      if (_ingredientsControllers[i].ingredient?.unit == _ingredientsControllers[i].unitNotifier.value) {
                        ingredient = _ingredientsControllers[i].ingredient!;
                      } else {
                        ingredient = Ingredient.fromName(
                          _ingredientsControllers[i].ingredient!.name,
                          img: _ingredientsControllers[i].ingredient!.img,
                          unit: _ingredientsControllers[i].unitNotifier.value,
                        );
                        MySharedPreferences.addIngredient(ingredient);
                      }
                    } else {
                      ingredient = Ingredient.fromName(
                        _ingredientsControllers[i].controller.text,
                        unit: _ingredientsControllers[i].unitNotifier.value,
                      );
                      MySharedPreferences.addIngredient(ingredient);
                    }
                    int? quantity = _ingredientsControllers[i].quantityController.text.isNotEmpty ? int.parse(_ingredientsControllers[i].quantityController.text) : null;
                    RecipeIngredient recipeIngredient = RecipeIngredient(
                      ingredient: ingredient,
                      quantity: quantity,
                      text: "$quantity${ingredient.unit} ${ingredient.name}",
                    );
                    ingredients.add(recipeIngredient);
                  }
                }
                List<String> steps = _stepsControllers.map((controller) => controller.text).toList();
                for (int i = 0; i < steps.length; i++) {
                  if (steps[i].isEmpty) {
                    steps.removeAt(i);
                  }
                }
                Recipe recipe = Recipe(name: name, description: description, image: image, ingredients: ingredients, steps: steps);
                MySharedPreferences.addRecipe(recipe);
                Navigator.pop(context);
              },
              child: const Text("Ajouter la recette"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
