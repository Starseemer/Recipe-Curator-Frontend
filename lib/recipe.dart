import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'helpers/cookie_manager.dart';
import 'atoms/like_button.dart';
import 'atoms/icon_text.dart';
import 'atoms/share_button.dart';

class Recipe extends StatefulWidget {
  const Recipe({super.key, required this.id});

  final int id;
  @override
  State<Recipe> createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
  dynamic data = {
    'title': 'No title',
    'description': 'No description',
    'instructions': 'No instructions',
    'ingredients': [
      {"name": "No ingredients"}
    ],
  };

  int user_id = 0;

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
      setState(() {
        data = jsonDecode(response.body);
      });
    } else if (response.statusCode == 401) {
      Navigator.popAndPushNamed(context, '/login');
    }
  }

  void getUserId() async {
    http.Response response = await http.get(
      Uri.http('localhost:8000', '/token-check'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        'Authorization': MyCookieManager().getCookie(),
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        user_id = jsonDecode(response.body)["user"]['id'];
      });
    } else if (response.statusCode == 401) {
      Navigator.popAndPushNamed(context, '/login');
    }
  }

  void deleteRecipe() async {
    http.Response response = await http.delete(
      Uri.http('localhost:8001', '/recipes/${widget.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        'Authorization': MyCookieManager().getCookie(),
      },
    );

    response.statusCode == 200
        ? ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recipe deleted!'),
            ),
          )
        : ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recipe deletion failed!'),
            ),
          );
    Navigator.pop(context);
  }

  listSharedVocs(List<dynamic> vocs) {
    List<Widget> ingWidgets = [];
    List<Widget> ctWidgets = [];
    for (var ingredient in data['ingredients']) {
      if (ingredient["type"] == "Ingredient") {
        ingWidgets.add(Text("\u2022 ${ingredient["name"]}",
            style: TextStyle(fontSize: 20, color: Colors.white70)));
      } else {
        ctWidgets.add(Text("\u2022 ${ingredient["name"]}",
            style: TextStyle(fontSize: 20, color: Colors.white70)));
      }
    }
    if (ingWidgets.isEmpty) {
      ingWidgets.add(const Text("\u2022 No ingredient found for this recipe",
          style: TextStyle(fontSize: 20, color: Colors.white70)));
    }
    if (ctWidgets.isEmpty) {
      ctWidgets.add(const Text("\u2022 No cooking term found for this recipe",
          style: TextStyle(fontSize: 20, color: Colors.white70)));
    }
    Widget ing = const Text(
      "Ingredients:",
      style: TextStyle(
          fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
    );

    Widget ct = const Text(
      "Cooking Terms:",
      style: TextStyle(
          fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
    );

    return [
      ing,
      ...ingWidgets,
      const SizedBox(
        height: 20,
      ),
      ct,
      ...ctWidgets
    ];
  }

  @override
  void initState() {
    super.initState();
    getRecipe();
    getUserId();
  }

  @override
  Widget build(BuildContext context) {
    String baseLoc = Uri.base.toString().split("/home")[0];
    print("${baseLoc}/recipe/${widget.id}");
    return Scaffold(
      appBar: AppBar(
        title: Text(data['title']),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popAndPushNamed(context, '/home');
          },
        ),
        actions: [
          LikeButton(id: widget.id),
          ShareButton(url: "${baseLoc}/recipe/${widget.id}"),
          data["user_id"] == user_id
              ? IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit-recipe/${widget.id}')
                        .then((value) => getRecipe());
                  },
                  icon: const Icon(Icons.edit, size: 40, color: Colors.white))
              : Container(),
          data["user_id"] == user_id
              ? IconButton(
                  onPressed: () {
                    deleteRecipe();
                  },
                  icon: const Icon(Icons.delete, size: 40, color: Colors.white))
              : Container(),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Description:",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    data['description'],
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    IconText(
                      icon: Icon(Icons.timer, color: Colors.white),
                      text: "Cooking time: ${data['cooking_time']} min",
                      textStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 20),
                    IconText(
                      icon: const Icon(Icons.room_service, color: Colors.white),
                      text: "Serving size : ${data['serving_size']}",
                      textStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  ...listSharedVocs(data['ingredients']),
                  SizedBox(height: 20),
                  const Text(
                    "Instructions:",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    data['instructions'],
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
