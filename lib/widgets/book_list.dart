import 'package:flutter/material.dart';
import '../models/book.dart';

class BookList extends StatelessWidget {
  final List<Book> books;
  final Function(Book) onDelete; // Add this line
  final Function(Book) onEdit;

  const BookList({super.key, required this.books, required this.onDelete, required this.onEdit}); // Update constructor

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          child: ListTile(
            title: Text(book.title),
            subtitle: Text(book.author),
          
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => onEdit(book), // Call onEdit with the book
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => onDelete(book), // Call onDelete with the book
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}