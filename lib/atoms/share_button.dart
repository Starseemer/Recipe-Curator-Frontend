import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShareButton extends StatefulWidget {
  const ShareButton({super.key, required this.url});

  final String url;

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recipe copied to clipboard!'),
            ),
          );
          await Clipboard.setData(ClipboardData(text: widget.url));
        },
        icon: const Icon(Icons.share, size: 40, color: Colors.white));
  }
}
