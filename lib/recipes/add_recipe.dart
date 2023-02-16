import 'dart:io';

import 'package:cook_n_shop/api/marmiton_api.dart';
import 'package:cook_n_shop/models/recipe.dart';
import 'package:cook_n_shop/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;


import 'add_recipe_default.dart';

class AddRecipe extends StatefulWidget {
  const AddRecipe({Key? key}) : super(key: key);

  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {

  bool _isMarmiton = false;
  Map<String, String>? recipe;
  late TextEditingController _controller;

  static String _displayStringForOption(Map<String, String> recipe) => recipe['title']!;


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Ingredient'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddRecipeDefault())).then(
                (value) {
                  Navigator.pop(context);
                }
              );
            },
            child: const Text('Créer une recette'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isMarmiton = true;
              });
            },
            child: const Text('Ajouter une recette marmiton'),
          ),
          //Text(MySharedPreferences.errorsMSG.join('\n')),
          if (_isMarmiton)
            Autocomplete<Map<String, String>>(
              displayStringForOption: _displayStringForOption,
              optionsBuilder: (TextEditingValue textEditingValue) async {
                MySharedPreferences.errorsMSG.clear();
                if (textEditingValue.text == '') {
                  return const Iterable<Map<String, String>>.empty();
                }
                List<Map<String, String>> recipes = await MarmitonApi.searchRecipes(textEditingValue.text);
                return recipes;
              },
              onSelected: (Map<String, String> recipe) {
                this.recipe = recipe;
              },
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                _controller = textEditingController;
                return TextField(
                  focusNode: focusNode,
                  controller: textEditingController,
                  onSubmitted: (String value) {
                    onFieldSubmitted();
                  },
                );
              }
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        if (_isMarmiton)
          TextButton(
            onPressed: () async {
              if (recipe != null && _controller.text == recipe!['title']) {
                if (!MySharedPreferences.recipes.any((element) => element.name == recipe!['title'])) {
                  await addRecipe();
                  setState(() {});
                  if (mounted) Navigator.pop(context);
                } else {
                  print('Recipe already exists');
                }
              }
            },
            child: const Text('Add'),
          ),
      ],
    );
  }

  Future<void> addRecipe() async {
    assert(this.recipe != null);
    final recipeDetails = await MarmitonApi.recipe(this.recipe!['url']!);
    Recipe recipe = Recipe.fromJson(recipeDetails);

    Uri uri = Uri.parse(recipe.image!);
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = "${documentDirectory.path}/images/recipe/${recipe.id}";
    var filePathAndName = '${documentDirectory.path}/images/recipe/${recipe.id}/${uri.pathSegments.last}';

    await Directory(firstPath).create(recursive: true);
    File file2 = File(filePathAndName);
    file2.writeAsBytesSync(response.bodyBytes);

    recipe.image = filePathAndName;
    recipe.isNetworkImage = false;

    MySharedPreferences.addRecipe(recipe);
  }
}
