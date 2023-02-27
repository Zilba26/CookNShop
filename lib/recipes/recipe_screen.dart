import 'dart:io';
import 'dart:math' as Math;

import 'package:cook_n_shop/components/ingredient_recipe_screen.dart';
import 'package:cook_n_shop/models/recipe.dart';
import 'package:flutter/material.dart';

class RecipeScreen extends StatefulWidget {

  final Recipe recipe;

  const RecipeScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {

  bool showAllIngredients = false;

  Widget getImage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16.0),
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 40,
            maxHeight: 200,
          ),
          child: widget.recipe.image != null ? (widget.recipe.isNetworkImage ? Image.network(widget.recipe.image!, fit: BoxFit.fitWidth,) : Image.file(File(widget.recipe.image!))) : const SizedBox(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            getImage(context),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Text(widget.recipe.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            ),
            if (widget.recipe.description != null) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(widget.recipe.description!),
            ),
            Column(
              children: [
                Column(
                  children: widget.recipe.ingredients.map((ingredient) {
                    return IngredientRecipeScreen(recipeIngredient: ingredient);
                    //   Column(
                    //   children: [
                    //     Row(
                    //       children: [
                    //         Padding(
                    //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //           child: Container(
                    //             width: 10,
                    //             height: 10,
                    //             decoration: const BoxDecoration(
                    //               color: Colors.black,
                    //               shape: BoxShape.circle,
                    //             ),
                    //           ),
                    //         ),
                    //         Expanded(child: Text(ingredient.text, style: const TextStyle(fontSize: 17))),
                    //       ]
                    //     ),
                    //     const SizedBox(height: 4)
                    //   ],
                    // );
                  }).toList().sublist(0, showAllIngredients ? widget.recipe.ingredients.length : Math.min(4, widget.recipe.ingredients.length))
                ),
                if (widget.recipe.ingredients.length > 4) GestureDetector(
                  onTap: () {
                    setState(() {
                      showAllIngredients = !showAllIngredients;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      showAllIngredients ? Icon(Icons.arrow_drop_up, color: Theme.of(context).primaryColor,) : Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor,),
                      showAllIngredients ? Text('Voir moins', style: TextStyle(color: Theme.of(context).primaryColor),) : Text('Voir tout',style: TextStyle(color: Theme.of(context).primaryColor),),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                children: widget.recipe.steps.map((step) {
                  return ListTile(
                    minLeadingWidth: 0,
                    horizontalTitleGap: 8,
                    leading: Text('${widget.recipe.steps.indexOf(step) + 1}. '),
                    title: Text(step),
                  );
                }).toList()
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
