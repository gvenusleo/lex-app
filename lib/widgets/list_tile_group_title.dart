import "package:flutter/material.dart";

class ListTileGroupTitle extends StatelessWidget {
  const ListTileGroupTitle({
    Key? key,
    required this.title,
    this.padding = const EdgeInsets.only(left: 16, top: 12, bottom: 8),
  }) : super(key: key);

  final String title;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
