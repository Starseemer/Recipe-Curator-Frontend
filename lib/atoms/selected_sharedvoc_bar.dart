import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/cookie_manager.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class SelectedSharedVocBar extends StatefulWidget {
  const SelectedSharedVocBar(
      {super.key,
      required this.title,
      required this.initialValue,
      required this.terms,
      required this.onSelected,
      required this.onItemRemoved});

  final String title;
  final List<dynamic> initialValue;
  final List<MultiSelectItem<dynamic>> terms;
  final Function(List<dynamic>) onSelected;
  final Function(List<dynamic>) onItemRemoved;

  @override
  State<SelectedSharedVocBar> createState() => _SelectedSharedVocBarState();

  checkIfSelectedExists(name) {
    for (var ingredient in initialValue) {
      if (ingredient['name'] == name) {
        return true;
      }
    }
    return false;
  }
}

class _SelectedSharedVocBarState extends State<SelectedSharedVocBar> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget createNameBubble(name) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color.fromARGB(150, 42, 44, 138),
        border: Border.all(
            color: const Color.fromARGB(149, 255, 255, 255), width: 1),
      ),
      child: Text(
        name,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        showModalBottomSheet(
            isScrollControlled: true,
            constraints: BoxConstraints.loose(
                Size.square(MediaQuery.of(context).size.height * 0.6)),
            context: context,
            builder: (context) {
              return Container(
                alignment: Alignment.topCenter,
                height: 600,
                child: MultiSelectBottomSheet(
                  maxChildSize: 0.6,
                  items: widget.terms,
                  initialValue: widget.initialValue,
                  onConfirm: widget.onSelected,
                  onSelectionChanged: widget.onItemRemoved,
                  searchable: true,
                  title: Text(widget.title),
                  listType: MultiSelectListType.CHIP,
                ),
              );
            });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontSize: 20),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (var ingredient in widget.initialValue)
                  createNameBubble(ingredient['name']),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
