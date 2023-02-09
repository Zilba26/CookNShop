import 'package:cook_n_shop/models/ingredient.dart';

class RecipeIngredient {
  final Ingredient ingredient;
  final int? quantity;
  final String text;

  RecipeIngredient({
    required this.ingredient,
    required this.quantity,
    required this.text,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      ingredient: Ingredient.fromJson(json['ingredient']),
      quantity: json['quantity'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredient': ingredient,
      'quantity': quantity,
      'text': text,
    };
  }
}