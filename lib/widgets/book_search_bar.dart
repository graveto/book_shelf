import 'package:flutter/material.dart';

class BookSearchBar extends StatelessWidget {
  final Function(String) onSearchChanged;

  const BookSearchBar({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search books...',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}