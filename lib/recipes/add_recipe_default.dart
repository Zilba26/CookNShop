import 'dart:async';
import 'dart:io';

import 'package:cook_n_shop/components/unite_dropdown_button.dart';
import 'package:cook_n_shop/models/ingredient.dart';
import 'package:cook_n_shop/models/recipe.dart';
import 'package:cook_n_shop/models/recipe_ingredient.dart';
import 'package:cook_n_shop/models/units.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;


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

  final _formKey = GlobalKey<FormState>();
  bool _ingredientValidate = true;
  bool _stepValidate = true;

  String? image;
  bool isNetworkImage = false;

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

  Future<String?> _validateImageFormField(value) async {
    if (value.isEmpty) {
      setState(() {
        image = null;
      });
      return null;
    } else {
      try {
        Uri uri = Uri.parse(value);
        final response = await http.get(uri).timeout(const Duration(seconds: 10));
        if (response.statusCode != 200) {
          return "L'image n'a pas été trouvé, vérifiez l'URL";
        }
        var documentDirectory = await getApplicationDocumentsDirectory();
        var firstPath = "${documentDirectory.path}/images/recipe/${MySharedPreferences.lastRecipeId}";
        var filePathAndName = '${documentDirectory.path}/images/recipe/${MySharedPreferences.lastRecipeId}/${uri.pathSegments.last}';

        await Directory(firstPath).create(recursive: true);
        File file2 = File(filePathAndName);
        file2.writeAsBytesSync(response.bodyBytes);
        setState(() {
          image = filePathAndName;
          isNetworkImage = false;
        });
        return null;
      } catch (e) {
        return "URL invalide, respectez le format http";
      }
    }
  }

  void showDialogImage(context) {
    TextEditingController imageController = TextEditingController();
    String? errorText;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setAlertDialogState) {
            return AlertDialog(
              title: const Text("Ajouter une image"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image == null) return;

                      var documentDirectory = await getApplicationDocumentsDirectory();
                      var firstPath = "${documentDirectory.path}/images/recipe/${MySharedPreferences.lastRecipeId}";
                      var filePathAndName = '${documentDirectory.path}/images/recipe/${MySharedPreferences.lastRecipeId}/${image.name}';

                      await Directory(firstPath).create(recursive: true);
                      File file2 = File(filePathAndName);
                      file2.writeAsBytesSync(await image.readAsBytes());
                      setState(() {
                        this.image = filePathAndName;
                        isNetworkImage = false;
                      });
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: const Text("Depuis le stockage"),
                  ),
                  TextFormField(
                    controller: imageController,
                    decoration: InputDecoration(
                      labelText: "URL de l'image",
                      errorText: errorText,
                    ),
                    onFieldSubmitted: (value) async {
                      errorText = await _validateImageFormField(value);
                      setAlertDialogState(() {});
                      if (!mounted || errorText != null) return;
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Annuler"),
                ),
                TextButton(
                  onPressed: () async {
                    errorText = await _validateImageFormField(imageController.text);
                    setAlertDialogState(() {});
                    if (!mounted || errorText != null) return;
                    Navigator.of(context).pop();
                  },
                  child: const Text("Valider"),
                ),
              ],
            );
          }
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
        child: Form(
          key: _formKey,
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
                        child: isNetworkImage ? Image.network(image!) : Image.file(File(image!))
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
                child: TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer un nom";
                    }
                    return null;
                  },
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
              FormField(
                validator: (value) {
                  if (_ingredientsControllers.isEmpty || _ingredientsControllers.first.controller.text.isEmpty) {
                    return "Veuillez entrer au moins un ingrédient";
                  }
                  return null;
                },
                builder: (FormFieldState state) {
                  return Column(
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
                                    decoration: InputDecoration(
                                      labelText: "Ingrédient",
                                      border: const OutlineInputBorder(),
                                      errorText: (!_ingredientValidate && _ingredientsControllers.indexOf(controller) == 0) ? 'Inscrivez au moins un ingrédient' : null,
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
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
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
                  );
                }
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                  child: Text("Etapes :", style: Theme.of(context).textTheme.titleLarge,),
                ),
              ),
              FormField(
                validator: (value) {
                  if (_stepsControllers.isEmpty || _stepsControllers.first.text.isEmpty) {
                    return "Veuillez entrer au moins une étape";
                  }
                  return null;
                },
                builder: (context) {
                  return Column(
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
                                  errorText: (!_stepValidate && _stepsControllers.indexOf(controller) == 0) ? 'Inscrivez au moins une étape' : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                }
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _ingredientValidate = _ingredientsControllers.first.controller.text.isNotEmpty;
                  _stepValidate = _stepsControllers.first.text.isNotEmpty;
                  if (!_formKey.currentState!.validate()) return;
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
                  Recipe recipe = Recipe(name: name, description: description, image: image, isNetworkImage: isNetworkImage, ingredients: ingredients, steps: steps);
                  MySharedPreferences.addRecipe(recipe);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text("Ajouter la recette", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),)
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
