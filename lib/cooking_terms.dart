import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'helpers/cookie_manager.dart';
import 'atoms/comment.dart';
import 'molecules/add_comment_button_form.dart';
import 'molecules/cooking_term_edit.dart';

class CookingTerms extends StatefulWidget {
  const CookingTerms({super.key});

  @override
  State<CookingTerms> createState() => _CookingTermsState();
}

class _CookingTermsState extends State<CookingTerms> {
  List<dynamic> cookingTerms = [];
  TextEditingController searchController = TextEditingController();
  int user_id = 0;

  void getcookingTerms() async {
    http.Response response = await http.get(
      Uri.http('localhost:8002', '/cooking-terms'),
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
        cookingTerms = jsonDecode(response.body);
      });
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
    }
  }

  Future<void> searchCookingTerms(String term) async {
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
          'type': 'CookingTerms',
        }),
      );
      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
        setState(() {
          cookingTerms = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print("Exception caught: ");
      print(e);
    }
  }

  Widget? checkTrailing(cookingTerm) {
    if (user_id == cookingTerm["user_id"]) {
      return IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return Dialog(child: CookingTermEditCard(data: cookingTerm));
            },
          ).then((value) => getcookingTerms());
        },
      );
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    getcookingTerms();
    getUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooking Terms'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search Cooking Terms',
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
              searchCookingTerms(value);
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
                    child: CookingTermEditCard(
                      data: data,
                      isNew: true,
                      context: dialogContext,
                    ),
                  );
                },
              ).then((value) => getcookingTerms());
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
                      getComments(cookingTerms[index]['id']);

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
                    title: Text(cookingTerms[index]['name'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    subtitle: Text(cookingTerms[index]['desc'],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 15)),
                    iconColor: Colors.white,
                    trailing: checkTrailing(cookingTerms[index]),
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
                                      shared_voc_id: cookingTerms[index]['id'],
                                      commentAddedInvoke: () {
                                        setState(() {
                                          comments = getComments(
                                              cookingTerms[index]['id']);
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
                                      shared_voc_id: cookingTerms[index]['id'],
                                      commentAddedInvoke: () {
                                        setState(() {
                                          comments = getComments(
                                              cookingTerms[index]['id']);
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
                itemCount: cookingTerms.length,
                shrinkWrap: true,
              ),
            )),
      ),
    );
  }
}
