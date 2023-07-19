import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:recipe_curator/ingredients.dart';
import '../helpers/cookie_manager.dart';
import 'package:flutter/services.dart';

class RecipeCreateCard extends StatefulWidget {
  RecipeCreateCard({
    super.key,
  });

  @override
  State<RecipeCreateCard> createState() => _RecipeCreateCardState();
}

class _RecipeCreateCardState extends State<RecipeCreateCard> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _instController = TextEditingController();
  final _cookingController = TextEditingController();
  final _servingController = TextEditingController();
  bool _isSubmitting = false;
  List<MultiSelectItem<dynamic>> _ingredients = [];
  List<MultiSelectItem<dynamic>> _cookingTerms = [];
  List<dynamic> _selectedIngredients = [];
  List<dynamic> _selectedCookingTerms = [];

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
        _ingredients = ingredients
            .map((ingredient) => MultiSelectItem<dynamic>(
                  ingredient,
                  ingredient['name'],
                ))
            .toList();
        _cookingTerms = cookingTerms
            .map((cookingTerm) => MultiSelectItem<dynamic>(
                  cookingTerm,
                  cookingTerm['name'],
                ))
            .toList();
      });
    }
  }

  createRecipe() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      List<int> ing_ids = [];
      for (var ing in _selectedIngredients) {
        ing_ids.add(ing['id']);
      }
      for (var ct in _selectedCookingTerms) {
        ing_ids.add(ct['id']);
      }

      if (ing_ids.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one ingredient!'),
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Creating recipe...'),
        ),
      );

      http.Response response =
          await http.post(Uri.http('localhost:8001', '/recipes'),
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

      response.statusCode == 201
          ? ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recipe creted!'),
              ),
            )
          : ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recipe creation failed!'),
              ),
            );

      Navigator.of(context).popAndPushNamed('/home');
    }
  }

  @override
  void initState() {
    super.initState();

    getIngredients();
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
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        hintText: 'Cooking Time in minutes',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter cooking time';
                        }
                        return null;
                      },
                      maxLines: 1,
                    ),
                    TextFormField(
                      controller: _servingController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        FilteringTextInputFormatter.digitsOnly
                      ],
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
                      maxLines: 1,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 100.0,
                      child: MultiSelectBottomSheetField(
                        items: _ingredients,
                        onConfirm: (p0) {
                          setState(() {
                            _selectedIngredients = p0;
                          });
                        },
                        searchable: true,
                        title: Text("Ingredients"),
                        buttonText: Text("Select Ingredients"),
                        listType: MultiSelectListType.CHIP,
                        chipDisplay: MultiSelectChipDisplay(
                          onTap: (value) {
                            setState(() {
                              _selectedIngredients.remove(value);
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100.0,
                      child: MultiSelectBottomSheetField(
                        items: _cookingTerms,
                        onConfirm: (p0) {
                          setState(() {
                            _selectedCookingTerms = p0;
                          });
                        },
                        searchable: true,
                        title: Text("Cooking Terms"),
                        buttonText: Text("Select Cooking Terms"),
                        listType: MultiSelectListType.CHIP,
                        chipDisplay: MultiSelectChipDisplay(
                          onTap: (value) {
                            setState(() {
                              _selectedCookingTerms.remove(value);
                            });
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : createRecipe,
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
