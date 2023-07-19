import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'helpers/cookie_manager.dart';
import 'atoms/comment.dart';
import 'molecules/add_comment_button_form.dart';
import 'molecules/ingredient_edit.dart';

class Ingredients extends StatefulWidget {
  const Ingredients({super.key});

  @override
  State<Ingredients> createState() => _IngredientsState();
}

class _IngredientsState extends State<Ingredients> {
  List<dynamic> ingredients = [];
  int user_id = 0;
  TextEditingController searchController = TextEditingController();

  void getIngredients() async {
    http.Response response = await http.get(
      Uri.http('localhost:8002', '/ingredients'),
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
        ingredients = jsonDecode(response.body);
      });
    } else if (response.statusCode == 401) {
      Navigator.popAndPushNamed(context, '/login');
    }
  }

  Future<List> getComments(int id) async {
    List<dynamic> comments = [];
    http.Response response = await http.get(
      Uri.http('localhost:8003', '/comments/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        'Authorization': MyCookieManager().getCookie(),
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      Navigator.popAndPushNamed(context, '/login');
    }
    return comments;
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

  Future<void> searchIngredient(String term) async {
    try {
      http.Response response = await http.post(
        Uri.http('localhost:8005', '/search/shared_voc'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "Access-Control-Allow-Origin": "*",
          'Accept': '*/*',
          'Authorization': MyCookieManager().getCookie(),
        },
        body: jsonEncode(<String, dynamic>{
          'term': term,
          'type': 'Ingredient',
        }),
      );
      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
        setState(() {
          ingredients = jsonDecode(response.body);
        });
      } else if (response.statusCode == 401) {
        Navigator.popAndPushNamed(context, '/login');
      }
    } catch (e) {
      print("Exception caught: ");
      print(e);
    }
  }

  Widget? checkTrailing(ingredient) {
    if (user_id == ingredient["user_id"]) {
      return IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return Dialog(child: IngredientEditCard(data: ingredient));
            },
          ).then((value) => getIngredients());
        },
      );
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    getIngredients();
    getUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search Ingredients',
              hintStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 0.5),
              ),
              suffixIcon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              constraints: BoxConstraints(
                maxHeight: 45,
                maxWidth: 300,
              ),
            ),
            style: TextStyle(color: Colors.white),
            controller: searchController,
            onSubmitted: (value) {
              searchIngredient(value);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 40,
            onPressed: () {
              BuildContext dialogContext;
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  dialogContext = context;
                  dynamic data = {'name': '', 'desc': ''};
                  return Dialog(
                    child: IngredientEditCard(
                      data: data,
                      isNew: true,
                      context: dialogContext,
                    ),
                  );
                },
              ).then((value) => getIngredients());
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Card(
              child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  Future<List<dynamic>> comments =
                      getComments(ingredients[index]['id']);

                  return ExpansionTile(
                    backgroundColor: const Color.fromARGB(150, 42, 44, 138),
                    collapsedBackgroundColor:
                        const Color.fromARGB(150, 42, 44, 138),
                    childrenPadding: const EdgeInsets.only(
                        left: 20, bottom: 10, right: 20, top: 10),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    expandedAlignment: Alignment.topLeft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(
                          color: Color.fromARGB(149, 255, 255, 255), width: 1),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(
                          color: Color.fromARGB(149, 255, 255, 255), width: 1),
                    ),
                    title: Text(ingredients[index]['name'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    subtitle: Text(ingredients[index]['desc'],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 15)),
                    iconColor: Colors.white,
                    trailing: checkTrailing(ingredients[index]),
                    children: [
                      FutureBuilder(
                          builder: (context, AsyncSnapshot<List> snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data != null &&
                                snapshot.data!.isNotEmpty) {
                              List<Widget> comments_widget = [];
                              snapshot.data!.forEach((comment) {
                                comments_widget
                                    .add(CommentBar(comment: comment));
                              });

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ...comments_widget,
                                  const SizedBox(height: 10),
                                  CommentAdderButtonForm(
                                      shared_voc_id: ingredients[index]['id'],
                                      commentAddedInvoke: () {
                                        setState(() {
                                          comments = getComments(
                                              ingredients[index]['id']);
                                        });
                                      })
                                ],
                              );
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("No comments yet"),
                                  const SizedBox(height: 10),
                                  CommentAdderButtonForm(
                                      shared_voc_id: ingredients[index]['id'],
                                      commentAddedInvoke: () {
                                        setState(() {
                                          comments = getComments(
                                              ingredients[index]['id']);
                                        });
                                      })
                                ],
                              );
                            }
                          },
                          future: comments),
                    ],
                  );
                },
                itemCount: ingredients.length,
                shrinkWrap: true,
              ),
            )),
      ),
    );
  }
}
