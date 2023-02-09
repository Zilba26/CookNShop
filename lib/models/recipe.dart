import 'package:cook_n_shop/models/recipe_ingredient.dart';
import 'package:cook_n_shop/my_shared_preferences.dart';

class Recipe {
  int id;
  String name;
  String? description;
  String? image;
  List<RecipeIngredient> ingredients;
  List<String> steps;

  Recipe({
    id,
    required this.name,
    required this.description,
    required this.image,
    required this.ingredients,
    required this.steps,
  }) : id = id ?? MySharedPreferences.lastRecipeId + 1;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? MySharedPreferences.lastRecipeId + 1,
      name: json['name'],
      description: json['description'],
      image: json['image'],
      ingredients: (json['ingredients'].runtimeType == List<RecipeIngredient>) ? List<RecipeIngredient>.from(json['ingredients']) : List<RecipeIngredient>.from(json['ingredients'].map((x) => RecipeIngredient.fromJson(x))),
      steps: List<String>.from(json['steps']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'ingredients': ingredients,
      'steps': steps,
    };
  }
}