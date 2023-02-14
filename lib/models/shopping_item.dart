import 'package:cook_n_shop/models/ingredient.dart';

class ShoppingItem {
  Ingredient ingredient;
  int quantity;

  ShoppingItem({required this.ingredient, required this.quantity});

  Map<String, dynamic> toJson() => {
    'ingredient': ingredient.toJson(),
    'quantity': quantity,
  };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      ingredient: Ingredient.fromJson(json['ingredient']),
      quantity: json['quantity'],
    );
  }
}