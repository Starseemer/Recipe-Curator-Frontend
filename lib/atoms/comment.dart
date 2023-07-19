import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/cookie_manager.dart';

class CommentBar extends StatefulWidget {
  const CommentBar({super.key, required this.comment});

  final dynamic comment;

  @override
  State<CommentBar> createState() => _CommentBarState();
}

class _CommentBarState extends State<CommentBar> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color.fromARGB(150, 42, 44, 138),
          border: Border.all(
              color: const Color.fromARGB(149, 255, 255, 255), width: 1),
        ),
        child: Row(
          children: [
            Text(
              "${widget.comment['user_email']} :",
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              widget.comment['comment'],
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ));
  }
}
