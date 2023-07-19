import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_curator/ingredients.dart';
import 'helpers/cookie_manager.dart';
import 'molecules/recipe_create_card.dart';
import 'molecules/recipe_edit_card.dart';

class EditRecipe extends StatefulWidget {
  const EditRecipe({super.key, required this.id});

  final int id;

  @override
  State<EditRecipe> createState() => _EditRecipeState();
}

class _EditRecipeState extends State<EditRecipe> {
  bool isLoading = true;
  dynamic data;
  List<dynamic> selectedIngredients = [];
  List<dynamic> selectedCookingTerms = [];
  void getRecipe() async {
    http.Response response = await http.get(
      Uri.http('localhost:8001', '/recipes/by_recipe_id/${widget.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        'Authorization': MyCookieManager().getCookie(),
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        data = jsonDecode(response.body);
        for (dynamic i in data["ingredients"]) {
          if (i["type"] == "Ingredient")
            selectedIngredients.add(i);
          else
            selectedCookingTerms.add(i);
        }
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    getRecipe();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Update recipe'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: isLoading
            ? const CircularProgressIndicator()
            : RecipeEditCard(
                title: data["title"],
                description: data["description"],
                instructions: data["instructions"],
                cookingTime: data["cooking_time"].toString(),
                servingSize: data["serving_size"].toString(),
                prevSelectedIngredients: selectedIngredients,
                prevSelectedCookingTerms: selectedCookingTerms,
                id: widget.id,
              ));
  }
}
