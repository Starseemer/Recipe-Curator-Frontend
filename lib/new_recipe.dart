import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'helpers/cookie_manager.dart';
import 'molecules/recipe_create_card.dart';

class NewRecipe extends StatefulWidget {
  const NewRecipe({super.key});

  @override
  State<NewRecipe> createState() => _NewRecipeState();

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const NewRecipe());
  }
}

class _NewRecipeState extends State<NewRecipe> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Create a new recipe'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.popAndPushNamed(context, "/home");
              },
            )),
        body: RecipeCreateCard());
  }
}
