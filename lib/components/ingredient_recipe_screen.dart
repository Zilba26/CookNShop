import 'package:cook_n_shop/models/ingredient.dart';
import 'package:cook_n_shop/models/recipe_ingredient.dart';
import 'package:flutter/material.dart';

class IngredientRecipeScreen extends StatelessWidget {

  final RecipeIngredient recipeIngredient;
  late final Ingredient ingredient = recipeIngredient.ingredient;

  IngredientRecipeScreen({Key? key, required this.recipeIngredient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            getImage(),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ingredient.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                  if (recipeIngredient.quantity != null) Text("${recipeIngredient.quantity} ${ingredient.unit.unit}", style: const TextStyle(color: Colors.grey),),
                ]
              ),
            )
          ]
        ),
      ),
    );
  }

  Widget getImage() {
    return SizedBox(
      width: 50,
      child: ingredient.image == null ? const SizedBox() : (ingredient.isNetwork ? Image.network(ingredient.image!) : Image.asset(ingredient.image!))
    );
  }
}
