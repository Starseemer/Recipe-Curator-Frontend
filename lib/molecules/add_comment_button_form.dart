import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/cookie_manager.dart';

class CommentAdderButtonForm extends StatefulWidget {
  const CommentAdderButtonForm(
      {super.key,
      required this.shared_voc_id,
      required this.commentAddedInvoke});

  final int shared_voc_id;
  final Function commentAddedInvoke;

  @override
  State<CommentAdderButtonForm> createState() => _CommentAdderButtonFormState();
}

class _CommentAdderButtonFormState extends State<CommentAdderButtonForm> {
  bool isSelected = false;
  bool commentAdded = false;
  final _formKey = GlobalKey<FormState>();

  Widget _buildButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isSelected = true;
        });
      },
      child: Container(
        child: Row(
          children: [
            const Icon(Icons.add),
            SizedBox(width: 10),
            const Text('Add comment'),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    TextEditingController commentController = TextEditingController();
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: commentController,
            decoration: const InputDecoration(
              hintText: 'Comment',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                addComment(commentController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comment added')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void addComment(String comment) async {
    http.Response response = await http.post(
      Uri.http('localhost:8003', '/comments/${widget.shared_voc_id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        "Authorization": MyCookieManager().getCookie(),
      },
      body: jsonEncode(<dynamic, dynamic>{
        'body': comment,
      }),
    );
    if (response.statusCode == 201) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.
      // return Comment.fromJson(jsonDecode(response.body));
      setState(() {
        isSelected = false;
      });
      widget.commentAddedInvoke();
    } else {
      // If the server did not return a 200 CREATED response,
      // then throw an exception.
      throw Exception('Failed to add comment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isSelected ? _buildForm() : _buildButton();
  }
}
