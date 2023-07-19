import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/cookie_manager.dart';

class CookingTermEditCard extends StatefulWidget {
  const CookingTermEditCard(
      {super.key, required this.data, this.isNew = false, this.context = null});

  final dynamic data;
  final bool isNew;
  final BuildContext? context;

  @override
  State<CookingTermEditCard> createState() => _CookingTermEditCardState();
}

class _CookingTermEditCardState extends State<CookingTermEditCard> {
  void deleteCookingTerm() async {
    http.Response response = await http.delete(
      Uri.http('localhost:8002', '/cooking-terms/${widget.data['id']}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        'Authorization': MyCookieManager().getCookie(),
      },
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
    }
  }

  void updateCookingTerm(String name, String desc) async {
    http.Response response = await http.put(
      Uri.http('localhost:8002', '/cooking-terms/${widget.data['id']}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        'Authorization': MyCookieManager().getCookie(),
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'desc': desc,
      }),
    );

    print("Update cooking response: ${response.statusCode}");

    if (response.statusCode == 200) {
      Navigator.pop(context);
    }
  }

  void createCookingTerm(String name, String desc) async {
    http.Response response = await http.post(
      Uri.http('localhost:8002', '/cooking-terms'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        'Authorization': MyCookieManager().getCookie(),
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'desc': desc,
      }),
    );

    print("Create cooking response: ${response.statusCode}");
    if (response.statusCode == 201) {
      Navigator.pop(widget.context!);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _nameController =
        TextEditingController(text: widget.data['name']);
    TextEditingController _descController =
        TextEditingController(text: widget.data['desc']);
    return SizedBox(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Cooking Term',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the cooking term';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  hintText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the cooking terms description';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      widget.isNew == false
                          ? updateCookingTerm(
                              _nameController.text, _descController.text)
                          : createCookingTerm(
                              _nameController.text, _descController.text);
                    },
                    icon: const Icon(Icons.save, color: Colors.green),
                    iconSize: 30,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.cancel,
                        color: Color.fromARGB(255, 162, 150, 36)),
                    iconSize: 30,
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  widget.isNew
                      ? const SizedBox()
                      : IconButton(
                          onPressed: () {
                            deleteCookingTerm();
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          iconSize: 30,
                        )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
