import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_select/flutter_awesome_select.dart';
import 'package:flutter_custom_selector/flutter_custom_selector.dart';
import 'package:http/http.dart' as http;
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:recipe_curator/ingredients.dart';
import '../helpers/cookie_manager.dart';
import '../atoms/selected_sharedvoc_bar.dart';

class RecipeEditCard extends StatefulWidget {
  RecipeEditCard({
    super.key,
    this.id = 0,
    this.title = "",
    this.description = "",
    this.instructions = "",
    this.cookingTime = "",
    this.servingSize = "",
    this.prevSelectedIngredients = const [
      {"id": 1, "name": "empty", "description": "empty"}
    ],
    this.prevSelectedCookingTerms = const [
      {"id": 1, "name": "empty", "description": "empty"}
    ],
  });

  final int id;
  final String title;
  final String description;
  final String instructions;
  final String cookingTime;
  final String servingSize;
  List<dynamic> prevSelectedIngredients;
  List<dynamic> prevSelectedCookingTerms;

  @override
  State<RecipeEditCard> createState() => _RecipeEditCardState();
}

class _RecipeEditCardState extends State<RecipeEditCard> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _instController = TextEditingController();
  final _cookingController = TextEditingController();
  final _servingController = TextEditingController();
  bool _isSubmitting = false;
  List<S2Choice<int>> _ingredients = [];
  List<S2Choice<int>> _cookingTerms = [];
  List<int> _initialIngredients = [];
  List<int> _initialCookingTerms = [];

  void setValues() {
    setState(() {
      _titleController.text = widget.title;
      _descController.text = widget.description;
      _instController.text = widget.instructions;
      _cookingController.text = widget.cookingTime;
      _servingController.text = widget.servingSize;
      for (var ingredient in widget.prevSelectedIngredients) {
        _initialIngredients.add(ingredient['id']);
      }
      _initialIngredients = _initialIngredients;

      for (var cookingTerm in widget.prevSelectedCookingTerms) {
        _initialCookingTerms.add(cookingTerm['id']);
      }
      _initialCookingTerms = _initialCookingTerms;
    });
  }

  void getIngredients() async {
    List<dynamic> ingredients = [];
    http.Response response = await http.get(
      Uri.http('localhost:8002', '/ingredients'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        'Authorization': MyCookieManager().getCookie(),
      },
    );

    List<dynamic> cookingTerms = [];
    http.Response _response = await http.get(
      Uri.http('localhost:8002', '/cooking-terms'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        'Authorization': MyCookieManager().getCookie(),
      },
    );

    if (response.statusCode == 200) {
      ingredients = jsonDecode(response.body);
      cookingTerms = jsonDecode(_response.body);
      setState(() {
        print(ingredients);

        for (var ingredient in ingredients) {
          if (ingredient['id'].runtimeType == String) {
            _ingredients.add(S2Choice(
                value: int.parse(ingredient['id']), title: ingredient['name']));
          } else {
            _ingredients.add(
                S2Choice(value: ingredient['id'], title: ingredient['name']));
          }
        }

        for (var cookingterm in cookingTerms) {
          if (cookingterm['id'].runtimeType == String) {
            _cookingTerms.add(S2Choice(
              value: int.parse(cookingterm['id']),
              title: cookingterm['name'],
            ));
          } else {
            _cookingTerms.add(
                S2Choice(value: cookingterm['id'], title: cookingterm['name']));
          }
        }
      });
    }
  }

  updateRecipe() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updating recipe...'),
        ),
      );
      List<int> ing_ids = [];
      ing_ids.addAll(_initialIngredients);
      ing_ids.addAll(_initialCookingTerms);

      if (ing_ids.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please select at least one ingredient or cooking term!'),
          ),
        );
      } else {
        http.Response response =
            await http.put(Uri.http('localhost:8001', '/recipes/${widget.id}'),
                headers: {
                  'Content-Type': 'application/json; charset=UTF-8',
                  "Access-Control-Allow-Origin": "*",
                  'Accept': '*/*',
                  'Authorization': MyCookieManager().getCookie(),
                },
                body: jsonEncode(<String, dynamic>{
                  'title': _titleController.text,
                  'description': _descController.text,
                  'instructions': _instController.text,
                  'ingredients': ing_ids,
                  'cooking_time': int.parse(_cookingController.text),
                  'serving_size': int.parse(_servingController.text),
                }));

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recipe updated!'),
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recipe creation failed!'),
            ),
          );
        }
      }
    }
  }

  @override
  void initState() {
    setValues();
    getIngredients();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.black;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Color.fromARGB(182, 176, 190, 215),
          ),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        hintText: 'Title',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter title';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descController,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        hintText: 'Description',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                      maxLines: 2,
                    ),
                    TextFormField(
                      controller: _instController,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        hintText: 'Instructions',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter instructions';
                        }
                        return null;
                      },
                      maxLines: 20,
                    ),
                    TextFormField(
                      controller: _cookingController,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        hintText: 'Cooking Time',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter cooking time';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                    ),
                    TextFormField(
                      controller: _servingController,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        hintText: 'Serving Size',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter serving size';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                    ),
                    SmartSelect<int>.multiple(
                      title: "Ingredients",
                      // selectedValue: _initialIngredients,
                      choiceItems: _ingredients,
                      choiceType: S2ChoiceType.chips,
                      modalType: S2ModalType.bottomSheet,
                      modalStyle: S2ModalStyle(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                      ),
                      modalHeaderStyle: const S2ModalHeaderStyle(
                        backgroundColor: Colors.white,
                        textStyle: TextStyle(color: Colors.black54),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                      ),
                      modalConfig: const S2ModalConfig(
                        useFilter: true,
                        maxHeightFactor: .9,
                      ),

                      choiceStyle: S2ChoiceStyle(
                          raised: false,
                          color: Theme.of(context).colorScheme.secondary,
                          clipBehavior: Clip.antiAlias),
                      selectedValue: _initialIngredients,
                      tileBuilder: (context, state) {
                        return S2Tile.fromState(
                          state,
                          isTwoLine: true,
                          leading: Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: const Icon(Icons.brunch_dining),
                          ),
                        );
                      },
                      onChange: (selected) => setState(() {
                        _initialIngredients = selected.value;
                      }),
                    ),
                    SmartSelect<int>.multiple(
                      title: "Cooking Terms",
                      choiceItems: _cookingTerms,
                      choiceType: S2ChoiceType.chips,
                      modalType: S2ModalType.bottomSheet,
                      modalStyle: S2ModalStyle(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                      ),
                      modalHeaderStyle: const S2ModalHeaderStyle(
                        backgroundColor: Colors.white,
                        textStyle: TextStyle(color: Colors.black54),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                      ),
                      modalConfig: const S2ModalConfig(
                        useFilter: true,
                        maxHeightFactor: .9,
                      ),
                      choiceStyle: S2ChoiceStyle(
                          raised: false,
                          color: Theme.of(context).colorScheme.secondary,
                          clipBehavior: Clip.antiAlias),
                      selectedValue: _initialCookingTerms,
                      tileBuilder: (context, state) {
                        return S2Tile.fromState(
                          state,
                          isTwoLine: true,
                          leading: Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: const Icon(Icons.local_dining),
                          ),
                        );
                      },
                      onChange: (selected) => setState(() {
                        _initialCookingTerms = selected.value;
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : updateRecipe,
                        child: Text("Submit"),
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
