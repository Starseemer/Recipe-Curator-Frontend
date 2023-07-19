import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/cookie_manager.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({super.key, required this.id});

  final int id;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false;

  void checkIfLiked() async {
    http.Response response = await http.get(
      Uri.http('localhost:8004', '/favourites/check/${widget.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        "Authorization": MyCookieManager().getCookie(),
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        isLiked = true;
      });
    }
  }

  void likeRecipe() async {
    http.Response response = await http.post(
      Uri.http('localhost:8004', '/favourites/${widget.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        "Authorization": MyCookieManager().getCookie(),
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        isLiked = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLiked();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: likeRecipe,
        icon: Icon(
          Icons.favorite,
          color: isLiked ? Colors.red : Colors.grey,
          size: 40.0,
        ));
  }
}
