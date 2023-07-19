import 'package:flutter/material.dart';
import 'helpers/cookie_manager.dart';
import 'package:http/http.dart' as http;
import 'molecules/recipe_card.dart';
import 'recipe.dart';
import 'dart:convert';

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  List<dynamic> recipes = [];
  String token = "";
  bool isLoading = true;

  void getFavourites() async {
    List<dynamic> favs = [];
    try {
      http.Response response = await http.get(
        Uri.http('localhost:8004', '/favourites'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "Access-Control-Allow-Origin": "*",
          'Accept': '*/*',
          'Authorization': token,
        },
      );
      favs = jsonDecode(response.body);
      for (int i in favs) {
        await getRecipe(i);
      }
      setState(() {
        recipes = recipes;
        isLoading = false;
      });
    } catch (e) {
      print("Exception caught: ");
      print(e);
    }
  }

  Future<void> getRecipe(int id) async {
    try {
      print("Printing cookie:");
      print(MyCookieManager().getCookie());
      http.Response response = await http.get(
        Uri.http('localhost:8001', '/recipes/by_recipe_id/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "Access-Control-Allow-Origin": "*",
          'Accept': '*/*',
          'Authorization': token,
        },
      );
      if (response.statusCode == 200) {
        recipes.add(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        Navigator.popAndPushNamed(context, '/login');
      }
    } catch (e) {
      print("Exception caught: ");
      print(e);
    }
  }

  void getCookie() {
    setState(() {
      token = MyCookieManager().getCookie();
    });
  }

  @override
  void initState() {
    super.initState();
    getCookie();
    getFavourites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Favourites"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                ),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  return RecipeCard(
                    data: recipes[index],
                  );
                },
              ),
      ),
    );
  }
}
