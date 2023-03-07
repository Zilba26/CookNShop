import 'dart:async';

import 'package:cook_n_shop/models/ingredient.dart';
import 'package:cook_n_shop/models/recipe_ingredient.dart';
import 'package:cook_n_shop/models/units.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

import '../my_shared_preferences.dart';

class MarmitonApi {
  static const baseURL = 'https://www.marmiton.org';
  static const recipeURL = '$baseURL/recettes';
  static const searchURL = '$recipeURL/recherche.aspx';

  static Future<String?> search(String query) async {
    Uri uri = Uri.parse('$searchURL?aqt=$query');
    http.Response? response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      MySharedPreferences.errorsMSG.add("TimeoutException:");
    } catch (e) {
      MySharedPreferences.errorsMSG.add("Exception:");
    }
    return response?.body;
  }

  static Future<String> searchRecipe(String recipe) async {
    final response = await http.get(Uri.parse('$baseURL$recipe'));
    return response.body;
  }

  static String? getImage(Element? element) {
    if (element != null) {
      final imgSrc = element.attributes["src"];
      if (imgSrc != null && imgSrc.startsWith("https://assets")) {
        return imgSrc;
      } else {
        return element.attributes["data-src"];
      }
    }
    return null;
  }

  static List<Map<String, String>> parseSearchResults(String response) {
    final document = parse(response);
    final results = document.getElementsByClassName('MRTN__sc-1gofnyi-2');
    List<Map<String, String>> recipes = [];
    for (var result in results) {
      final title = result.querySelector("h4")?.text;
      final url = result.attributes["href"];
      String? img = getImage(result.querySelector("img"));
      if (title != null && url != null) recipes.add({'title': title, 'img': img ?? "", 'url': url});
    }
    return recipes;
  }

  static Future<Map<String, Object>> parseRecipeResults(String response) async {
    final document = parse(response);
    final title = document.querySelector(".RCP__sc-l87aur-2 h1")?.text;
    final img = getImage(document.querySelector("main img"));
    final ingredients = document.getElementsByClassName("RCP__sc-vgpd2s-1");
    List<RecipeIngredient> ingredientsList = [];
    for (var ingredient in ingredients) {
      final ingredientQuantity = ingredient.querySelector(".RCP__sc-8cqrvd-0 span")?.text.replaceAll("\u00A0", " ");
      String? ingredientName = ingredient.querySelector(".RCP__sc-8cqrvd-3")?.text;

      //ingredient text
      String ingredientText = "$ingredientQuantity";
      if (ingredientQuantity == null || ingredientQuantity.isNotEmpty) ingredientText += " ";
      ingredientText += '${ingredient.querySelector(".RCP__sc-8cqrvd-2")?.text}';
      if (ingredientText.isEmpty) {
        ingredientName = '${ingredientName?[0].toUpperCase()}${ingredientName?.substring(1)}';
      }
      ingredientText += '$ingredientName ${ingredient.querySelector(".RCP__sc-8cqrvd-4")?.text}';
      ingredientName = '${ingredientName?[0].toUpperCase()}${ingredientName?.substring(1)}';

      int? quantity;
      Unit unit = baseUnits[0];

      if (ingredientQuantity != null) {
        if (ingredientQuantity.isNotEmpty) {
          final quantityAndUnit = ingredientQuantity.trim().split(" ");
          try {
            quantity = int.parse(quantityAndUnit[0]);
            if (quantityAndUnit.length > 1) {
              quantityAndUnit.removeAt(0);
              unit = baseUnits.firstWhere((element) => element.unit == quantityAndUnit.join(" "), orElse: () => baseUnits[0]);
            }
          } catch (e) {
            quantity = null;
          }
        }
      }

      final ingredientImg = getImage(ingredient.querySelector("img"));
      final Ingredient ingredientModel;

      if (MySharedPreferences.ingredients.any((element) => element.name.toLowerCase() == ingredientName?.toLowerCase() && element.unit == unit)) {
        ingredientModel = MySharedPreferences.ingredients.firstWhere((element) => element.name.toLowerCase() == ingredientName?.toLowerCase());
      } else {
        ingredientModel = Ingredient.fromName(ingredientName, img: ingredientImg, unit: unit);
        MySharedPreferences.addIngredient(ingredientModel);
      }

      ingredientsList.add(
        RecipeIngredient(
            ingredient: ingredientModel,
            quantity: quantity,
            text: ingredientText
        )
      );
    }
    final steps = document.getElementsByClassName("RCP__sc-1wtzf9a-3");
    List<String> stepsList = [];
    for (var step in steps) {
      final stepText = step.text;
      stepsList.add(stepText);
    }
    return {'name': title ?? "", 'image': img ?? "", 'ingredients': ingredientsList, 'steps': stepsList};
  }

  static Future<List<Map<String, String>>> searchRecipes(String query) async {
    final response = await search(query);
    if (response == null) return [];
    return parseSearchResults(response);
  }

  static Future<Map<String, Object>> recipe(String recipe) async {
    final response = await searchRecipe(recipe);
    return await parseRecipeResults(response);
  }
}