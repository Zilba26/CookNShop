import 'package:cook_n_shop/models/recipe.dart';
import 'package:flutter/material.dart';

class RecipeScreen extends StatelessWidget {

  final Recipe recipe;

  const RecipeScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            recipe.image != null ? Container(color: Colors.black, width: MediaQuery.of(context).size.width, child: Image.network(recipe.image!, height: 200, fit: BoxFit.fitHeight,)) : const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(recipe.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            ),
            if (recipe.description != null) Text(recipe.description!),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                children: recipe.ingredients.map((ingredient) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Expanded(child: Text(ingredient.text, style: const TextStyle(fontSize: 17))),
                        ]
                      ),
                      const SizedBox(height: 4)
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                children: recipe.steps.map((step) {
                  return ListTile(
                    minLeadingWidth: 0,
                    horizontalTitleGap: 8,
                    leading: Text('${recipe.steps.indexOf(step) + 1}. '),
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
