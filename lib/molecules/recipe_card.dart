import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecipeCard extends StatefulWidget {
  const RecipeCard({super.key, required this.data});

  final dynamic data;

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        child: InkWell(
          onTap: () {
            // context.go("/recipe/${widget.data['id']}");
            Navigator.of(context).pushNamed("/recipe/${widget.data['id']}");
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.data['title'],
                    style: const TextStyle(fontSize: 30)),
                Text(widget.data['description'],
                    style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
