import 'package:cook_n_shop/models/recipe_ingredient.dart';
import 'package:cook_n_shop/my_shared_preferences.dart';
import 'package:cook_n_shop/recipes/add_recipe.dart';
import 'package:cook_n_shop/recipes/add_recipe_default.dart';
import 'package:cook_n_shop/recipes/recipe_screen.dart';
import 'package:flutter/material.dart';

import '../models/recipe.dart';

class Recipes extends StatefulWidget {
  const Recipes({Key? key}) : super(key: key);

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  List<Recipe> recipes = MySharedPreferences.recipes;

  setThisState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: recipes.isEmpty ? const Center(
          child: Text("Aucune recette"),
        ) : ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RecipeScreen(
                        recipe: recipes[index],
                      )));
            },
            child: ListTile(
              title: Text(recipes[index].name),
              trailing: PopupMenuButton(
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: "add",
                      child: Text('Ajouter à la liste de courses'),
                    ),
                    const PopupMenuItem(
                      value: "edit",
                      child: Text('Modifier'),
                    ),
                    const PopupMenuItem(
                      value: "delete",
                      child: Text('Supprimer'),
                    ),
                  ];
                },
                onSelected: (String value) async {
                  switch (value) {
                    case "add":
                      List<RecipeIngredient> ingredients = recipes[index].ingredients;
                      for (RecipeIngredient ingredient in ingredients) {
                        if (MySharedPreferences.ingredients.any((element) => element.id == ingredient.ingredient.id) && ingredient.quantity != null) {
                          MySharedPreferences.addIngredientToShoppingList(ingredient.ingredient, quantity: ingredient.quantity!);
                        }
                      }
                      break;
                    case "edit":
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddRecipeDefault(recipe: recipes[index],))).then((value) => setThisState());
                      break;
                    case "delete":
                      await MySharedPreferences.removeRecipe(recipes[index]);
                      setState(() {});
                      break;
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddRecipe();
            }).then((value) => setThisState());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
