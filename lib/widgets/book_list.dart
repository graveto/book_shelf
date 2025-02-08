import 'package:flutter/material.dart';
import '../models/book.dart';

class BookList extends StatelessWidget {
  final List<Book> books;
  final Function(Book) onDelete; // Add this line
  final Function(Book) onEdit;

  const BookList(
      {super.key,
      required this.books,
      required this.onDelete,
      required this.onEdit}); // Update constructor

  @override
  Widget build(BuildContext context) {
    final cardTextColor = TextStyle(
      color: Color.fromARGB(
        255,
        28,
        20,
        20,
      ),
    );
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          child: ListTile(
            title: Text(book.title, style: cardTextColor),
            subtitle: Text(book.author, style: cardTextColor),
            leading: Text('#${book.number}', style: cardTextColor),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => onEdit(book), // Call onEdit with the book
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirm Delete"),
                        content: Text(
                            "Are you sure you want to delete '${book.title}'?"),
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: Text("Delete"),
                            onPressed: () {
                              onDelete(book);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  // onDelete(book), // Call onDelete with the book
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
