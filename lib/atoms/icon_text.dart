import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  const IconText(
      {Key? key,
      required this.icon,
      required this.text,
      this.textStyle,
      this.width,
      this.height})
      : super(key: key);

  final Icon icon;
  final String text;
  final TextStyle? textStyle;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          icon,
          const SizedBox(height: 10),
          Text(text, style: textStyle),
        ],
      ),
    );
  }
}
